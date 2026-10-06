# dots

`~/.config` for my Arch + Hyprland laptop. It's backed up automatically by `config-sync.timer`, which runs 5 min after boot and once a day. It commits any changes plus the installed package lists, then pushes. If the laptop is offline, the commits wait and go out on the next run.

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
