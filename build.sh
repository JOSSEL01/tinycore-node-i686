#!/bin/bash
# ============================================
# Compilador de Node.js para Tiny Core i686
# ============================================
# Autor: Jose Andres Mamani Mollericona
# GitHub: JOSSEL01
# ============================================
# Este script hace TODO el proceso:
# 1. Instala dependencias
# 2. Descarga el código fuente
# 3. Aplica parche para Python 3.14
# 4. Configura para i686
# 5. Compila Node.js
# 6. Instala en directorio temporal
# 7. Estripa binarios
# 8. Crea metadatos (.info, .dep, .list)
# 9. Empaqueta como .tcz
# 10. Genera el .md5.txt
# ============================================

set -e

# ============================================
# CONFIGURACIÓN
# ============================================
NODE_VERSION="v20.19.2"
BUILD_DIR="$HOME/node-build"
PACKAGE_DIR="/tmp/node-package"
OUTPUT_DIR="/tmp"
EXTENSION_NAME="node-$NODE_VERSION"

# ============================================
# COLORES
# ============================================
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Compilador de Node.js para Tiny Core i686${NC}"
echo -e "${GREEN}  Versión: $NODE_VERSION${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================
# VERIFICAR SI ES ROOT PARA INSTALAR PAQUETES
# ============================================
if [ "$EUID" -eq 0 ]; then
    SUDO=""
else
    SUDO="sudo"
fi

# ============================================
# [1/8] INSTALAR DEPENDENCIAS
# ============================================
echo -e "\n${YELLOW}[1/8] Instalando dependencias...${NC}"

# Verificar si estamos en Fedora/RHEL
if command -v dnf &> /dev/null; then
    PKG_MANAGER="dnf"
elif command -v yum &> /dev/null; then
    PKG_MANAGER="yum"
else
    echo -e "${RED}No se encontró dnf ni yum. Este script es para Fedora/RHEL.${NC}"
    exit 1
fi

# Lista de paquetes necesarios
PACKAGES=(
    "gcc"
    "gcc-c++"
    "make"
    "python3"
    "wget"
    "tar"
    "xz"
    "glibc-devel.i686"
    "libstdc++.i686"
    "openssl-devel.i686"
    "zlib-ng-compat-devel.i686"
    "libstdc++-devel.i686"
    "libgcc.i686"
    "squashfs-tools"
)

echo -e "${YELLOW}Instalando paquetes de compilación...${NC}"
$SUDO $PKG_MANAGER install -y "${PACKAGES[@]}" 2>&1 | tail -10

# Verificar soporte 32 bits
echo 'int main(){return 0;}' > /tmp/test-node.c
if ! gcc -m32 /tmp/test-node.c -o /tmp/test-node 2>/dev/null; then
    echo -e "${RED}Error: GCC no puede compilar para 32 bits.${NC}"
    echo -e "${YELLOW}Instala: sudo dnf install -y glibc-devel.i686 libstdc++.i686${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Dependencias instaladas y verificadas${NC}"

# ============================================
# [2/8] DESCARGAR CÓDIGO FUENTE
# ============================================
echo -e "\n${YELLOW}[2/8] Descargando Node.js $NODE_VERSION...${NC}"

mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

if [ ! -f "node-$NODE_VERSION.tar.xz" ]; then
    wget "https://nodejs.org/dist/$NODE_VERSION/node-$NODE_VERSION.tar.xz"
else
    echo -e "${GREEN}✓ El archivo ya existe${NC}"
fi

if [ -d "node-$NODE_VERSION" ]; then
    rm -rf "node-$NODE_VERSION"
fi
tar -xf "node-$NODE_VERSION.tar.xz"
cd "node-$NODE_VERSION"
echo -e "${GREEN}✓ Código fuente extraído${NC}"

# ============================================
# [3/8] APLICAR PARCHE PARA PYTHON 3.14
# ============================================
echo -e "\n${YELLOW}[3/8] Aplicando parche para Python 3.14...${NC}"

NODEDOWNLOAD="tools/configure.d/nodedownload.py"
if [ -f "$NODEDOWNLOAD" ]; then
    # Reemplazar imports antiguos
    sed -i 's/^try:$/from urllib.request import build_opener, install_opener, urlretrieve/; /^    from urllib.request import FancyURLopener, URLopener$/d; /^except ImportError:$/d; /^    from urllib import FancyURLopener, URLopener$/d' "$NODEDOWNLOAD"
    # Eliminar clase ConfigOpener obsoleta
    sed -i '/^class ConfigOpener/,/^$/d' "$NODEDOWNLOAD"
    
    # Reemplazar la llamada a retrieve
    sed -i 's/^        ConfigOpener()\.retrieve(url, targetfile, reporthook=reporthook)$/        opener = build_opener()\n        opener.addheaders = [("User-Agent", "Python-urllib\/3.14 node.js\/configure")]\n        install_opener(opener)\n        urlretrieve(url, targetfile, reporthook=reporthook)/' "$NODEDOWNLOAD"
    
    echo -e "${GREEN}✓ Parche aplicado${NC}"
