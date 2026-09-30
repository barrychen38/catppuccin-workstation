#!/usr/bin/env bash
# Catppuccin Workstation — one-line installer.
#
#   git clone https://github.com/barrychen38/catppuccin-workstation && ./catppuccin-workstation/install.sh
#
# or directly:
#
#   curl -fsSL https://raw.githubusercontent.com/barrychen38/catppuccin-workstation/main/install.sh | bash
#
set -euo pipefail

REPO_URL="https://github.com/barrychen38/catppuccin-workstation"
CLONE_DIR="$HOME/.catppuccin-workstation"
NO_BREW=0
[[ "${1:-}" == "--no-brew" ]] && NO_BREW=1

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mWarning:\033[0m %s\n' "$*"; }

# --- 0. Platform check -----------------------------------------------------
if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This setup targets macOS only (lazygit/ghostty paths, osxkeychain). Aborting." >&2
  exit 1
fi

# --- 1. Locate the repo ----------------------------------------------------
# When piped from curl, this script runs without the repo next to it:
# clone to ~/.catppuccin-workstation and re-exec from there.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ ! -d "$SCRIPT_DIR/config" ]]; then
  info "Fetching the repository..."
  if [[ -d "$CLONE_DIR/.git" ]]; then
    git -C "$CLONE_DIR" pull --ff-only
  else
    rm -rf "$CLONE_DIR"
    git clone --depth 1 "$REPO_URL" "$CLONE_DIR"
  fi
  exec bash "$CLONE_DIR/install.sh" "${1:-}"
fi
REPO_DIR="$SCRIPT_DIR"

# --- 2. Dependencies via Homebrew -------------------------------------------
if [[ $NO_BREW -eq 1 ]]; then
  info "Skipping Homebrew dependencies (--no-brew)"
else
  if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew is not installed. Visit https://brew.sh first, or rerun with --no-brew." >&2
    exit 1
  fi
  info "Installing dependencies (this can take a while on first run)..."
  brew bundle install --file="$REPO_DIR/Brewfile"
fi

# --- 3. Back up existing configs --------------------------------------------
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"
backup() {
  if [[ -e "$1" ]]; then
    mkdir -p "$BACKUP_DIR/$(dirname "${1#"$HOME"/}")"
    mv "$1" "$BACKUP_DIR/${1#"$HOME"/}"
  fi
}

# --- 4. Install configs ------------------------------------------------------
info "Installing Ghostty config..."
backup "$HOME/.config/ghostty/config"
mkdir -p "$HOME/.config/ghostty"
cp "$REPO_DIR/config/ghostty/config" "$HOME/.config/ghostty/config"
# Ghostty on macOS may also read the Application Support config; keep a single
# source of truth in ~/.config.
if ls "$HOME/Library/Application Support/com.mitchellh.ghostty/"config* >/dev/null 2>&1; then
  info "Moving Ghostty's Application Support config aside (backed up)..."
  while IFS= read -r f; do
    backup "$f"
  done < <(ls "$HOME/Library/Application Support/com.mitchellh.ghostty/"config* 2>/dev/null)
fi

info "Installing Source Han Sans SC font..."
if [[ ! -e "$HOME/Library/Fonts/SourceHanSansSC-VF.ttf" ]]; then
  mkdir -p "$HOME/Library/Fonts"
  cp "$REPO_DIR/fonts/SourceHanSansSC-VF.ttf" "$HOME/Library/Fonts/"
fi

info "Installing zsh, starship, bat, git, yazi, herdr configs..."
for item in \
  ".zshrc:config/zsh/zshrc" \
  ".config/starship.toml:config/starship.toml" \
  ".config/bat/config:config/bat/config" \
  ".config/git/catppuccin.gitconfig:config/git/catppuccin.gitconfig" \
  ".config/git/ignore:config/git/ignore" \
  ".config/yazi/yazi.toml:config/yazi/yazi.toml" \
  ".config/yazi/keymap.toml:config/yazi/keymap.toml" \
  ".config/yazi/theme.toml:config/yazi/theme.toml" \
  ".config/yazi/package.toml:config/yazi/package.toml" \
  ".config/herdr/config.toml:config/herdr/config.toml"; do
  target="$HOME/${item%%:*}"
  source="$REPO_DIR/${item##*:}"
  backup "$target"
  mkdir -p "$(dirname "$target")"
  cp "$source" "$target"
done

# yazi flavor (directory)
if [[ -d "$HOME/.config/yazi/flavors" ]]; then
  mkdir -p "$BACKUP_DIR/.config/yazi"
  mv "$HOME/.config/yazi/flavors" "$BACKUP_DIR/.config/yazi/flavors"
fi
mkdir -p "$HOME/.config/yazi"
cp -R "$REPO_DIR/config/yazi/flavors" "$HOME/.config/yazi/flavors"

info "Installing gitconfig..."
backup "$HOME/.gitconfig"
cp "$REPO_DIR/config/git/gitconfig" "$HOME/.gitconfig"

info "Installing lazygit config..."
backup "$HOME/Library/Application Support/lazygit/config.yml"
mkdir -p "$HOME/Library/Application Support/lazygit"
cp "$REPO_DIR/config/lazygit/config.yml" "$HOME/Library/Application Support/lazygit/config.yml"

info "Installing Neovim config (LazyVim)..."
backup "$HOME/.config/nvim"
mkdir -p "$HOME/.config"
cp -R "$REPO_DIR/config/nvim" "$HOME/.config/nvim"

# --- 5. bat themes -----------------------------------------------------------
info "Installing Catppuccin themes for bat..."
if command -v bat >/dev/null 2>&1; then
  bash "$REPO_DIR/scripts/bat-themes.sh"
else
  warn "bat not found; run scripts/bat-themes.sh after dependencies are installed."
fi

# --- 6. Local zsh overrides ---------------------------------------------------
if [[ ! -e "$HOME/.zshrc.local" ]]; then
  cp "$REPO_DIR/config/zsh/zshrc.local.example" "$HOME/.zshrc.local"
  info "Created ~/.zshrc.local (add your secrets/proxy/work aliases there)"
fi

# --- 7. Neovim bootstrap -------------------------------------------------------
info "Bootstrapping Neovim plugins (headless)..."
if command -v nvim >/dev/null 2>&1; then
  nvim --headless "+Lazy! sync" +qa >/dev/null 2>&1 || warn "Neovim plugin sync failed; it will retry on first launch."
else
  warn "nvim not found; plugins will install on first launch."
fi

# --- 8. Done -------------------------------------------------------------------
cat <<'EOF'

Done. Next steps:

  1. Set your git identity (the installed file has placeholders):
       git config --global user.name  "Your Name"
       git config --global user.email "you@example.com"
  2. Optional — Herdr (terminal workspace for AI agents), config already installed:
       see https://herdr.dev for the installer
  3. Restart your terminal (or open a new Ghostty window).

Existing configs were backed up under:
EOF
echo "  $BACKUP_DIR"
