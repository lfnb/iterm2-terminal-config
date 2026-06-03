#!/bin/bash

# ==============================================================================
# iterm2-terminal-config 一键安装脚本
# ==============================================================================
# 用法:
#   bash <(curl -fsSL https://raw.githubusercontent.com/lfnb/iterm2-terminal-config/main/install.sh)
#
# 说明:
#   1. 安装 Homebrew 依赖（字体、终端工具、zsh 插件）
#   2. 备份已有配置到 ~/.config-backup/YYYYMMDD_HHMMSS/
#   3. 从 GitHub 下载配置文件到目标位置
#
# 恢复备份:
#   cp ~/.config-backup/<时间戳>/iterm2-profile.json ~/Library/Application\ Support/iTerm2/DynamicProfiles/profile.json
#   cp ~/.config-backup/<时间戳>/starship.toml ~/.config/starship.toml
#
# 卸载 zsh 配置:
#   删除 ~/.zshrc 中 ">>> iterm2-terminal-config >>>" 到 "<<< iterm2-terminal-config <<<" 之间的内容
# ==============================================================================

set -e

REPO_URL="https://github.com/lfnb/iterm2-terminal-config.git"
BACKUP_DIR="$HOME/.config-backup/$(date +%Y%m%d_%H%M%S)"
TMP_DIR="$(mktemp -d)"
ITERM2_PROFILES_DIR="$HOME/Library/Application Support/iTerm2/DynamicProfiles"

# 清理临时目录
cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

# ==============================================================================
# 用户确认
# ==============================================================================
echo ""
echo "======================================"
echo " iTerm2 Terminal Config 安装脚本"
echo "======================================"
echo ""
echo "本脚本将执行以下操作:"
echo "  1. 通过 Homebrew 安装终端工具和字体"
echo "  2. 备份已有 iTerm2 和 Starship 配置到 ~/.config-backup/"
echo "  3. 安装新的终端配置（iTerm2 + Starship + zsh）"
echo ""
echo "已有配置将备份到: $BACKUP_DIR"
echo ""
read -p "是否继续？(y/n) " -n 1 -r < /dev/tty
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "已取消安装。"
  exit 0
fi
echo ""

# ==============================================================================
# 检查环境
# ==============================================================================
if ! command -v brew &> /dev/null; then
  echo "错误: 未检测到 Homebrew，请先安装: https://brew.sh"
  exit 1
fi

if ! command -v git &> /dev/null; then
  echo "错误: 未检测到 git，请先安装 Xcode Command Line Tools: xcode-select --install"
  exit 1
fi

# ==============================================================================
# 安装依赖
# ==============================================================================
echo "==> 安装 Homebrew 依赖..."
brew install --cask font-maple-mono-nf
if [ ! -d "/Applications/iTerm.app" ]; then
  brew install --cask iterm2
else
  echo "    iTerm2 已安装，跳过。"
fi
brew install starship fzf zoxide eza bat yazi lazygit zsh-autosuggestions zsh-syntax-highlighting zsh-completions

# ==============================================================================
# 下载配置文件
# ==============================================================================
echo "==> 下载配置文件..."
git clone --depth 1 "$REPO_URL" "$TMP_DIR/repo"

# ==============================================================================
# 备份已有配置
# ==============================================================================
echo "==> 检查已有配置..."
backup_file() {
  local file="$1"
  local name="$2"
  if [ -e "$file" ] || [ -L "$file" ]; then
    mkdir -p "$BACKUP_DIR"
    if [ -L "$file" ]; then
      local target
      target="$(readlink "$file")"
      echo "$target" > "$BACKUP_DIR/$name.symlink"
      echo "    备份软链接 $file (指向 $target)"
    else
      cp "$file" "$BACKUP_DIR/$name"
      echo "    备份文件 $file"
    fi
  fi
}

backup_file "$ITERM2_PROFILES_DIR/profile.json" "iterm2-profile.json"
backup_file ~/.config/starship.toml "starship.toml"

if [ -d "$BACKUP_DIR" ]; then
  echo ""
  echo "    ✓ 已有配置已备份到: $BACKUP_DIR"
  echo ""
else
  echo "    无已有配置，跳过备份。"
fi

# ==============================================================================
# 安装配置文件
# ==============================================================================
echo "==> 安装配置文件..."
mkdir -p "$ITERM2_PROFILES_DIR"

cp "$TMP_DIR/repo/iterm2/profile.json" "$ITERM2_PROFILES_DIR/profile.json"
cp "$TMP_DIR/repo/starship/starship.toml" ~/.config/starship.toml
echo "    ✓ ~/Library/Application Support/iTerm2/DynamicProfiles/profile.json"
echo "    ✓ ~/.config/starship.toml"

# .zshrc 追加到用户已有配置尾部（不覆盖）
if grep -q "# >>> iterm2-terminal-config >>>" ~/.zshrc 2>/dev/null; then
  echo "    .zshrc 中已存在 iterm2-terminal-config 配置，跳过。"
else
  {
    echo ""
    echo "# >>> iterm2-terminal-config >>>"
    echo "# 以下内容由 iterm2-terminal-config 安装脚本自动追加"
    echo "# 删除方法: 移除从 >>> 到 <<< 之间的所有内容"
    cat "$TMP_DIR/repo/zsh/.zshrc"
    echo "# <<< iterm2-terminal-config <<<"
  } >> ~/.zshrc
  echo "    ✓ ~/.zshrc (已追加到尾部)"
fi

# ==============================================================================
# 设置 iTerm2 全局偏好
# ==============================================================================
echo "==> 设置 iTerm2 偏好..."
# 选中文本自动复制到剪贴板
defaults write com.googlecode.iterm2 CopySelection -bool true
# 打字时隐藏鼠标
defaults write com.googlecode.iterm2 HideMouseWhileTyping -bool true
echo "    ✓ 选中自动复制、打字隐藏鼠标"

# ==============================================================================
# 完成
# ==============================================================================
echo ""
echo "======================================"
echo " 安装完成！"
echo "======================================"
echo ""
echo "请重启 iTerm2 终端生效。"
echo "在 iTerm2 → Profiles 中选择 \"Catppuccin Mocha\" 并设为默认。"
echo ""
if [ -d "$BACKUP_DIR" ]; then
  echo "恢复旧配置:"
  echo "  cp $BACKUP_DIR/iterm2-profile.json ~/Library/Application\ Support/iTerm2/DynamicProfiles/profile.json"
  echo "  cp $BACKUP_DIR/starship.toml ~/.config/starship.toml"
  echo ""
fi
echo "卸载 zsh 配置:"
echo "  删除 ~/.zshrc 中 '>>> iterm2-terminal-config >>>' 到 '<<< iterm2-terminal-config <<<' 之间的所有内容"
echo ""