else
    echo -e "${YELLOW}⚠ No se encontró $NODEDOWNLOAD, omitiendo parche${NC}"
fi

# ============================================
# [4/8] CONFIGURAR
# ============================================
echo -e "\n${YELLOW}[4/8] Configurando para i686...${NC}"

rm -rf out
python3 configure.py \
    --dest-cpu=ia32 \
    --prefix=/usr/local \
    --shared-openssl \
    --shared-zlib \
    --without-intl

echo -e "${GREEN}✓ Configuración completada${NC}"

# ============================================
# [5/8] COMPILAR
# ============================================
echo -e "\n${YELLOW}[5/8] Compilando Node.js con $(nproc) hilos...${NC}"
echo -e "${YELLOW}Esto puede tardar 15-30 minutos...${NC}"

make -j$(nproc)

echo -e "${GREEN}✓ Compilación completada${NC}"

# ============================================
# [6/8] INSTALAR Y ESTRIBAR
# ============================================
echo -e "\n${YELLOW}[6/8] Instalando en $PACKAGE_DIR...${NC}"

rm -rf "$PACKAGE_DIR"
make install DESTDIR="$PACKAGE_DIR"

echo -e "${YELLOW}Estripando binarios...${NC}"

if [ -f "$PACKAGE_DIR/usr/local/bin/node" ]; then
    strip "$PACKAGE_DIR/usr/local/bin/node"
fi

find "$PACKAGE_DIR" -type f -exec file {} \; 2>/dev/null | \
    grep 'ELF' | awk -F: '{print $1}' | \
    xargs strip 2>/dev/null || true

echo -e "${GREEN}✓ Instalación y estripado completados${NC}"

# ============================================
# [7/8] CREAR METADATOS Y EMPAQUETAR
# ============================================
echo -e "\n${YELLOW}[7/8] Creando metadatos y empaquetando...${NC}"

# Calcular tamaño
PACKAGE_SIZE=$(du -sh "$PACKAGE_DIR" | cut -f1)

# Crear archivo .info
cat > "$PACKAGE_DIR/usr/local/share/node.tcz.info" << EOF
Title:          node.tcz
Description:    Node.js JavaScript runtime (v$NODE_VERSION)
Version:        ${NODE_VERSION#v}
Author:         OpenJS Foundation
Original-site:  https://nodejs.org
Copying-policy: MIT
Size:           $PACKAGE_SIZE
Extension_by:   Jose Andres Mamani Mollericona
Comments:       Compilado para i686 desde Fedora 43 (github.com/JOSSEL01)
Change-log:     Compilado manualmente
Current:        $(date +%Y-%m-%d)
EOF

# Crear archivo .dep
cat > "$OUTPUT_DIR/$EXTENSION_NAME.tcz.dep" << EOF
openssl.tcz
EOF

# Crear archivo .list
cd "$PACKAGE_DIR"
find usr -not -type d > "$OUTPUT_DIR/$EXTENSION_NAME.tcz.list"

# Empaquetar como .tcz
cd /tmp
mksquashfs node-package "$EXTENSION_NAME.tcz"

# Crear .md5.txt
md5sum "$EXTENSION_NAME.tcz" > "$EXTENSION_NAME.tcz.md5.txt"

echo -e "${GREEN}✓ Metadatos y paquete creados${NC}"

# ============================================
# [8/8] RESUMEN FINAL
# ============================================
echo -e "\n${GREEN}[8/8] ¡COMPILACIÓN COMPLETADA!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "Archivos generados en ${YELLOW}$OUTPUT_DIR${NC}:"
echo ""
ls -lh "$OUTPUT_DIR/$EXTENSION_NAME"* 2>/dev/null || true
echo ""
echo -e "${YELLOW}Para instalar en Tiny Core:${NC}"
echo "  1. Copia $EXTENSION_NAME.tcz a /etc/sysconfig/tcedir/optional/"
echo "  2. Ejecuta: tce-load -i $EXTENSION_NAME"
echo "  3. Verifica: node --version"
echo ""
echo -e "${GREEN}¡Listo!${NC}"
