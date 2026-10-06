#!/bin/bash
# Script de compilación de Node.js para Tiny Core i686
set -e

NODE_VERSION="v20.19.2"
BUILD_DIR="$HOME/node-build"
PACKAGE_DIR="/tmp/node-package"

echo "==> Descargando Node.js $NODE_VERSION..."
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"
wget -nc "https://nodejs.org/dist/$NODE_VERSION/node-$NODE_VERSION.tar.xz"
tar -xf "node-$NODE_VERSION.tar.xz"
cd "node-$NODE_VERSION"

echo "==> Configurando para i686..."
rm -rf out
python3 configure.py \
  --dest-cpu=ia32 \
  --prefix=/usr/local \
  --shared-openssl \
  --shared-zlib \
  --without-intl

echo "==> Compilando con $(nproc) hilos..."
make -j$(nproc)

echo "==> Instalando en $PACKAGE_DIR..."
rm -rf "$PACKAGE_DIR"
make install DESTDIR="$PACKAGE_DIR"

echo "==> Estripando binarios..."
strip "$PACKAGE_DIR/usr/local/bin/node"
find "$PACKAGE_DIR" -type f -exec file {} \; | grep 'ELF' | awk -F: '{print $1}' | xargs strip 2>/dev/null || true

echo "==> Empaquetando .tcz..."
cd /tmp
mksquashfs node-package "node-$NODE_VERSION.tcz"

echo "==> Listo: /tmp/node-$NODE_VERSION.tcz"
ls -lh "/tmp/node-$NODE_VERSION.tcz"
