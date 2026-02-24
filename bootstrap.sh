#!/bin/bash

# 遇到错误即刻退出
set -e

echo "🚀 开始执行 Ubuntu 全栈开发环境自动构建脚本..."

# ---------------------------------------------------------
# 0. 提权与代理配置 (非常重要)
# ---------------------------------------------------------
# 提前要求输入 sudo 密码，防止中途打断
sudo -v

while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# 设定代理环境变量，确保后续所有的 curl 和 wget 都能顺利拉取 GitHub 资源
export HTTP_PROXY="http://127.0.0.1:2334"
export HTTPS_PROXY="http://127.0.0.1:2334"

export ALL_PROXY="socks5://127.0.0.1:2333"
echo "✅ 已注入本地代理环境变量 (127.0.0.1:2334)"


# ---------------------------------------------------------
# 1. 基础系统包与终端神器安装
# ---------------------------------------------------------
echo "📦 正在更新系统包并安装基础依赖..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y \
    curl wget git zsh tmux stow build-essential unzip \
    jq btop ncdu fzf direnv tree software-properties-common

# ---------------------------------------------------------
# 2. 安装 Node.js 环境 (fnm + pnpm)
# ---------------------------------------------------------
if ! command -v fnm &> /dev/null; then
    echo "🟢 正在安装 fnm (Fast Node Manager)..."
    curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
    # 临时生效以便后续安装 node
    export PATH="$HOME/.local/share/fnm:$PATH"
    eval "`fnm env`"
    
    echo "🟢 正在安装 Node.js LTS 与 pnpm..."
    fnm install --lts
    fnm use lts-latest

    npm install -g pnpm
    pnpm config set registry https://mirrors.cloud.tencent.com/npm/

else

    echo "✅ Node.js (fnm) 已安装，跳过."
fi

# ---------------------------------------------------------
# 3. 安装 Lazygit
# ---------------------------------------------------------
if ! command -v lazygit &> /dev/null; then
    echo "🟠 正在安装 Lazygit..."
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')

    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf lazygit.tar.gz lazygit

    sudo install lazygit /usr/local/bin
    rm lazygit.tar.gz lazygit
else

    echo "✅ Lazygit 已安装，跳过."
fi

# ---------------------------------------------------------
# 4. 安装 Docker & Docker Compose & Lazydocker

# ---------------------------------------------------------
if ! command -v docker &> /dev/null; then
    echo "🐳 正在安装 Docker..."

    curl -fsSL https://get.docker.com | sh

    # 将当前用户加入 docker 组 (免 sudo)
    sudo usermod -aG docker $USER

    # 为 Docker Daemon 配置代理
    echo "🐳 正在为 Docker Daemon 配置代理..."
    sudo mkdir -p /etc/systemd/system/docker.service.d
    cat <<EOF | sudo tee /etc/systemd/system/docker.service.d/http-proxy.conf > /dev/null
[Service]
Environment="HTTP_PROXY=http://127.0.0.1:2334"
Environment="HTTPS_PROXY=http://127.0.0.1:2334"
Environment="NO_PROXY=localhost,127.0.0.1,192.168.1.116"
EOF
    sudo systemctl daemon-reload
    sudo systemctl restart docker
else

    echo "✅ Docker 已安装，跳过."
fi

# 安装 Lazydocker
if ! command -v lazydocker &> /dev/null; then

    echo "🐳 正在安装 Lazydocker..."
    curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
else
    echo "✅ Lazydocker 已安装，跳过."
fi

# ---------------------------------------------------------
# 5. 安装 Python (uv) & Rust 环境

# ---------------------------------------------------------
if ! command -v uv &> /dev/null; then
    echo "🐍 正在安装 Python 极速包管理器 (uv)..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
else
    echo "✅ uv 已安装，跳过."

fi

if ! command -v cargo &> /dev/null; then
    echo "🦀 正在安装 Rust 工具链..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
else
    echo "✅ Rust 已安装，跳过."

fi

# ---------------------------------------------------------
# 6. 更改默认 Shell 为 Zsh
# ---------------------------------------------------------
if [ "$SHELL" != "$(which zsh)" ]; then
    echo "🐚 正在将 Zsh 设为默认 Shell..."
    sudo chsh -s $(which zsh) $USER
fi

echo "======================================================="
echo "🎉 全栈环境构建完毕！"
echo "⚠️  注意: Docker 免 sudo 权限和 Zsh 默认环境需要重新登录才能完全生效。"
echo "👉 建议执行: sudo reboot"
echo "======================================================="
