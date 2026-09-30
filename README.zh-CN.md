# Catppuccin Workstation

[English](README.md)

一套穿同款配色的 macOS 终端工作站——[Catppuccin Macchiato](https://catppuccin.com)，从终端模拟器到文件管理器，一个主题贯穿到底。

> 当前仅在 macOS 上验证，适合喜欢深色主题的朋友。其他操作系统或浅色主题不保证兼容。

![Ghostty 中的 Catppuccin Macchiato 工作站：左侧 Neovim，右上 lazygit，右下 Starship 与 eza](docs/screenshot.png)

## 包含什么

| 层 | 工具 | 说明 |
| --- | --- | --- |
| 终端 | [Ghostty](https://ghostty.org) | Catppuccin Macchiato，轻毛玻璃，`cmd+shift+r` 热重载 |
| 提示符 | [starship](https://starship.rs) | 极简 format：目录、git 分支、主机名（仅 SSH） |
| Shell | zsh | [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)，仅加载提示符与语法高亮 |
| 命令行 | [eza](https://github.com/eza-community/eza) / [bat](https://github.com/sharkdp/bat) / [ripgrep](https://github.com/BurntSushi/ripgrep) / [fzf](https://github.com/junegunn/fzf) | 文件展示、主题高亮及编辑器搜索依赖；不设置 alias |
| Git | [delta](https://github.com/dandavison/delta) + [lazygit](https://github.com/jesseduffield/lazygit) | 处处带主题的 diff，lazygit 的 diff 也走 delta |
| 编辑器 | [Neovim](https://neovim.io) + [LazyVim](https://www.lazyvim.org) | 原版 LazyVim + Catppuccin 配色 |
| 文件 | [yazi](https://github.com/sxyazi/yazi) | Catppuccin flavor |

字体：[Maple Mono Normal NL NF](https://font.subf.dev/en/)（Homebrew 安装）+ [思源黑体](https://github.com/adobe-fonts/source-han-sans)（随仓库分发，SIL OFL 1.1）。

仓库提供主题配置及必要的加载设置；命令 alias、补全、目录跳转等由用户自己的 shell 配置管理。

## 安装

一行：

```bash
curl -fsSL https://raw.githubusercontent.com/barrychen38/catppuccin-workstation/main/install.sh | bash
```

或先克隆看一眼再装：

```bash
git clone https://github.com/barrychen38/catppuccin-workstation
cd catppuccin-workstation && ./install.sh
```

安装全程**增量更新**，不动你自己的东西：

- `~/.zshrc` 保留原内容，只在末尾追加一个受管理的小块，source 我们的片段（`~/.config/catppuccin-workstation/zshrc`）
- `~/.gitconfig` 保留原内容和已有 include；主题 include 只添加一次，delta 配置用 `git config --global` 逐项合入
- Ghostty 在现有配置中维护受管理块；优先使用 Application Support 目录，同一目录优先使用 `config.ghostty`，再使用 `config`，保留原文件及用户设置
- bat 配置只在缺主题行时补上
- 完全由我们接管的全量文件（starship.toml、lazygit、nvim、yazi flavor）替换前会备份到 `~/.dotfiles-backup/<时间戳>/`
- 安装器还会：Homebrew 装依赖（`--no-brew` 跳过）、装思源黑体、装 bat 的 Catppuccin 主题、无头引导 Neovim 插件

本套配置面向 zsh（macOS 默认 shell）。如果你的登录 shell 不是 zsh，安装器会提示切换方法（`chsh -s /bin/zsh`）。

## 可选效率工具

以下工具不是主题依赖，但可以搭配使用，提高日常终端操作效率。它们按需安装，本仓库的安装脚本不会安装或初始化它们：

| 工具 | 用途 |
| --- | --- |
| [fzf-tab](https://github.com/Aloxaf/fzf-tab) | 用 fzf 筛选 zsh 的 Tab 补全候选项 |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | 用 `z` 快速跳转到常用目录 |
| [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) | 输入时根据历史记录提示命令 |

通过 Homebrew 安装（fzf-tab 依赖 `fzf`，本仓库的 Brewfile 已包含 `fzf`）：

```bash
brew install fzf fzf-tab zoxide zsh-autosuggestions
```

仅安装 package 不会启用 shell 集成，需要参考上述项目的说明，在自己的 `~/.zshrc` 中配置。fzf-tab 应在 `compinit` 之后、zsh-autosuggestions 之前加载；本仓库加载语法高亮的受管理块应放在这些插件之后。本仓库不管理这些集成或用户的命令 alias。

## 工具与链接

- 主题：[Catppuccin](https://catppuccin.com) · [catppuccin/delta](https://github.com/catppuccin/delta) · [catppuccin/bat](https://github.com/catppuccin/bat) · [catppuccin/yazi](https://github.com/catppuccin/yazi)
- 终端：[Ghostty](https://ghostty.org)
- 提示符与 Shell：[starship](https://starship.rs) · [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
- 命令行：[eza](https://github.com/eza-community/eza) · [bat](https://github.com/sharkdp/bat) · [ripgrep](https://github.com/BurntSushi/ripgrep) · [fzf](https://github.com/junegunn/fzf)
- Git：[git-delta](https://github.com/dandavison/delta) · [lazygit](https://github.com/jesseduffield/lazygit)
- 编辑器：[Neovim](https://neovim.io) · [LazyVim](https://www.lazyvim.org)
- 文件：[yazi](https://github.com/sxyazi/yazi)
- 字体：[Maple Mono](https://font.subf.dev/en/) · [思源黑体](https://github.com/adobe-fonts/source-han-sans)

## 回滚

被替换的文件都移到了 `~/.dotfiles-backup/<时间戳>/`；zsh 与 gitconfig 的改动，删掉 `~/.zshrc` 里 `# >>> catppuccin-workstation >>>` 块、unset 掉 delta 相关 key 即可撤销。

删除主题 include 时，保留其他 include：

```bash
git config --global --fixed-value --unset-all include.path "$HOME/.config/git/catppuccin.gitconfig"
```

Ghostty 的改动可通过删除实际安装位置中的受管理块撤销。

## 验证

运行 `python3 -B -m unittest discover -s tests -v` 执行安装器回归检查。测试使用临时用户目录，模拟依赖安装、下载和插件引导，不会安装到当前账号。

## 许可

仓库内容为 MIT；`fonts/SourceHanSansSC-VF.ttf` 遵循 SIL Open Font License 1.1（见 `fonts/OFL.txt`）。
