# Catppuccin Workstation

[中文文档](README.zh-CN.md)

A macOS terminal workstation dressed in one theme — [Catppuccin Macchiato](https://catppuccin.com) — from the terminal emulator down to the file manager.

> Currently verified only on macOS and intended for those who prefer dark themes. Compatibility with other operating systems or light themes is not guaranteed.

![Catppuccin Macchiato in Ghostty: Neovim on the left, lazygit at the top right, and Starship with eza at the bottom right](docs/screenshot.png)

## What's inside

| Layer | Tool | Notes |
| --- | --- | --- |
| Terminal | [Ghostty](https://ghostty.org) | Catppuccin Macchiato, subtle blur, hot reload on `cmd+shift+r` |
| Prompt | [starship](https://starship.rs) | Minimal format: directory, git branch, host (SSH only) |
| Shell | zsh | [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting); only prompt and syntax highlighting initialization |
| CLI | [eza](https://github.com/eza-community/eza) / [bat](https://github.com/sharkdp/bat) / [ripgrep](https://github.com/BurntSushi/ripgrep) / [fzf](https://github.com/junegunn/fzf) | File display, themed highlighting, and editor search dependencies; no aliases |
| Git | [delta](https://github.com/dandavison/delta) + [lazygit](https://github.com/jesseduffield/lazygit) | Themed diffs everywhere; lazygit renders diffs through delta |
| Editor | [Neovim](https://neovim.io) + [LazyVim](https://www.lazyvim.org) | Stock LazyVim + the Catppuccin colorscheme |
| Files | [yazi](https://github.com/sxyazi/yazi) | Catppuccin flavor |

Fonts: [Maple Mono Normal NL NF](https://font.subf.dev/en/) (installed via Homebrew) + [Source Han Sans SC](https://github.com/adobe-fonts/source-han-sans) (vendored under `fonts/`, SIL OFL 1.1).

The repository provides theme configuration and the initialization it needs. Command aliases, completion, and directory navigation belong to your own shell configuration.

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

Everything is **incremental** — nothing of yours gets thrown away:

- `~/.zshrc` keeps its content; a small managed block is appended that sources our snippet from `~/.config/catppuccin-workstation/zshrc`
- `~/.gitconfig` keeps its content and existing includes; the theme include is added once and delta settings are merged in with `git config --global`
- Ghostty gets a managed block in its existing config; Application Support takes precedence over the XDG directory, and `config.ghostty` takes precedence over `config`. Existing files and settings are kept in place.
- bat config only gains the theme lines if missing
- Files we fully own (starship.toml, lazygit, nvim, yazi flavor) are backed up to `~/.dotfiles-backup/<timestamp>/` before being replaced
- The installer also installs dependencies via Homebrew (`--no-brew` to skip), the Source Han Sans font, Catppuccin themes for bat, and bootstraps Neovim plugins headlessly

The setup targets zsh (the macOS default). If your login shell is something else, the installer will tell you how to switch (`chsh -s /bin/zsh`).

## Optional productivity tools

These tools are not required by the theme, but can make everyday shell work faster. They are optional and are not installed or initialized by this repository's installer:

| Tool | Use |
| --- | --- |
| [fzf-tab](https://github.com/Aloxaf/fzf-tab) | Select zsh Tab-completion candidates with fzf |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Jump to frequently used directories with `z` |
| [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) | Suggest commands from shell history as you type |

Install them with Homebrew (`fzf` is required by fzf-tab and is already included in this repository's Brewfile):

```bash
brew install fzf fzf-tab zoxide zsh-autosuggestions
```

Installation alone does not enable their shell integrations. Follow the linked setup instructions in your own `~/.zshrc`. Load fzf-tab after `compinit` and before zsh-autosuggestions; keep this repository's managed block, which loads syntax highlighting, after those plugins. This repository does not manage these integrations or your command aliases.

## Tools & links

- Theme: [Catppuccin](https://catppuccin.com) · [catppuccin/delta](https://github.com/catppuccin/delta) · [catppuccin/bat](https://github.com/catppuccin/bat) · [catppuccin/yazi](https://github.com/catppuccin/yazi)
- Terminal: [Ghostty](https://ghostty.org)
- Prompt & shell: [starship](https://starship.rs) · [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
- CLI: [eza](https://github.com/eza-community/eza) · [bat](https://github.com/sharkdp/bat) · [ripgrep](https://github.com/BurntSushi/ripgrep) · [fzf](https://github.com/junegunn/fzf)
- Git: [git-delta](https://github.com/dandavison/delta) · [lazygit](https://github.com/jesseduffield/lazygit)
- Editor: [Neovim](https://neovim.io) · [LazyVim](https://www.lazyvim.org)
- Files: [yazi](https://github.com/sxyazi/yazi)
- Fonts: [Maple Mono](https://font.subf.dev/en/) · [Source Han Sans](https://github.com/adobe-fonts/source-han-sans)

## Rollback

Replaced files are moved to `~/.dotfiles-backup/<timestamp>/`. The zsh and gitconfig changes can be undone by deleting the `# >>> catppuccin-workstation >>>` block from `~/.zshrc` and unsetting the delta keys.

To remove the theme include without affecting other includes:

```bash
git config --global --fixed-value --unset-all include.path "$HOME/.config/git/catppuccin.gitconfig"
```

Remove the managed block from the selected Ghostty config to undo its changes.

## Verification

Run the installer regression checks with `python3 -B -m unittest discover -s tests -v`. They use temporary home directories and mock package installation, downloads, and plugin bootstrap; they do not install into your account.

## License

MIT for everything in this repository, except `fonts/SourceHanSansSC-VF.ttf` which is distributed under the SIL Open Font License 1.1 (see `fonts/OFL.txt`).
