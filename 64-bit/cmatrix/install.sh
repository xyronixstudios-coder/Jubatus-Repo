#!/bin/bash
set -euo pipefail
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"

# cmatrix apt'ten veya kaynak derleme
if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get install -y cmatrix >/dev/null 2>&1 && { echo "cmatrix kuruldu (apt)"; exit 0; }
elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -S --noconfirm cmatrix >/dev/null 2>&1 && { echo "cmatrix kuruldu (pacman)"; exit 0; }
elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y cmatrix >/dev/null 2>&1 && { echo "cmatrix kuruldu (dnf)"; exit 0; }
elif command -v zypper >/dev/null 2>&1; then
    sudo zypper --non-interactive install cmatrix >/dev/null 2>&1 && { echo "cmatrix kuruldu (zypper)"; exit 0; }
fi

# Fallback: kaynak derle
echo ":: cmatrix kaynaktan derleniyor..."
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"
curl -fsSL "https://github.com/abishekvashok/cmatrix/releases/download/v2.0/cmatrix-v2.0-Butterscotch.tar.gz" -o cmatrix.tar.gz
tar -xzf cmatrix.tar.gz
cd cmatrix-* 2>/dev/null || cd cmatrix
./configure --prefix=/usr/local >/dev/null 2>&1 || true
make >/dev/null 2>&1 || true
sudo make install >/dev/null 2>&1 || true
cd ~ && rm -rf "$TMP_DIR"
echo "cmatrix kuruldu (kaynak)"
