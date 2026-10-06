# Node.js v20.19.2 para Tiny Core Linux i686

Extensión .tcz de Node.js v20.19.2 compilada para Tiny Core Linux 17.0 (i686, 32 bits).

## Instalación rápida

Desde tu Tiny Core, ejecuta:

`bash
wget https://github.com/JOSSEL01/tinycore-node-i686/raw/main/packages/node-v20.19.2.tcz
sudo mv node-v20.19.2.tcz /etc/sysconfig/tcedir/optional/
tce-load -i node-v20.19.2
node --version
