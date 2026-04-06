#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="/home/sebastian/Documents/dotfiles/nixos/hosts/sebastian-laptop-legion/configuration.nix"
OPTION="nixfiles.passwordless-sudo.enable"

# Sprawdź aktualny stan
if grep -q "${OPTION} = true" "$CONFIG_FILE"; then
    NEW_STATE="false"
    ACTION="wyłączam"
else
    NEW_STATE="true"
    ACTION="włączam"
fi

echo "🔐 $ACTION passwordless-sudo..."

# Zmień ustawienie
sed -i "s/${OPTION} = [a-z]*;/${OPTION} = ${NEW_STATE};/" "$CONFIG_FILE"

echo "✓ Konfiguracja zmieniona: ${OPTION} = ${NEW_STATE}"
echo ""
echo "Uruchamiam: sudo nixos-rebuild switch --flake /home/sebastian/Documents/dotfiles#sebastian-laptop-legion --quiet"
sudo nixos-rebuild switch --flake /home/sebastian/Documents/dotfiles#sebastian-laptop-legion --quiet

echo ""
echo "✓ Gotowe!"
