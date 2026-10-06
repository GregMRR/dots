#!/usr/bin/env bash
# Restore this config on a fresh Arch install.
# Prereq: an SSH key added to GitHub (ssh-keygen -t ed25519, then add ~/.ssh/id_ed25519.pub).
set -euo pipefail
REPO=git@github.com:GregMRR/dots.git

sudo pacman -S --needed --noconfirm git base-devel openssh

# Clone into the existing ~/.config without deleting files the repo doesn't track.
tmp=$(mktemp -d)
git clone "$REPO" "$tmp/dots"
mkdir -p "$HOME/.config"
mv "$tmp/dots/.git" "$HOME/.config/.git"
rm -rf "$tmp"
git -C "$HOME/.config" checkout -f main

if ! command -v yay >/dev/null; then
    tmp=$(mktemp -d)
    git clone https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin"
    (cd "$tmp/yay-bin" && makepkg -si --noconfirm)
    rm -rf "$tmp"
fi

cd "$HOME/.config"
# Skip packages that no longer exist in the repos instead of failing the whole install.
comm -12 <(sort dotfiles/packages/pacman.txt) <(pacman -Slq | sort) \
    | sudo pacman -S --needed --noconfirm -
yay -S --needed --noconfirm - < dotfiles/packages/aur.txt || echo "some AUR packages failed; check output above"

systemctl --user daemon-reload
systemctl --user enable --now config-sync.timer
echo "Done. Log out and back in (or reboot) to start Hyprland with the restored config."
