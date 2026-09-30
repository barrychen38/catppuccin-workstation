# Catppuccin Workstation

[English](README.md)

一套穿同款配色的 macOS 终端工作站——[Catppuccin Macchiato](https://catppuccin.com)，从终端模拟器到文件管理器，一个主题贯穿到底。

<!-- TODO: 替换为真实终端截图 -->
![terminal](docs/screenshot.png)

## 包含什么

| 层 | 工具 | 说明 |
| --- | --- | --- |
| 终端 | [Ghostty](https://ghostty.org) | Catppuccin Macchiato，轻毛玻璃，`cmd+shift+r` 热重载 |
| 提示符 | [starship](https://starship.rs) | 极简 format：目录、git 分支、主机名（仅 SSH） |
| Shell | zsh | [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)、[zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)、[fzf](https://github.com/junegunn/fzf)、[fzf-tab](https://github.com/Aloxaf/fzf-tab)、[zoxide](https://github.com/ajeetdsouza/zoxide)，无 Oh My Zsh |
| 命令平替 | [eza](https://github.com/eza-community/eza) / [bat](https://github.com/sharkdp/bat) / [ripgrep](https://github.com/BurntSushi/ripgrep) / zoxide | `ls`、`cat`、`grep`、`cd` 的升级 |
| Git | [delta](https://github.com/dandavison/delta) + [lazygit](https://github.com/jesseduffield/lazygit) | 处处带主题的 diff，lazygit 的 diff 也走 delta |
| 编辑器 | [Neovim](https://neovim.io) + [LazyVim](https://www.lazyvim.org) | 原版 LazyVim + Catppuccin 配色 |
| 文件 | [yazi](https://github.com/sxyazi/yazi) | Catppuccin flavor，`y()` 退出时 cd 到浏览目录 |

字体：[Maple Mono NF](https://font.subf.dev/en/)（Homebrew 安装）+ [思源黑体](https://github.com/adobe-fonts/source-han-sans)（随仓库分发，SIL OFL 1.1）。

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
- `~/.gitconfig` 保留原内容，delta 配置用 `git config --global` 逐项合入
- Ghostty 配置追加受管理块（后出现的配置生效）
- bat 配置只在缺主题行时补上
- 完全由我们接管的全量文件（starship.toml、lazygit、nvim、yazi flavor）替换前会备份到 `~/.dotfiles-backup/<时间戳>/`
- 安装器还会：Homebrew 装依赖（`--no-brew` 跳过）、装思源黑体、装 bat 的 Catppuccin 主题、无头引导 Neovim 插件

本套配置面向 zsh（macOS 默认 shell）。如果你的登录 shell 不是 zsh，安装器会提示切换方法（`chsh -s /bin/zsh`）。

## 工具与链接

- 主题：[Catppuccin](https://catppuccin.com) · [catppuccin/delta](https://github.com/catppuccin/delta) · [catppuccin/bat](https://github.com/catppuccin/bat) · [catppuccin/yazi](https://github.com/catppuccin/yazi)
- 终端：[Ghostty](https://ghostty.org)
- 提示符与 Shell：[starship](https://starship.rs) · [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) · [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) · [fzf](https://github.com/junegunn/fzf) · [fzf-tab](https://github.com/Aloxaf/fzf-tab) · [zoxide](https://github.com/ajeetdsouza/zoxide)
- 命令行：[eza](https://github.com/eza-community/eza) · [bat](https://github.com/sharkdp/bat) · [ripgrep](https://github.com/BurntSushi/ripgrep)
- Git：[git-delta](https://github.com/dandavison/delta) · [lazygit](https://github.com/jesseduffield/lazygit)
- 编辑器：[Neovim](https://neovim.io) · [LazyVim](https://www.lazyvim.org)
- 文件：[yazi](https://github.com/sxyazi/yazi)
- 字体：[Maple Mono](https://font.subf.dev/en/) · [思源黑体](https://github.com/adobe-fonts/source-han-sans)

## 回滚

被替换的文件都移到了 `~/.dotfiles-backup/<时间戳>/`；zsh 与 gitconfig 的改动，删掉 `~/.zshrc` 里 `# >>> catppuccin-workstation >>>` 块、unset 掉 delta 相关 key 即可撤销。

## 许可

仓库内容为 MIT；`fonts/SourceHanSansSC-VF.ttf` 遵循 SIL Open Font License 1.1（见 `fonts/OFL.txt`）。
