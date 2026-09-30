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
| Shell | zsh + autosuggestions / syntax-highlighting / fzf-tab | 无 Oh My Zsh |
| 命令平替 | eza / bat / ripgrep / zoxide | `ls`、`cat`、`grep`、`cd` 的升级 |
| Git | [delta](https://github.com/dandavison/delta) + [lazygit](https://github.com/jesseduffield/lazygit) | 处处带主题的 diff，lazygit 的 diff 也走 delta |
| 编辑器 | Neovim + [LazyVim](https://www.lazyvim.org) | Catppuccin 配色，插件版本锁定 |
| 文件 | [yazi](https://github.com/sxyazi/yazi) | Catppuccin flavor，`y()` 退出时 cd 到浏览目录 |
| Agent 工作台 | [Herdr](https://herdr.dev) | 只装配置；二进制去 herdr.dev 安装 |

字体：Maple Mono NF（Homebrew 安装）+ 思源黑体（随仓库分发，SIL OFL 1.1）。

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

安装器会：

1. 用 Homebrew 装依赖（`--no-brew` 跳过）
2. 把现有配置备份到 `~/.dotfiles-backup/<时间戳>/`
3. 安装全部配置（Ghostty、zsh、starship、bat、git、lazygit、nvim、yazi、herdr）和思源黑体
4. 安装 bat 的 Catppuccin 主题
5. 无头引导 Neovim 插件
6. 生成 `~/.zshrc.local`，放你的密钥、代理和工作别名

装完记得：设置 git 身份（`git config --global user.name/email`），再开一个新终端窗口。

## 刻意不收进来的东西

密钥、代理、个人别名永远不会进这个仓库。它们放在 `~/.zshrc.local`，由仓库的 `~/.zshrc` 在末尾加载。模板见 `config/zsh/zshrc.local.example`。

## 回滚

每次安装都会把被替换的文件移到 `~/.dotfiles-backup/<时间戳>/`，想撤销就拷回去。

## 许可

仓库内容为 MIT；`fonts/SourceHanSansSC-VF.ttf` 遵循 SIL Open Font License 1.1（见 `fonts/OFL.txt`）。
