# Node.js v20.19.2 para Tiny Core Linux i686

![Node.js](https://img.shields.io/badge/Node.js-v20.19.2-brightgreen)
![Platform](https://img.shields.io/badge/Platform-i686-blue)
![Tiny Core](https://img.shields.io/badge/Tiny%20Core-17.0-orange)
![License](https://img.shields.io/badge/License-MIT-yellow)

Extensión .tcz de Node.js v20.19.2 compilada específicamente para Tiny Core Linux 17.0 (i686, 32 bits).

---

## 📋 Tabla de contenidos

- [Características](#-características)
- [Requisitos](#-requisitos)
- [Instalación rápida](#-instalación-rápida)
- [Instalación manual](#-instalación-manual)
- [Verificación](#-verificación)
- [Detalles de compilación](#-detalles-de-compilación)
- [Limitaciones](#-limitaciones)
- [Solución de problemas](#-solución-de-problemas)
- [Recompilar desde cero](#-recompilar-desde-cero)
- [Licencia](#-licencia)

---

## ✨ Características

- ✅ Node.js v20.19.2 LTS (Mantenimiento LTS hasta abril de 2026)
- ✅ Compilado para i686 (32 bits), compatible con equipos antiguos
- ✅ Incluye npm v10.x
- ✅ Binarios estripados para reducir el tamaño del paquete
- ✅ Compatible con glibc 2.42 (la misma que usa Tiny Core 17.0)
- ✅ Tamaño del paquete: ~35 MB

---

## 📦 Requisitos

- Tiny Core Linux 17.0 (o compatible)
- Arquitectura i686 (32 bits)
- glibc 2.42 o superior
- Al menos 100 MB de espacio libre en disco
- Conexión a Internet (solo para la instalación rápida)

---

## 🚀 Instalación rápida

Desde la terminal de tu Tiny Core, ejecuta estos comandos:

`bash
# Descargar la extensión
wget https://github.com/JOSSEL01/tinycore-node-i686/raw/main/packages/node-v20.19.2.tcz

# Mover a la carpeta de extensiones
sudo mv node-v20.19.2.tcz /mnt/sda(_)/tce/optional/

# Instalar
tce-load -i node-v20.19.2

# Colocar en Onboot
nano /etc/sysconfig/tcedir/onboot.lst

Ir hasta la parte final del archivo y poner node-v20.19.2.tcz y con las teclas ctrl + o luego enter luego ctrl + x y ya estaria

# Verificar
node --version
