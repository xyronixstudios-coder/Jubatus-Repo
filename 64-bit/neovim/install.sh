#!/bin/bash
set -euo pipefail
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"

# 1. Once apt/pacman/dnf (32-bit uyumlu)
if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get install -y neovim >/dev/null 2>&1 && { echo "neovim kuruldu (apt)"; exit 0; }
elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -S --noconfirm neovim >/dev/null 2>&1 && { echo "neovim kuruldu (pacman)"; exit 0; }
elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y neovim >/dev/null 2>&1 && { echo "neovim kuruldu (dnf)"; exit 0; }
fi

# 2. Fallback: GitHub release (64-bit ve arm64 icin)
NVIM_VERSION="0.10.4"
ARCH=$(uname -m)
case "$ARCH" in
    x86_64)  NVIM_ARCH="nvim-linux-x86_64" ;;
    aarch64) NVIM_ARCH="nvim-linux-arm64" ;;
    *) echo "[HATA] 32-bit icin apt gerekli (neovim binary yok)"; exit 1 ;;
esac

NVIM_URL="https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}/${NVIM_ARCH}.tar.gz"
TARGET="/usr/local/bin/nvim"

echo ":: neovim ${NVIM_VERSION} (${NVIM_ARCH}) indiriliyor..."
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"
curl -fsSL --retry 3 --proto '=https' "$NVIM_URL" -o nvim.tar.gz
tar -xzf nvim.tar.gz
NVIM_BIN=$(find . -type f -name "nvim" -executable | head -1)
[ -z "$NVIM_BIN" ] && { echo "[HATA] nvim binary bulunamadi"; exit 1; }
sudo cp -f "$NVIM_BIN" "$TARGET"
sudo chmod +x "$TARGET"
cd ~ && rm -rf "$TMP_DIR"
echo "neovim kuruldu: $TARGET"
