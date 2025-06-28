# mateOS · Arch Linux Hyprland Installer

**mateOS** es un instalador totalmente automatizado e interactivo de Arch Linux, optimizado para Hyprland, Wayland puro, Secure Boot y dotfiles integrados.

## ✅ Características
y mejorado para entorno propi
- Instalación guiada con [`gum`](https://github.com/charmbracelet/gum)
- Entorno **Hyprland** sin X11: incluye Waybar, Wofi, PipeWire, etc.
- Soporte para **Secure Boot** (`sbctl`)
- Login con **SDDM**
- Archivos de configuración (`dotfiles`) para Zsh, GTK, QT y autostart
- Particionado automático en Btrfs con subvolúmenes y compresión
- Sincronización de hora, red, sonido, brillo, clipboard y más
- Integración lista para clonar y ejecutar desde GitHub

---

## 🚀 Instalación rápida desde Arch ISO (modo UEFI)

1. Inicia desde la [ISO oficial de Arch Linux](https://archlinux.org/download/)
2. Conéctate a internet
3. Ejecuta:

```bash
bash <(curl -sL https://raw.githubusercontent.com/danteRub/mateOS/main/bootstrap.sh)
```

Esto clonará el repo y lanzará el instalador interactivo.

---

## 📁 Estructura del repositorio

```
mateOS/
├── install.sh            # Script principal interactivo
├── 00-preinstall.sh
├── 01-disk-setup.sh
├── 02-install-base.sh
├── 03-chroot-setup.sh
├── 04-postinstall.sh
├── bootstrap.sh          # Script para ejecución vía curl
├── dotfiles/
│   ├── .zshrc
│   ├── .zprofile
│   └── .config/
│       ├── gtk-3.0/
│       ├── qt5ct/
│       └── hypr/
└── README.md
```

---

## 🔧 Requisitos mínimos

- Sistema compatible con UEFI
- Conexión a internet durante la instalación
- Uso en Live ISO de Arch (recomendado)

---

## 🧠 Créditos

Desarrollado por [danteRub](https://github.com/danteRub) como un entorno Arch limpio, moderno y reproducible con enfoque en Hyprland y Wayland puro.

Inspirado por [Chris Titus Tech](https://github.com/ChrisTitusTech/ArchTitus).
