# Dotfiles

## Step 0: install vpn

> IMPORTANT: must install vpn first

install clash or sing-box first

## Step 1: clone repository

```bash
sudo apt update && sudo apt install git stow -y

git clone --recursive git@github.com:Jackie733/dotfiles.git ~/dotfiles
```

## Step 2: install

```bash
cd ~/dotfiles
./install.sh
```

## Step3: bootstrap

```bash
./bootstrap.sh
```
