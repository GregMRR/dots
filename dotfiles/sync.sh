#!/usr/bin/env bash
# Commit and push ~/.config changes. Run by config-sync.timer at boot and daily.
set -euo pipefail
cd "$HOME/.config"

pacman -Qqen > dotfiles/packages/pacman.txt
pacman -Qqem > dotfiles/packages/aur.txt

git add -A
if ! git diff --cached --quiet; then
    git commit -q -m "auto-sync $(hostname) $(date '+%F %H:%M')"
fi

# Offline is fine: unpushed commits go out on the next successful run.
git push -q origin main || echo "push failed (offline?), will retry next run"
