#!/usr/bin/env bash
# Catppuccin Workstation — incremental installer.
#
#   git clone https://github.com/barrychen38/catppuccin-workstation && ./catppuccin-workstation/install.sh
#
# or directly:
#
#   curl -fsSL https://raw.githubusercontent.com/barrychen38/catppuccin-workstation/main/install.sh | bash
#
# Everything is incremental: your ~/.zshrc and ~/.gitconfig keep their own
# content (we only append a managed block / set delta keys), and any file we
# fully own is backed up before being replaced.
set -euo pipefail

REPO_URL="https://github.com/barrychen38/catppuccin-workstation"
CLONE_DIR="$HOME/.catppuccin-workstation"
MANAGED="catppuccin-workstation"
ZSH_SNIPPET_DIR="$HOME/.config/$MANAGED"
NO_BREW=0
[[ "${1:-}" == "--no-brew" ]] && NO_BREW=1

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mWarning:\033[0m %s\n' "$*"; }

# --- 0. Platform check -------------------------------------------------------
if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This setup targets macOS only (lazygit/ghostty paths, osxkeychain). Aborting." >&2
  exit 1
fi

# --- 1. Locate the repo --------------------------------------------------------
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

# --- 2. Dependencies via Homebrew ----------------------------------------------
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

# --- 3. Backup helpers -----------------------------------------------------------
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
BACKED_UP=0

backup() {
  if [[ -e "$1" ]]; then
    mkdir -p "$BACKUP_DIR/$(dirname "${1#"$HOME"/}")"
    mv "$1" "$BACKUP_DIR/${1#"$HOME"/}"
    BACKED_UP=1
  fi
}

# Install a file we fully own: skip if identical, back up the old one if not.
install_owned_file() {
  local src=$1 dst=$2
  mkdir -p "$(dirname "$dst")"
  if [[ -e "$dst" ]] && diff -q "$src" "$dst" >/dev/null 2>&1; then
    return 0
  fi
  backup "$dst"
  cp "$src" "$dst"
}

install_owned_dir() {
  local src=$1 dst=$2
  mkdir -p "$(dirname "$dst")"
  if [[ -d "$dst" ]] && diff -rq "$src" "$dst" >/dev/null 2>&1; then
    return 0
  fi
  backup "$dst"
  cp -R "$src" "$dst"
}

# Replace (or insert) a managed block in a config file we do NOT own.
# Re-running always refreshes the block in place; the rest of the file is kept.
# $2 is either a file path or a literal string.
set_managed_block() {
  local file=$1 content=$2
  mkdir -p "$(dirname "$file")"
  touch "$file"
  local tmp
  tmp="$(mktemp)"
  awk '/^# >>> catppuccin-workstation >>>$/{f=1} !f{print} /^# <<< catppuccin-workstation <<<$/{f=0}' "$file" > "$tmp"
  {
    echo "# >>> $MANAGED >>>"
    if [[ -f "$content" ]]; then cat "$content"; else printf '%s\n' "$content"; fi
    echo "# <<< $MANAGED <<<"
  } >> "$tmp"
  mv "$tmp" "$file"
}

# --- 4. zsh: snippet + managed block in ~/.zshrc ---------------------------------
info "Installing zsh integrations (incremental, ~/.zshrc is kept)..."
install_owned_file "$REPO_DIR/config/zsh/zshrc" "$ZSH_SNIPPET_DIR/zshrc"
set_managed_block "$HOME/.zshrc" "source \"$ZSH_SNIPPET_DIR/zshrc\""

USER_SHELL="$(dscl . -read "$HOME" UserShell 2>/dev/null | awk '{print $2}' || true)"

# --- 5. Ghostty: managed block in the config --------------------------------------
info "Installing Ghostty settings (incremental)..."
set_managed_block "$HOME/.config/ghostty/config" "$REPO_DIR/config/ghostty/config"
# Keep a single source of truth: if the macOS Application Support config also
# exists, our ~/.config block comes after it only if sourced — instead, move it
# aside so ~/.config/ghostty/config is the only active file.
if ls "$HOME/Library/Application Support/com.mitchellh.ghostty/"config* >/dev/null 2>&1; then
  info "Moving Ghostty's Application Support config aside (backed up)..."
  while IFS= read -r f; do
    backup "$f"
  done < <(ls "$HOME/Library/Application Support/com.mitchellh.ghostty/"config* 2>/dev/null)
fi

# --- 6. Font -----------------------------------------------------------------------
info "Installing Source Han Sans SC font..."
if [[ ! -e "$HOME/Library/Fonts/SourceHanSansSC-VF.ttf" ]]; then
  mkdir -p "$HOME/Library/Fonts"
  cp "$REPO_DIR/fonts/SourceHanSansSC-VF.ttf" "$HOME/Library/Fonts/"
fi

# --- 7. starship / bat -------------------------------------------------------------
info "Installing starship config..."
install_owned_file "$REPO_DIR/config/starship.toml" "$HOME/.config/starship.toml"

info "Installing bat config (incremental)..."
BAT_CFG="$HOME/.config/bat/config"
mkdir -p "$(dirname "$BAT_CFG")"
touch "$BAT_CFG"
grep -q -- '--theme=' "$BAT_CFG" || echo '--theme="Catppuccin Macchiato"' >> "$BAT_CFG"
grep -q -- '--style=' "$BAT_CFG" || echo '--style="numbers,changes,header"' >> "$BAT_CFG"

# --- 8. git + delta (incremental via `git config`) ----------------------------------
info "Installing delta settings into ~/.gitconfig (incremental)..."
install_owned_file "$REPO_DIR/config/git/catppuccin.gitconfig" "$HOME/.config/git/catppuccin.gitconfig"
git config --global include.path "$HOME/.config/git/catppuccin.gitconfig"
git config --global core.pager delta
git config --global interactive.diffFilter 'delta --color-only'
git config --global delta.navigate true
git config --global delta.features catppuccin-macchiato
git config --global delta.line-numbers true
git config --global delta.decorations 'commit-style box'
git config --global delta.hide-plus-minus-markers false

# --- 9. lazygit ----------------------------------------------------------------------
info "Installing lazygit config..."
install_owned_file "$REPO_DIR/config/lazygit/config.yml" "$HOME/Library/Application Support/lazygit/config.yml"

# --- 10. Neovim (LazyVim) --------------------------------------------------------------
info "Installing Neovim config (LazyVim)..."
if [[ -d "$HOME/.config/nvim" ]] && ! diff -rq "$REPO_DIR/config/nvim" "$HOME/.config/nvim" >/dev/null 2>&1; then
  warn "An existing Neovim config differs; it will be backed up and replaced."
fi
install_owned_dir "$REPO_DIR/config/nvim" "$HOME/.config/nvim"

# --- 11. yazi (theme only) ---------------------------------------------------------------
info "Installing yazi theme..."
install_owned_file "$REPO_DIR/config/yazi/theme.toml" "$HOME/.config/yazi/theme.toml"
install_owned_file "$REPO_DIR/config/yazi/package.toml" "$HOME/.config/yazi/package.toml"
install_owned_dir "$REPO_DIR/config/yazi/flavors" "$HOME/.config/yazi/flavors"

# --- 12. bat themes ------------------------------------------------------------------------
info "Installing Catppuccin themes for bat..."
if command -v bat >/dev/null 2>&1; then
  bash "$REPO_DIR/scripts/bat-themes.sh"
else
  warn "bat not found; run scripts/bat-themes.sh after dependencies are installed."
fi

# --- 13. Neovim bootstrap ---------------------------------------------------------------------
info "Bootstrapping Neovim plugins (headless)..."
if command -v nvim >/dev/null 2>&1; then
  nvim --headless "+Lazy! sync" +qa >/dev/null 2>&1 || warn "Neovim plugin sync failed; it will retry on first launch."
else
  warn "nvim not found; plugins will install on first launch."
fi

# --- 14. Done -----------------------------------------------------------------------------------
cat <<'EOF'

Done. Next steps:

  1. Set your git identity (if you haven't already):
       git config --global user.name  "Your Name"
       git config --global user.email "you@example.com"
  2. Restart your terminal (or open a new Ghostty window).
EOF

if [[ "$USER_SHELL" != */zsh && -n "$USER_SHELL" ]]; then
  echo "  3. Your login shell is $USER_SHELL — these configs target zsh."
  echo "     Switch with: chsh -s /bin/zsh"
fi

if [[ $BACKED_UP -eq 1 ]]; then
  echo
  echo "Replaced files were backed up under:"
  echo "  $BACKUP_DIR"
fi
