#!/bin/bash
# ============================================
# Compilador de Node.js para Tiny Core i686
# ============================================
# Autor: Jose Andres Mamani Mollericona
# GitHub: JOSSEL01
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
# VERIFICAR DEPENDENCIAS
# ============================================
echo -e "\n${YELLOW}[1/7] Verificando dependencias...${NC}"

DEPS=("gcc" "g++" "make" "python3" "wget" "tar" "xz")
MISSING=()

for dep in "${DEPS[@]}"; do
    if ! command -v "$dep" &> /dev/null; then
        MISSING+=("$dep")
    fi
done

if [ ${#MISSING[@]} -ne 0 ]; then
    echo -e "${RED}Faltan dependencias:${NC}"
    printf '%s\n' "${MISSING[@]}"
    echo -e "${YELLOW}Instálalas con:${NC}"
    echo "sudo dnf install -y gcc gcc-c++ make python3 wget tar xz squashfs-tools"
    exit 1
fi

# Verificar soporte 32 bits
echo 'int main(){return 0;}' > /tmp/test-node.c
if ! gcc -m32 /tmp/test-node.c -o /tmp/test-node 2>/dev/null; then
    echo -e "${RED}Error: GCC no puede compilar para 32 bits.${NC}"
    echo -e "${YELLOW}Instala: sudo dnf install -y glibc-devel.i686 libstdc++.i686${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Dependencias verificadas${NC}"

# ============================================
# DESCARGAR CÓDIGO FUENTE
# ============================================
echo -e "\n${YELLOW}[2/7] Descargando Node.js $NODE_VERSION...${NC}"

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
# PARCHE PARA PYTHON 3.14 (si es necesario)
# ============================================
echo -e "\n${YELLOW}[3/7] Aplicando parche para Python 3.14...${NC}"

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
    echo -e "${YELLOW}⚠️ No se encontró $NODEDOWNLOAD, omitiendo parche${NC}"
fi

# ============================================
# CONFIGURAR
# ============================================
echo -e "\n${YELLOW}[4/7] Configurando para i686...${NC}"

rm -rf out
python3 configure.py \
    --dest-cpu=ia32 \
    --prefix=/usr/local \
    --shared-openssl \
    --shared-zlib \
    --without-intl

echo -e "${GREEN}✓ Configuración completada${NC}"
# ============================================
# COMPILAR
# ============================================
echo -e "\n${YELLOW}[5/7] Compilando Node.js con $(nproc) hilos...${NC}"
echo -e "${YELLOW}Esto puede tardar 15-30 minutos...${NC}"

make -j$(nproc)

echo -e "${GREEN}✓ Compilación completada${NC}"

# ============================================
# INSTALAR EN DIRECTORIO TEMPORAL
# ============================================
echo -e "\n${YELLOW}[6/7] Instalando en $PACKAGE_DIR...${NC}"

rm -rf "$PACKAGE_DIR"
make install DESTDIR="$PACKAGE_DIR"

echo -e "${GREEN}✓ Instalación completada${NC}"

# ============================================
# ESTRIBAR BINARIOS
# ============================================
echo -e "\n${YELLOW}[7/7] Estripando y empaquetando...${NC}"

# Estripar binario principal
if [ -f "$PACKAGE_DIR/usr/local/bin/node" ]; then
    strip "$PACKAGE_DIR/usr/local/bin/node"
fi

# Estripar todos los ELF
find "$PACKAGE_DIR" -type f -exec file {} \; 2>/dev/null | \
    grep 'ELF' | awk -F: '{print $1}' | \
    xargs strip 2>/dev/null || true

echo -e "${GREEN}✓ Binarios estripados${NC}"

# ============================================
# CREAR METADATOS
# ============================================
# Crear archivo .info
cat > "$PACKAGE_DIR/usr/local/share/node.tcz.info" << EOF
Title:          node.tcz
Description:    Node.js JavaScript runtime (v$NODE_VERSION)
Version:        ${NODE_VERSION#v}
Author:         OpenJS Foundation
Original-site:  https://nodejs.org
Copying-policy: MIT
Size:           $(du -sh "$PACKAGE_DIR" | cut -f1)
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

# ============================================
# RESUMEN FINAL
# ============================================
echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}  ¡COMPILACIÓN COMPLETADA!${NC}"
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
