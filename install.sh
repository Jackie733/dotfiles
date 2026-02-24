#!/bin/bash

# 遇到错误立即退出
set -e

# 获取 dotfiles 目录的绝对路径
DOTFILES_DIR="$HOME/dotfiles"

echo "🚀 开始部署 Dotfiles 环境..."

# 1. 确保在正确的目录下
cd "$DOTFILES_DIR"

# 2. 同步并更新所有子模块 (非常重要！在新电脑上 clone 后，子模块默认是空的)
echo "📦 正在初始化和更新 Git 子模块 (Neovim & Tmux)..."
git submodule update --init --recursive

# 3. 自动化 Stow 投射
echo "🔗 正在生成软链接..."

# 遍历 dotfiles 下的所有非隐藏目录，并执行 stow
for dir in */; do
    # 去除目录名末尾的斜杠
    package="${dir%/}"
    

    echo "  👉 正在链接: $package"
    # 使用 -R (restow) 模式，它会自动修复断裂的链接并覆盖旧链接
    stow -R --target="$HOME" "$package"
done

echo "✅ 所有配置已部署完毕！"
echo "🎉 欢迎回到你的专属极客环境！"
