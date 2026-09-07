# Dotfiles & VPS / Workstation Setup

A streamlined, modular dotfiles and environment provisioning suite for Linux VPS servers and desktop workstations.

Includes automated one-step bootstrapping, OS package detection (`apt`, `pacman`, `dnf`), server security hardening (UFW, Fail2Ban, Nginx), modern developer tooling (Zsh, NVM, PNPM, Vim, tmux), and Openbox window management with Vim keybindings.

---

## Features

- **Automated Installation**: Single script detects package managers (`apt`, `pacman`, `dnf`), installs core utilities, sets up shell, and creates configuration symlinks.
- **Server Hardening**: Automatic SSH port detection, UFW firewall rules, Fail2Ban jails for SSH & Nginx abuse, and Nginx rate-limiting zones.
- **Developer Stack**: Pre-configured [Zsh](https://www.zsh.org/) with Oh My Zsh and custom `seahorse` theme, [NVM](https://github.com/nvm-sh/nvm) + Node.js LTS, [PNPM](https://pnpm.io/), and Python virtual environment helpers.
- **Vim Config**: Lightweight Vim setup with NERDTree, hybrid relative line numbers, search highlighting, and custom leader shortcuts.
- **Workstation & WM**: [Openbox](http://openbox.org/) window manager with Vim-style movement/focusing/resizing, [Picom](https://github.com/yshui/picom) compositor, and screenshot shortcuts.

---

## Quick Start

Clone the repository and run the installer:

```bash
git clone https://github.com/hoytnix/dot-files.git ~/dot-files
cd ~/dot-files
chmod +x install.sh setup-server.sh
./install.sh
```

### What `install.sh` Does:

1. **Detects Package Manager**: Supports Debian/Ubuntu (`apt`), Arch Linux (`pacman`), and Fedora/RHEL (`dnf`).
2. **Installs Core Tools**: `zsh`, `vim`, `tmux`, `git`, `curl`, `wget`, `ripgrep`, `fd`, `htop`, build tools, `nginx`, `ufw`, `fail2ban`, and Python.
3. **Configures Shell**: Changes default shell to Zsh and installs [Oh My Zsh](https://ohmyz.sh/).
4. **Node & Package Tools**: Installs NVM, Node.js (LTS), and PNPM.
5. **Vim Setup**: Clones the NERDTree plugin to `~/.vim/pack/vendor/start/nerdtree`.
6. **Symlinks Configs**:
   - `zsh/zshrc` -> `~/.zshrc`
   - `zsh/seahorse.zsh-theme` -> `~/.oh-my-zsh/custom/themes/seahorse.zsh-theme`
   - `vim/vimrc` -> `~/.vimrc`
   - `picom/picom.conf` -> `~/.config/picom/picom.conf`
   - `scripts/bin/*` -> `~/.local/bin/*`
7. **Optional Hardening**: Prompts to execute `setup-server.sh`.

---

## Server Hardening (`setup-server.sh`)

To harden a VPS independently:

```bash
sudo ./setup-server.sh
```

### 1. UFW Firewall
- Default policy: **Deny incoming**, **Allow outgoing**.
- Auto-detects active SSH port (defaults to 22 if undetected) and permits SSH traffic.
- Allows HTTP (port 80) and HTTPS (port 443).

### 2. Fail2Ban Jails & Filters
- **SSH Protection**: Monitors SSH auth failures with ban duration of 1 hour.
- **Nginx Rate Limits (`nginx-req-limit`)**: Catches requests triggering Nginx rate-limiting zones; bans offender via UFW for 24 hours.
- **Nginx Malicious Scanners (`nginx-badbots`)**: Automatically bans requests probing for `.php`, `.asp`, `.env`, `.cgi`, etc., for 48 hours.

### 3. Nginx Rate Limits & Verbose Logging
- Defines `req_limit_per_ip` (10r/s) and `conn_limit_per_ip` zones in the `http` block of `/etc/nginx/nginx.conf`.
- Injects a `verbose_detailed` logging format tracking upstream connect and response times.

---

## Shell & Environment (Zsh)

Loaded from `zsh/zshrc` with Oh My Zsh:

### Aliases & Commands

| Alias / Command | Action |
|---|---|
| `s` | `sudo` shorthand |
| `ports` | `sudo netstat -tulanp` (view listening ports & sockets) |
| `myip` | Fetch public IP via `curl -s ifconfig.me` |
| `nginx-reload` | Validate Nginx config and reload service |
| `f2b-status` | `sudo fail2ban-client status` |
| `ufw-status` | `sudo ufw status verbose` |
| `apti` / `aptu` | `apt install -y` / `apt update && apt upgrade -y` |
| `pS` / `pSs` / `pSyu`| Pacman install, search, and system upgrade |

### Python Virtual Environment Helpers

- `venv <name>`: Activates `~/.venvs/<name>`
- `venvN <name>`: Creates a new virtual environment at `~/.venvs/<name>`, activates it, and updates `pip`.

---

## Vim Configuration

Configured in `vim/vimrc`:

- **Leader key**: `<Space>`
- **Escape shortcut**: `jk` in insert mode
- **Toggle NERDTree**: `<Space>n`
- **Line numbers**: Hybrid relative numbers (`number` + `relativenumber`)
- **Indentation**: 4 spaces (`expandtab`, `shiftwidth=4`, `tabstop=4`)
- **Color Column**: Boundary indicators at columns 78, 80, and 120

---

## Desktop & Window Management (Openbox)

For desktop/X11 installations using Openbox (`openbox/rc.xml`):

- **Openbox Menu**: `Super + Space`

### Window Navigation & Tiling (Vim Motions)

Uses Vim navigation keys (`j`, `k`, `l`, `;`):

- **Focus Window**: `Super + [jkl;]`
- **Move Window**: `Super + Shift + [jkl;]`
- **Tile Half-Screen**: `Super + Shift + Alt + [j/;]`
- **Tile Quarter-Screen**: `Super + Alt + [j/;]`

### Screenshot Shortcuts (Shutter)

Configured with `scripts/bin/screenshot_select`:

- `PrtSc`: Select screen portion
- `Alt + PrtSc`: Full screen capture
- `Ctrl + PrtSc`: Active window capture
- `Alt + Ctrl + PrtSc`: Interactive window selector

---

## Legacy Arch Package List & Sync

- `pkglist.txt`: Native Arch package snapshot (`pacman -Qqen > pkglist.txt`).
- `manage.py`: Python utility to compare file checksums between system configs and repository files, update `pkglist.txt`, and push changes to Git.

