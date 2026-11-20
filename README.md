# dots

`~/.config` for my Arch + Hyprland laptop (hostname `unicorn`). A systemd timer keeps this repo up to date automatically.

## What runs automatically

There is no cron job. Two systemd user timers run on `unicorn`:

| Timer | Schedule | Action |
|---|---|---|
| `config-sync.timer` | 5 min after boot, and daily (up to 10 min random delay; a missed run starts at the next boot) | Runs `dotfiles/sync.sh` to commit and push this repo |
| `claude-usage.timer` | Mondays 10:00 | Runs `~/claude-usage/usage_backup.py` to back up Claude Code token usage to GitHub. The script is outside this repo. |

`dotfiles/sync.sh` does these steps in order:

1. Save the installed package lists to `dotfiles/packages/pacman.txt` and `aur.txt`.
2. Stage all changes (`git add -A`).
3. Scan the staged changes with `gitleaks`.
4. Commit with the message `auto-sync unicorn <date time>`. This message shows which machine made the commit.
5. Push to `origin main`. If the laptop is offline, the commit waits and goes out on the next run.

If `gitleaks` is missing or finds a possible secret, the script commits nothing, unstages the changes and shows a critical desktop notification. To fix it, remove the secret or add its fingerprint to `.gitleaksignore`.

To see the timers: `systemctl --user list-timers`.

## Restore on a new laptop

1. Install Arch and log in as your user.
2. Create an SSH key and add it to GitHub:
   ```sh
   ssh-keygen -t ed25519 && cat ~/.ssh/id_ed25519.pub   # paste at github.com/settings/keys
   ```
3. Fetch and run the bootstrap script:
   ```sh
   sudo pacman -S --needed git openssh
   git clone git@github.com:GregMRR/dots.git /tmp/dots && bash /tmp/dots/dotfiles/bootstrap.sh
   ```
   The script installs the config into `~/.config`, installs yay plus every pacman/AUR package, and enables the sync timer.

## Day to day

- Sync now: `systemctl --user start config-sync` (logs: `journalctl --user -u config-sync`)
- Track a new app: add `!/appname/` to `.gitignore`.
- Only the folders listed in `.gitignore` are tracked. App caches, browser profiles and account data (Slack, Discord, Firefox, Nextcloud…) are left out on purpose.
