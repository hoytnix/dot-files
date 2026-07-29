#!/usr/bin/env sh
set -e

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info() { printf "${BLUE}[INFO]${NC} %s\n" "$1"; }
success() { printf "${GREEN}[SUCCESS]${NC} %s\n" "$1"; }
error() { printf "${RED}[ERROR]${NC} %s\n" "$1"; }

# --- Detect Package Manager ---
info "Detecting OS and package manager..."
if command -v apt-get >/dev/null 2>&1; then
    PKG_MAN="apt"
elif command -v pacman >/dev/null 2>&1; then
    PKG_MAN="pacman"
elif command -v dnf >/dev/null 2>&1; then
    PKG_MAN="dnf"
else
    PKG_MAN="unknown"
fi

# --- Install Base System & Server Packages ---
info "Installing core CLI & server dependencies..."
case $PKG_MAN in
    apt)
        sudo apt-get update -qq
        sudo apt-get install -y -qq zsh vim tmux git curl wget ripgrep fd-find htop build-essential \
            nginx ufw fail2ban python3-venv python3-pip
        ;;
    pacman)
        sudo pacman -Sy --noconfirm zsh vim tmux git curl wget ripgrep fd htop base-devel \
            nginx ufw fail2ban python
        ;;
    dnf)
        sudo dnf install -y -q zsh vim tmux git curl wget ripgrep fd-find htop \
            nginx ufw fail2ban python3
        ;;
    *)
        error "Package manager not recognized. Please install base packages manually."
        ;;
esac

# --- Change Default Shell to Zsh ---
if [ "$SHELL" != "$(which zsh)" ]; then
    info "Changing default shell to Zsh..."
    chsh -s "$(which zsh)" "$USER" || true
fi

# --- Install Oh My Zsh ---
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    info "Installing Oh My Zsh..."
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# --- Install NVM & Node LTS ---
if [ ! -d "$HOME/.nvm" ]; then
    info "Installing NVM and Node.js LTS..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install --lts
    nvm use --lts
fi

# --- Install PNPM ---
if ! command -v pnpm >/dev/null 2>&1; then
    info "Installing PNPM..."
    curl -fsSL https://get.pnpm.io/install.sh | sh -
fi

# --- Auto-Install NERDTree for Vim ---
if [ ! -d "$HOME/.vim/pack/vendor/start/nerdtree" ]; then
    info "Installing NERDTree plugin for Vim..."
    mkdir -p "$HOME/.vim/pack/vendor/start"
    git clone https://github.com/preservim/nerdtree.git "$HOME/.vim/pack/vendor/start/nerdtree"
fi

# --- Create Symlinks ---
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
info "Symlinking configuration files from $DOTFILES_DIR..."

link_file() {
    src="$1"
    dst="$2"
    if [ -f "$dst" ] || [ -d "$dst" ]; then
        if [ ! -L "$dst" ]; then
            info "Backing up existing $dst to ${dst}.backup"
            mv "$dst" "${dst}.backup"
        fi
    fi
    mkdir -p "$(dirname "$dst")"
    ln -sfn "$src" "$dst"
    success "Linked $src -> $dst"
}

# Link Zsh & Theme
link_file "$DOTFILES_DIR/zsh/zshrc" "$HOME/.zshrc"
if [ -f "$DOTFILES_DIR/zsh/seahorse.zsh-theme" ]; then
    link_file "$DOTFILES_DIR/zsh/seahorse.zsh-theme" "$HOME/.oh-my-zsh/custom/themes/seahorse.zsh-theme"
fi

# Link Vim Configuration
if [ -f "$DOTFILES_DIR/vim/vimrc" ]; then
    link_file "$DOTFILES_DIR/vim/vimrc" "$HOME/.vimrc"
fi

# Link Picom (Modern Compton replacement)
if [ -f "$DOTFILES_DIR/picom/picom.conf" ]; then
    link_file "$DOTFILES_DIR/picom/picom.conf" "$HOME/.config/picom/picom.conf"
fi

# Link Executable Bin Scripts
if [ -d "$DOTFILES_DIR/scripts/bin" ]; then
    mkdir -p "$HOME/.local/bin"
    for script in "$DOTFILES_DIR/scripts/bin"/*; do
        [ -f "$script" ] && link_file "$script" "$HOME/.local/bin/$(basename "$script")"
    done
fi

# Create default Python virtual environments folder
mkdir -p "$HOME/.venvs"

success "One-and-Done VPS Setup Complete! Restart your terminal session or run 'zsh' to load your environment."
