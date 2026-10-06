#!/usr/bin/env bash
# Commit and push ~/.config changes. Run by config-sync.timer at boot and daily.
set -euo pipefail
cd "$HOME/.config"

pacman -Qqen > dotfiles/packages/pacman.txt
pacman -Qqem > dotfiles/packages/aur.txt

# Refuse to commit anything that looks like a secret; leave the changes unstaged.
block() {
    git reset -q
    echo "BLOCKED: $1" >&2
    notify-send -u critical "Config sync blocked" "$1
See: journalctl --user -u config-sync" || true
    exit 1
}

git add -A
if ! git diff --cached --quiet; then
    command -v gitleaks >/dev/null || block "gitleaks is not installed, refusing to commit unchecked changes."
    if ! gitleaks git --pre-commit --staged --redact -v --no-banner --exit-code 1 >&2; then
        block "Possible secret in staged changes. Remove it (or add its fingerprint to .gitleaksignore if it's a false positive)."
    fi
    git commit -q -m "auto-sync $(hostname) $(date '+%F %H:%M')"
fi

# Offline is fine: unpushed commits go out on the next successful run.
git push -q origin main || echo "push failed (offline?), will retry next run"
