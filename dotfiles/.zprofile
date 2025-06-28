#!/bin/bash
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &

# Portal workaround
sleep 1 && xdg-desktop-portal-hyprland &

# Waybar
waybar &
