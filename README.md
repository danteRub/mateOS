# Arch Hyprland Installer

Instalador 100% interactivo de Arch Linux con Hyprland, Wayland puro, sbctl y dotfiles listos.

## Requisitos

- Conexión a Internet
- Ejecutar desde una ISO oficial de Arch Linux en modo UEFI
- Instalar 'gum': `pacman -Sy gum`

## Instalación

```bash
git clone https://github.com/tuusuario/arch-hyprland-installer.git
cd arch-hyprland-installer
chmod +x *.sh
./install.sh
```

## Características

- Hyprland + Waybar + Wofi
- Secure Boot (sbctl)
- SDDM
- Dotfiles (zsh, gtk, qt, polkit, etc.)
- Zram + Pipewire + Starship
