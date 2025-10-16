#!/bin/bash
# Script para sincronizar cambios del repo local a la instalación de mateOS

echo "🔄 Sincronizando cambios a la instalación de mateOS..."

# 1. Copiar archivos actualizados del repo a la instalación
echo "📦 Copiando archivos del repositorio a ~/.local/share/mateos/..."

# Eliminar archivos antiguos de bash
rm -rf ~/.local/share/mateos/default/bash
rm -f ~/.local/share/mateos/default/bashrc

# Copiar todos los archivos actualizados
rsync -av --exclude='.git' /home/rubrick/GitHub/mateOS/ ~/.local/share/mateos/

echo "✅ Archivos sincronizados!"
echo ""

# 2. Instalar paquetes necesarios
echo "📦 Instalando paquetes de zsh..."
yay -S --needed --noconfirm zsh zsh-autosuggestions zsh-syntax-highlighting oh-my-zsh-git

# 3. Desinstalar paquetes antiguos
echo "🗑️  Eliminando paquetes antiguos..."
yay -R --noconfirm bash-completion 2>/dev/null || echo "bash-completion ya no está instalado"
yay -R --noconfirm 1password-beta 1password-cli 2>/dev/null || echo "1password ya no está instalado"

# 4. Hacer backup de configuraciones existentes
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
echo "💾 Haciendo backup de configuraciones en: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

# Backup de archivos que se van a modificar
if [ -f ~/.zshrc ]; then
  cp ~/.zshrc "$BACKUP_DIR/zshrc.backup"
fi
if [ -d ~/.config/hypr ]; then
  cp -r ~/.config/hypr "$BACKUP_DIR/hypr"
fi

# 5. Aplicar configuraciones
echo "🔧 Aplicando configuraciones..."

# Copiar .zshrc
cp -f ~/.local/share/mateos/default/zshrc ~/.zshrc

# Copiar configs de hyprland (en lugar de copiar todo ~/.local/share/mateos/config/*)
mkdir -p ~/.config/hypr
cp -f ~/.local/share/mateos/config/hypr/bindings.conf ~/.config/hypr/bindings.conf
cp -f ~/.local/share/mateos/config/hypr/hypridle.conf ~/.config/hypr/hypridle.conf
cp -f ~/.local/share/mateos/default/hypr/apps.conf ~/.config/hypr/apps.conf
rm -f ~/.config/hypr/apps/1password.conf 2>/dev/null

# Cambiar shell a zsh
chsh -s /usr/bin/zsh

# 6. Actualizar script de bloqueo
echo "🔒 Actualizando script de bloqueo..."
sudo cp -f ~/.local/share/mateos/bin/mateos-lock-screen /usr/local/bin/mateos-lock-screen
sudo chmod +x /usr/local/bin/mateos-lock-screen

# 7. Recargar Hyprland
echo "🔄 Recargando Hyprland..."
hyprctl reload 2>/dev/null || echo "No se pudo recargar Hyprland (tal vez no estás en una sesión de Hyprland)"

echo ""
echo "✅ ¡Instalación completada!"
echo ""
echo "📌 Cambios aplicados:"
echo "   ✓ Migrado de bash a zsh con oh-my-zsh"
echo "   ✓ Eliminado 1password y bash-completion"
echo "   ✓ Actualizadas configuraciones de Hyprland"
echo "   ✓ Eliminados bindings: SUPER+/, SUPER+C, SUPER+E, SUPER+X"
echo ""
echo "💾 Backup guardado en: $BACKUP_DIR"
echo "   (puedes restaurar desde ahí si algo sale mal)"
echo ""
echo "📌 Próximos pasos:"
echo "   1. Cierra esta terminal"
echo "   2. Abre una nueva terminal (se abrirá con zsh)"
echo "   3. Verifica que todo funcione correctamente"
echo ""

