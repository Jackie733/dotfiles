#!/bin/bash

REPO_URL="https://github.com/Jackie733/dotfiles.git"
TARGET_DIR="$HOME/dotfiles"

if ! command -v git &>/dev/null; then
	echo "Error: git is not installed. Please install git first."
	exit 1
fi

if [ -d "$TARGET_DIR" ]; then
	echo "Directory $TARGET_DIR already exists."
	echo "Updating existing repository..."
	cd "$TARGET_DIR" && git pull
else
	echo "Cloning repository..."
	git clone "$REPO_URL" "$TARGET_DIR"
fi

cd "$TARGET_DIR" || exit

if [ -f "install.sh" ]; then
	echo "Running install script..."
	chmod +x install.sh
	./install.sh
else
	echo "Error: install.sh not found in $TARGET_DIR."
	exit 1
fi

echo "Setup completed successfully!"
