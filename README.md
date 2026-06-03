# iTerm2 Terminal Config

macOS 下基于 iTerm2 + Starship + zsh 插件的终端美化方案，一键安装即可在新电脑复用。

## 效果

- 彩虹条提示符（基于 Starship 官方 catppuccin-powerline 预设，启用换行显示）
- 半透明毛玻璃窗口
- 语法高亮、自动建议、模糊搜索

## 包含的配置文件

| 文件 | 说明 | 安装位置 |
|------|------|---------|
| `iterm2/profile.json` | iTerm2 配置（字体、配色、窗口、光标） | `~/Library/Application Support/iTerm2/DynamicProfiles/profile.json` |
| `starship/starship.toml` | Starship 彩虹条提示符配置（官方预设 + 换行） | `~/.config/starship.toml` |
| `zsh/.zshrc` | zsh 配置（插件、工具、别名、快捷键） | `~/.zshrc` |

## 一键安装

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/lfnb/iterm2-terminal-config/main/install.sh)
```

安装前会询问确认，确认后自动执行：
1. 通过 Homebrew 安装所有依赖
2. 备份已有 iTerm2 和 Starship 配置文件
3. 安装 iTerm2 Profile 和 Starship 配置
4. 将 zsh 配置追加到 `~/.zshrc` 尾部（不覆盖用户已有内容）
5. 设置 iTerm2 全局偏好（选中自动复制、打字隐藏鼠标）

安装完成后，在 iTerm2 → Profiles 中选择 "Catppuccin Mocha" 并设为默认。

## 备份与恢复

安装脚本会自动将已有配置备份到 `~/.config-backup/<时间戳>/` 目录。

备份文件对应关系：

| 备份文件 | 原始位置 |
|---------|---------|
| `~/.config-backup/<时间戳>/iterm2-profile.json` | `~/Library/Application Support/iTerm2/DynamicProfiles/profile.json` |
| `~/.config-backup/<时间戳>/starship.toml` | `~/.config/starship.toml` |

恢复命令：

```bash
# 查看备份目录（找到对应时间戳）
ls ~/.config-backup/

# 恢复（替换 <时间戳> 为实际目录名）
cp ~/.config-backup/<时间戳>/iterm2-profile.json ~/Library/Application\ Support/iTerm2/DynamicProfiles/profile.json
cp ~/.config-backup/<时间戳>/starship.toml ~/.config/starship.toml
```

### 卸载 zsh 配置

删除 `~/.zshrc` 中 `# >>> iterm2-terminal-config >>>` 到 `# <<< iterm2-terminal-config <<<` 之间的所有内容即可。

## 依赖

| 工具 | 用途 |
|------|------|
| [iTerm2](https://iterm2.com) | macOS 终端模拟器 |
| [Starship](https://starship.rs) | 跨 shell 提示符 |
| [fzf](https://github.com/junegunn/fzf) | 模糊搜索（Ctrl+R 搜历史，Ctrl+T 搜文件） |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | 智能目录跳转（`z foo` 代替 `cd`） |
| [eza](https://github.com/eza-community/eza) | 替代 ls，彩色图标 |
| [bat](https://github.com/sharkdp/bat) | 替代 cat，语法高亮 |
| [yazi](https://github.com/sxyazi/yazi) | 终端文件管理器 |
| [lazygit](https://github.com/jesseduffield/lazygit) | Git 终端 UI（`lg` 启动） |
| [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) | 历史命令自动建议 |
| [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) | 命令语法高亮 |
| [zsh-completions](https://github.com/zsh-users/zsh-completions) | Tab 补全增强 |
| [Maple Mono NF](https://github.com/subframe7536/maple-font) | 终端字体（Nerd Font，中文显示优秀） |

## 手动安装

### 1. 安装依赖

```bash
brew install --cask font-maple-mono-nf
brew install --cask iterm2
brew install starship fzf zoxide eza bat yazi lazygit zsh-autosuggestions zsh-syntax-highlighting zsh-completions
```

### 2. 下载配置文件

```bash
git clone --depth 1 https://github.com/lfnb/iterm2-terminal-config.git /tmp/iterm2-config
```

### 3. 安装配置文件

```bash
mkdir -p ~/Library/Application\ Support/iTerm2/DynamicProfiles
cp /tmp/iterm2-config/iterm2/profile.json ~/Library/Application\ Support/iTerm2/DynamicProfiles/profile.json
cp /tmp/iterm2-config/starship/starship.toml ~/.config/starship.toml
cat /tmp/iterm2-config/zsh/.zshrc >> ~/.zshrc
```

> 注意：zsh 配置是追加到 `~/.zshrc` 尾部，不会覆盖已有内容。如果重复执行需手动去重。

### 4. 设置 iTerm2 偏好

```bash
defaults write com.googlecode.iterm2 CopySelection -bool true
defaults write com.googlecode.iterm2 HideMouseWhileTyping -bool true
```

### 5. 清理并重启

```bash
rm -rf /tmp/iterm2-config
```

重启 iTerm2，在 Profiles 中选择 "Catppuccin Mocha" 并设为默认。

## Starship 预设说明

彩虹条基于 `starship preset catppuccin-powerline` 官方预设，唯一改动：

- `[line_break] disabled = false`：彩虹条一行，输入符号在下一行

## 快捷键速查

| 快捷键 | 功能 |
|--------|------|
| `Ctrl+F` | 接受自动建议 |
| `Ctrl+R` | fzf 模糊搜索历史命令 |
| `Ctrl+T` | fzf 模糊搜索文件 |
| `Tab` | 补全，连续按在候选列表中移动 |

## 别名速查

| 别名 | 实际命令 |
|------|---------|
| `ls` | `eza --icons --group-directories-first` |
| `ll` | `eza -l --icons --sort=name` |
| `lt` | `eza --tree --icons --level=2` |
| `cat` | `bat --paging=never --style=plain` |
| `y` | yazi 文件管理器（退出自动 cd） |
| `lg` | lazygit（Git 终端 UI） |
| `z foo` | zoxide 智能跳转到包含 foo 的目录 |
