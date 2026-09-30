# Catppuccin Workstation

[中文文档](README.zh-CN.md)

A macOS terminal workstation dressed in one theme — [Catppuccin Macchiato](https://catppuccin.com) — from the terminal emulator down to the file manager.

<!-- TODO: replace with a real terminal screenshot -->
![terminal](docs/screenshot.png)

## What's inside

| Layer | Tool | Notes |
| --- | --- | --- |
| Terminal | [Ghostty](https://ghostty.org) | Catppuccin Macchiato, subtle blur, hot reload on `cmd+shift+r` |
| Prompt | [starship](https://starship.rs) | Minimal format: directory, git branch, host (SSH only) |
| Shell | zsh + autosuggestions / syntax-highlighting / fzf-tab | No Oh My Zsh |
| CLI replacements | eza / bat / ripgrep / zoxide | `ls`, `cat`, `grep`, `cd` upgrades |
| Git | [delta](https://github.com/dandavison/delta) + [lazygit](https://github.com/jesseduffield/lazygit) | Themed diffs everywhere, lazygit renders diffs through delta |
| Editor | Neovim + [LazyVim](https://www.lazyvim.org) | Catppuccin colorscheme, plugin versions locked |
| Files | [yazi](https://github.com/sxyazi/yazi) | Catppuccin flavor, `y()` cds to the browsed directory on quit |
| Agent workspace | [Herdr](https://herdr.dev) | Config only; install the binary from herdr.dev |

Fonts: Maple Mono NF (installed via Homebrew) + Source Han Sans SC (vendored under `fonts/`, SIL OFL 1.1).

## Install

One line:

```bash
curl -fsSL https://raw.githubusercontent.com/barrychen38/catppuccin-workstation/main/install.sh | bash
```

Or clone and inspect first:

```bash
git clone https://github.com/barrychen38/catppuccin-workstation
cd catppuccin-workstation && ./install.sh
```

The installer:

1. Installs dependencies with Homebrew (`--no-brew` to skip)
2. Backs up your existing configs to `~/.dotfiles-backup/<timestamp>/`
3. Installs every config (Ghostty, zsh, starship, bat, git, lazygit, nvim, yazi, herdr) and the Source Han Sans font
4. Installs the Catppuccin themes for bat
5. Bootstraps Neovim plugins headlessly
6. Creates `~/.zshrc.local` for your secrets, proxy, and work aliases

After install: set your git identity (`git config --global user.name/email`) and open a new terminal window.

## What is deliberately not included

Secrets, proxy settings, and personal aliases never enter this repo. They belong in `~/.zshrc.local`, which the repo's `~/.zshrc` sources at the end. See `config/zsh/zshrc.local.example`.

## Rollback

Every install moves replaced files to `~/.dotfiles-backup/<timestamp>/`. To undo, copy them back.

## License

MIT for everything in this repository, except `fonts/SourceHanSansSC-VF.ttf` which is distributed under the SIL Open Font License 1.1 (see `fonts/OFL.txt`).
