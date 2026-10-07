# Node.js v20.19.2 para Tiny Core Linux i686

![Node.js](https://img.shields.io/badge/Node.js-v20.19.2-brightgreen)
![Platform](https://img.shields.io/badge/Platform-i686-blue)
![Tiny Core](https://img.shields.io/badge/Tiny%20Core-17.0-orange)
![License](https://img.shields.io/badge/License-MIT-yellow)

Extensión `.tcz` de **Node.js v20.19.2** compilada para **Tiny Core Linux 17.0 (i686, 32 bits)**.

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

- ✅ Node.js **v20.19.2 LTS** (Mantenimiento LTS hasta abril de 2026)
- ✅ Compilado para **i686 (32 bits)**, compatible con equipos antiguos
- ✅ Incluye **npm** v10.x
- ✅ Binarios **estripados** para reducir el tamaño del paquete
- ✅ Compatible con **glibc 2.42** (la misma que usa Tiny Core 17.0)
- ✅ Tamaño del paquete: **~35 MB**

---

## 📦 Requisitos

- **Tiny Core Linux 17.0** (o compatible)
- **Arquitectura i686** (32 bits)
- **glibc 2.42** o superior
- Al menos **100 MB de espacio libre** en disco

---

## 🚀 Instalación rápida

Desde la terminal de tu Tiny Core:

```bash
wget https://github.com/JOSSEL01/tinycore-node-i686/raw/main/packages/node-v20.19.2.tcz
sudo mv node-v20.19.2.tcz /etc/sysconfig/tcedir/optional/
tce-load -i node-v20.19.2
node --version
```

Deberías ver: `v20.19.2`

---

## 🔧 Instalación manual

1. Descarga `node-v20.19.2.tcz` desde la carpeta `packages/`.
2. Cópialo a `/etc/sysconfig/tcedir/optional/` en tu Tiny Core.
3. Ejecuta:
   ```bash
   tce-load -i node-v20.19.2
   ```
4. Verifica:
   ```bash
   node --version
   npm --version
   ```

---

## ✅ Verificación

```bash
node --version
# Salida esperada: v20.19.2

npm --version
# Salida esperada: 10.x.x

file $(which node)
# Salida esperada: ELF 32-bit LSB executable, Intel 80386...
```

---

## 🛠️ Detalles de compilación

| Parámetro | Valor |
|---|---|
| **Versión de Node.js** | v20.19.2 LTS |
| **Sistema anfitrión** | Fedora 43 x86_64 |
| **Arquitectura objetivo** | i686 (32 bits) |
| **glibc** | 2.42 |
| **GCC** | 15.2.0 |
| **Flags** | `--dest-cpu=ia32 --prefix=/usr/local --shared-openssl --shared-zlib --without-intl` |

---

## ⚠️ Limitaciones

- **Sin soporte `Intl`:** Este paquete fue compilado con `--without-intl`, por lo que las funciones de internacionalización (`Intl.DateTimeFormat`, `Intl.NumberFormat`, etc.) no están disponibles.

- **Soporte i686 experimental:** Node.js clasifica el soporte para arquitecturas de 32 bits como experimental desde la versión 10.

---

## 🐛 Solución de problemas

### Error: `node: error while loading shared libraries: libssl.so.3`

**Solución:**
```bash
tce-load -wi openssl
```

### Error: `node: command not found`

**Solución:**
```bash
tce-load -i node-v20.19.2
which node
```

---

## 🔨 Recompilar desde cero

Usa el script `build.sh` incluido en este repositorio:

```bash
chmod +x build.sh
./build.sh
```

Edita la variable `NODE_VERSION` en `build.sh` para cambiar de versión.

---

## 📄 Licencia

Node.js es software libre bajo la [licencia MIT](https://github.com/nodejs/node/blob/main/LICENSE).

---

## 📞 Contacto

- **Autor:** Jose Andres Mamani Mollericona
- **GitHub:** [@JOSSEL01](https://github.com/JOSSEL01)
- **Repositorio:** [tinycore-node-i686](https://github.com/JOSSEL01/tinycore-node-i686)
