#!/usr/bin/env sh
set -e

# --- Resolve Dotfiles Directory ---
# Resolves symlinks and handles execution from any working directory
SCRIPT_SOURCE="$0"
case "$SCRIPT_SOURCE" in
    \~/*) SCRIPT_SOURCE="$HOME/${SCRIPT_SOURCE#\~/}" ;;
esac
while [ -h "$SCRIPT_SOURCE" ]; do
    SCRIPT_DIR="$(cd -P "$(dirname "$SCRIPT_SOURCE")" >/dev/null 2>&1 && pwd)"
    SCRIPT_SOURCE="$(readlink "$SCRIPT_SOURCE")"
    case "$SCRIPT_SOURCE" in
        /*) ;;
        *) SCRIPT_SOURCE="$SCRIPT_DIR/$SCRIPT_SOURCE" ;;
    esac
done
DOTFILES_DIR="$(cd -P "$(dirname "$SCRIPT_SOURCE")" >/dev/null 2>&1 && pwd)"


# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

info() { printf "${BLUE}[INFO]${NC}  %s\n" "$1"; }
step() { printf "\n${CYAN}${BOLD}[STEP]${NC} %s\n" "$1"; }
success() { printf "${GREEN}[OK]${NC}    %s\n" "$1"; }
warn() { printf "${YELLOW}[WARN]${NC}  %s\n" "$1"; }
error() { printf "${RED}[ERR]${NC}   %s\n" "$1"; }

info "Resolved dotfiles repository root: $DOTFILES_DIR"

# --- Configure System Locale ---
step "1. Configuring system locale..."
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

info "Generating en_US.UTF-8 locale..."
if [ -f /etc/locale.gen ]; then
    if grep -q "^# *en_US.UTF-8 UTF-8" /etc/locale.gen 2>/dev/null; then
        sudo sed -i 's/^# *en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen 2>/dev/null || true
    fi
fi

if command -v locale-gen >/dev/null 2>&1; then
    sudo locale-gen en_US.UTF-8 || sudo locale-gen || true
elif [ -x /usr/sbin/locale-gen ]; then
    sudo /usr/sbin/locale-gen en_US.UTF-8 || sudo /usr/sbin/locale-gen || true
elif command -v localectl >/dev/null 2>&1; then
    sudo localectl set-locale LANG=en_US.UTF-8 || true
fi
success "Locale generated and set: LANG=$LANG LC_ALL=$LC_ALL"

# --- Detect Package Manager ---
step "2. Detecting operating system and package manager..."
if command -v apt-get >/dev/null 2>&1; then
    PKG_MAN="apt"
    info "Found 'apt-get'. Selected package manager: Debian/Ubuntu (apt)"
elif command -v pacman >/dev/null 2>&1; then
    PKG_MAN="pacman"
    info "Found 'pacman'. Selected package manager: Arch Linux (pacman)"
elif command -v dnf >/dev/null 2>&1; then
    PKG_MAN="dnf"
    info "Found 'dnf'. Selected package manager: Fedora/RHEL (dnf)"
else
    PKG_MAN="unknown"
    warn "No recognized package manager (apt, pacman, dnf) detected."
fi

# --- Install Base System & Server Packages ---
step "3. Installing core CLI & server dependencies..."
case $PKG_MAN in
    apt)
        info "Running: sudo apt-get update..."
        sudo apt-get update
        info "Installing core packages (locales, zsh, vim, tmux, git, curl, wget, ripgrep, fd-find, htop, build-essential, ufw, fail2ban, python3-venv, python3-pip)..."
        sudo apt-get install -y locales zsh vim tmux git curl wget ripgrep fd-find htop build-essential \
            ufw fail2ban python3-venv python3-pip
        success "Core dependencies successfully installed via apt."
        ;;
    pacman)
        info "Synchronizing pacman package databases..."
        sudo pacman -Sy --noconfirm
        info "Installing core packages (zsh, vim, tmux, git, curl, wget, ripgrep, fd, htop, base-devel, ufw, fail2ban, python)..."
        sudo pacman -S --noconfirm --needed zsh vim tmux git curl wget ripgrep fd htop base-devel \
            ufw fail2ban python
        success "Core dependencies successfully installed via pacman."
        ;;
    dnf)
        info "Installing core packages (zsh, vim, tmux, git, curl, wget, ripgrep, fd-find, htop, ufw, fail2ban, python3)..."
        sudo dnf install -y zsh vim tmux git curl wget ripgrep fd-find htop \
            ufw fail2ban python3
        success "Core dependencies successfully installed via dnf."
        ;;
    *)
        error "Package manager not recognized. Please install base packages manually."
        ;;
esac

# --- Optional Full Distribution Package List Installation ---
step "4. Optional full distribution package list installation..."
info "Checking for available distribution package lists in $DOTFILES_DIR/pkglist..."

PKGLIST_DIR="$DOTFILES_DIR/pkglist"
if [ -d "$PKGLIST_DIR" ]; then
    # Detect suggested default pkglist
    DEFAULT_PKGLIST=""
    if [ -f /etc/os-release ]; then
        OS_ID="$(. /etc/os-release && echo "$ID" | tr '[:upper:]' '[:lower:]')"
        case "$OS_ID" in
            *arch*)   DEFAULT_PKGLIST="arch" ;;
            *ubuntu*) DEFAULT_PKGLIST="ubuntu" ;;
            *debian*) DEFAULT_PKGLIST="debian" ;;
            *fedora*|*rhel*|*centos*) DEFAULT_PKGLIST="fedora" ;;
        esac
    fi
    if [ -z "$DEFAULT_PKGLIST" ]; then
        case "$PKG_MAN" in
            pacman) DEFAULT_PKGLIST="arch" ;;
            apt)    DEFAULT_PKGLIST="debian" ;;
            dnf)    DEFAULT_PKGLIST="fedora" ;;
        esac
    fi

    printf "\nDo you want to install all your packages from a distribution pkglist? [y/N]: "
    read -r install_all_choice
    if echo "$install_all_choice" | grep -iq "^y"; then
        info "Available distribution package lists in $PKGLIST_DIR:"
        pkglist_idx=1
        pkglist_files=""
        for f in "$PKGLIST_DIR"/*.txt; do
            if [ -f "$f" ]; then
                base="$(basename "$f" .txt)"
                if [ "$base" = "$DEFAULT_PKGLIST" ]; then
                    printf "  %d) %s (%s) [detected OS recommendation]\n" "$pkglist_idx" "$base" "$f"
                else
                    printf "  %d) %s (%s)\n" "$pkglist_idx" "$base" "$f"
                fi
                pkglist_files="$pkglist_files $f"
                pkglist_idx=$((pkglist_idx + 1))
            fi
        done

        if [ -n "$DEFAULT_PKGLIST" ]; then
            printf "Which pkglist do you want to install? [1-%d / name, default: %s]: " "$((pkglist_idx - 1))" "$DEFAULT_PKGLIST"
        else
            printf "Which pkglist do you want to install? [1-%d / name]: " "$((pkglist_idx - 1))"
        fi
        read -r chosen_input
        chosen_input="$(echo "$chosen_input" | tr -d '[:space:]')"

        if [ -z "$chosen_input" ] && [ -n "$DEFAULT_PKGLIST" ]; then
            chosen_input="$DEFAULT_PKGLIST"
        fi

        CHOSEN_FILE=""
        case "$chosen_input" in
            ''|*[!0-9]*)
                if [ -f "$PKGLIST_DIR/${chosen_input}.txt" ]; then
                    CHOSEN_FILE="$PKGLIST_DIR/${chosen_input}.txt"
                elif [ -f "$PKGLIST_DIR/${chosen_input}" ]; then
                    CHOSEN_FILE="$PKGLIST_DIR/${chosen_input}"
                fi
                ;;
            *)
                curr_idx=1
                for f in "$PKGLIST_DIR"/*.txt; do
                    if [ -f "$f" ]; then
                        if [ "$curr_idx" -eq "$chosen_input" ]; then
                            CHOSEN_FILE="$f"
                            break
                        fi
                        curr_idx=$((curr_idx + 1))
                    fi
                done
                ;;
        esac

        if [ -n "$CHOSEN_FILE" ] && [ -f "$CHOSEN_FILE" ]; then
            pkg_count="$(grep -vE '^\s*#|^\s*$' "$CHOSEN_FILE" | wc -l | tr -d ' ')"
            info "Selected package list: $CHOSEN_FILE ($pkg_count packages listed)"
            info "Installing packages using package manager: $PKG_MAN..."

            case "$PKG_MAN" in
                apt)
                    info "Installing packages via apt-get..."
                    pkgs_to_install="$(grep -vE '^\s*#|^\s*$' "$CHOSEN_FILE" | tr '\n' ' ')"
                    sudo apt-get install -y $pkgs_to_install
                    success "Package list ($CHOSEN_FILE) installed successfully via apt."
                    ;;
                pacman)
                    info "Installing packages via pacman..."
                    sudo pacman -S --noconfirm --needed $(grep -vE '^\s*#|^\s*$' "$CHOSEN_FILE")
                    success "Package list ($CHOSEN_FILE) installed successfully via pacman."
                    ;;
                dnf)
                    info "Installing packages via dnf..."
                    pkgs_to_install="$(grep -vE '^\s*#|^\s*$' "$CHOSEN_FILE" | tr '\n' ' ')"
                    sudo dnf install -y $pkgs_to_install
                    success "Package list ($CHOSEN_FILE) installed successfully via dnf."
                    ;;
                *)
                    warn "Unrecognized package manager '$PKG_MAN'. Cannot automatically batch install."
                    info "Package list file is located at: $CHOSEN_FILE"
                    ;;
            esac
        else
            warn "Invalid pkglist selection '$chosen_input'. Skipping package list installation."
        fi
    else
        info "Skipping full package list installation as requested."
    fi
else
    warn "Directory $PKGLIST_DIR not found. Skipping package list installation."
fi

# --- Change Default Shell to Zsh ---
step "5. Configuring default login shell..."
ZSH_BIN="$(command -v zsh || true)"
info "Current user: $USER"
info "Current shell: $SHELL"
info "Zsh location: ${ZSH_BIN:-not found}"

if [ -z "$ZSH_BIN" ]; then
    warn "Zsh binary not found in PATH. Skipping shell modification."
elif [ "$SHELL" = "$ZSH_BIN" ]; then
    info "Default shell is already Zsh ($SHELL). Skipping change."
else
    info "Changing default shell for $USER to $ZSH_BIN..."
    if chsh -s "$ZSH_BIN" "$USER"; then
        success "Default shell successfully changed to $ZSH_BIN."
    else
        warn "Failed to change shell with chsh. You can run 'chsh -s $ZSH_BIN' manually."
    fi
fi

# --- Install Oh My Zsh ---
step "6. Setting up Oh My Zsh..."
if [ -d "$HOME/.oh-my-zsh" ]; then
    info "Oh My Zsh is already installed at $HOME/.oh-my-zsh. Skipping."
else
    info "Oh My Zsh not found. Downloading and running installer from raw.githubusercontent.com..."
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    success "Oh My Zsh installed successfully at $HOME/.oh-my-zsh."
fi

# --- Install NVM & Node LTS ---
step "7. Setting up NVM (Node Version Manager) & Node.js LTS..."
export NVM_DIR="$HOME/.nvm"
if [ -d "$NVM_DIR" ]; then
    info "NVM directory already exists at $NVM_DIR."
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    if command -v node >/dev/null 2>&1; then
        info "Node is already available: $(node -v) (npm $(npm -v 2>/dev/null || echo 'N/A'))"
    else
        info "Loading NVM and installing Node.js LTS..."
        nvm install --lts
        nvm use --lts
        success "Node.js LTS installed: $(node -v)"
    fi
else
    info "NVM not found. Downloading installer from nvm-sh/nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    info "Loading NVM environment from $NVM_DIR/nvm.sh..."
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    info "Installing Node.js LTS release..."
    nvm install --lts
    nvm use --lts
    success "NVM and Node.js LTS installed: $(node -v 2>/dev/null || echo 'done')"
fi

# --- Install PNPM ---
step "8. Setting up PNPM package manager..."
if command -v pnpm >/dev/null 2>&1; then
    info "PNPM is already installed at $(command -v pnpm) (version: $(pnpm -v 2>/dev/null || echo 'unknown')). Skipping."
else
    info "PNPM not found in PATH. Downloading and installing via https://get.pnpm.io/install.sh..."
    curl -fsSL https://get.pnpm.io/install.sh | sh -
    success "PNPM installed successfully."
fi

# --- Auto-Install NERDTree for Vim ---
step "9. Setting up NERDTree plugin for Vim..."
NERDTREE_DIR="$HOME/.vim/pack/vendor/start/nerdtree"
if [ -d "$NERDTREE_DIR" ]; then
    info "NERDTree plugin already present at $NERDTREE_DIR. Skipping clone."
else
    info "Creating Vim pack directory: $HOME/.vim/pack/vendor/start"
    mkdir -p "$HOME/.vim/pack/vendor/start"
    info "Cloning preservim/nerdtree into $NERDTREE_DIR..."
    git clone https://github.com/preservim/nerdtree.git "$NERDTREE_DIR"
    success "NERDTree cloned successfully."
fi

# --- Create Symlinks ---
step "10. Symlinking configuration files..."
info "Config source directory: $DOTFILES_DIR"

# Ensure config directories are real directories, not stale directory symlinks
for cfg_dir in "$HOME/.config/openbox" "$HOME/.config/tint2" "$HOME/.config/picom"; do
    if [ -L "$cfg_dir" ] || [ -h "$cfg_dir" ]; then
        warn "Removing directory symlink at $cfg_dir..."
        rm -f "$cfg_dir"
    fi
done

link_file() {
    src="$1"
    dst="$2"
    info "Linking target: $dst"
    if [ ! -e "$src" ] && [ ! -L "$src" ]; then
        warn "Source path does not exist: $src. Skipping."
        return 0
    fi

    # Check if dst is already a symlink (including broken symlinks or relocated paths)
    if [ -L "$dst" ] || [ -h "$dst" ]; then
        target="$(readlink "$dst" || true)"
        if [ "$target" != "$src" ] || [ ! -e "$dst" ]; then
            if [ ! -e "$dst" ]; then
                warn "Symlink $dst is broken (target: $target). Removing stale symlink..."
            else
                info "Symlink $dst points to relocated/outdated path ($target). Removing stale symlink..."
            fi
            rm -f "$dst"
        else
            info "Symlink $dst already points to $src. Refreshing..."
            rm -f "$dst"
        fi
    elif [ -e "$dst" ]; then
        info "Existing file or directory found at $dst. Backing up to ${dst}.backup"
        mv "$dst" "${dst}.backup"
        success "Backup created: ${dst}.backup"
    fi

    mkdir -p "$(dirname "$dst")"
    ln -sfn "$src" "$dst"
    success "Linked: $src -> $dst"
}

# Link Zsh & Theme
info "Configuring Zsh dotfiles..."
link_file "$DOTFILES_DIR/zsh/zshrc" "$HOME/.zshrc"
if [ -f "$DOTFILES_DIR/zsh/seahorse.zsh-theme" ]; then
    link_file "$DOTFILES_DIR/zsh/seahorse.zsh-theme" "$HOME/.oh-my-zsh/custom/themes/seahorse.zsh-theme"
else
    info "Custom theme $DOTFILES_DIR/zsh/seahorse.zsh-theme not found. Skipping."
fi

# Link Vim Configuration
info "Configuring Vim dotfiles..."
if [ -f "$DOTFILES_DIR/vim/vimrc" ]; then
    link_file "$DOTFILES_DIR/vim/vimrc" "$HOME/.vimrc"
else
    info "Vim config $DOTFILES_DIR/vim/vimrc not found. Skipping."
fi

# Link Openbox Configuration
info "Configuring Openbox window manager..."
mkdir -p "$HOME/.config/openbox"
if [ -d "$DOTFILES_DIR/openbox" ]; then
    for ob_cfg in autostart rc.xml menu.xml environment; do
        if [ -f "$DOTFILES_DIR/openbox/$ob_cfg" ]; then
            if [ "$ob_cfg" = "autostart" ]; then
                chmod +x "$DOTFILES_DIR/openbox/$ob_cfg"
            fi
            link_file "$DOTFILES_DIR/openbox/$ob_cfg" "$HOME/.config/openbox/$ob_cfg"
        fi
    done
    # Link any other configs present in openbox directory
    for ob_file in "$DOTFILES_DIR/openbox"/*; do
        if [ -f "$ob_file" ]; then
            ob_name="$(basename "$ob_file")"
            case "$ob_name" in
                autostart|rc.xml|menu.xml|environment) ;;
                *) link_file "$ob_file" "$HOME/.config/openbox/$ob_name" ;;
            esac
        fi
    done
    success "Openbox configuration files linked to $HOME/.config/openbox."
else
    info "Openbox directory $DOTFILES_DIR/openbox not found. Skipping."
fi

# Link Tint2 Configuration
info "Configuring Tint2 panel..."
mkdir -p "$HOME/.config/tint2"
if [ -f "$DOTFILES_DIR/tint2/tint2rc" ]; then
    link_file "$DOTFILES_DIR/tint2/tint2rc" "$HOME/.config/tint2/tint2rc"
else
    info "Tint2 config $DOTFILES_DIR/tint2/tint2rc not found. Skipping."
fi

# Link Picom (Modern Compton replacement)
info "Configuring Picom compositor..."
mkdir -p "$HOME/.config/picom"
if [ -f "$DOTFILES_DIR/picom/picom.conf" ]; then
    link_file "$DOTFILES_DIR/picom/picom.conf" "$HOME/.config/picom/picom.conf"
else
    info "Picom config $DOTFILES_DIR/picom/picom.conf not found. Skipping."
fi

# Link Executable Bin Scripts
step "11. Linking executable bin scripts..."
if [ -d "$DOTFILES_DIR/scripts/bin" ]; then
    info "Found bin scripts directory at $DOTFILES_DIR/scripts/bin"
    info "Ensuring $HOME/.local/bin exists..."
    mkdir -p "$HOME/.local/bin"

    # Remove broken or orphaned symlinks in ~/.local/bin pointing to stale dotfiles paths
    for link in "$HOME/.local/bin"/*; do
        if [ -L "$link" ] || [ -h "$link" ]; then
            if [ ! -e "$link" ]; then
                link_target="$(readlink "$link" || true)"
                warn "Removing orphaned/broken symlink in ~/.local/bin: $link (pointed to: $link_target)"
                rm -f "$link"
            fi
        fi
    done

    for script in "$DOTFILES_DIR/scripts/bin"/*; do
        if [ -f "$script" ]; then
            script_name="$(basename "$script")"
            info "Processing script: $script_name"
            info "Setting executable permissions (+x) on $script"
            chmod +x "$script"
            link_file "$script" "$HOME/.local/bin/$script_name"
        fi
    done
    success "All scripts in $DOTFILES_DIR/scripts/bin linked to $HOME/.local/bin."
else
    info "No scripts/bin directory found at $DOTFILES_DIR/scripts/bin. Skipping."
fi

# Create default Python virtual environments folder
step "12. Initializing Python virtual environments directory..."
if [ -d "$HOME/.venvs" ]; then
    info "Virtual environments directory $HOME/.venvs already exists."
else
    info "Creating directory: $HOME/.venvs"
    mkdir -p "$HOME/.venvs"
    success "Created $HOME/.venvs."
fi

# Append to the bottom of install.sh
step "13. Optional Server Hardening..."
printf "\nDo you want to configure UFW and Fail2Ban security now? [y/N]: "
read -r response
if echo "$response" | grep -iq "^y"; then
    info "User opted in. Launching $DOTFILES_DIR/setup-server.sh..."
    "$DOTFILES_DIR/setup-server.sh"
    success "Server setup script completed."
else
    info "Skipping server security hardening."
fi

printf "\n"
success "============================================================"
success " One-and-Done VPS Setup Complete!"
success " All packages, dotfiles, plugins, and bins are configured."
success " Restart your terminal session or run 'zsh' to load changes."
success "============================================================"
