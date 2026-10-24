#!/bin/bash
set -euo pipefail
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"

# 1. apt/pacman/dnf
if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get install -y ncdu >/dev/null 2>&1 && { echo "ncdu kuruldu (apt)"; exit 0; }
elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -S --noconfirm ncdu >/dev/null 2>&1 && { echo "ncdu kuruldu (pacman)"; exit 0; }
elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y ncdu >/dev/null 2>&1 && { echo "ncdu kuruldu (dnf)"; exit 0; }
fi

# 2. Fallback: statik binary
NCDU_VERSION="2.7"
ARCH=$(uname -m)
case "$ARCH" in
    x86_64)  NCDU_ARCH="linux-x86_64" ;;
    i?86)    NCDU_ARCH="linux-i386" ;;
    aarch64) NCDU_ARCH="linux-aarch64" ;;
    *) echo "[HATA] Desteklenmeyen mimari: $ARCH"; exit 1 ;;
esac

NCDU_URL="https://dev.yorhel.nl/download/ncdu-${NCDU_VERSION}-${NCDU_ARCH}.tar.gz"
TARGET="/usr/local/bin/ncdu"

echo ":: ncdu ${NCDU_VERSION} (${NCDU_ARCH}) indiriliyor..."
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"
curl -fsSL --retry 3 --proto '=https' "$NCDU_URL" -o ncdu.tar.gz
tar -xzf ncdu.tar.gz
NCDU_BIN=$(find . -type f -name "ncdu" -executable | head -1)
[ -z "$NCDU_BIN" ] && { echo "[HATA] ncdu binary bulunamadi"; exit 1; }
sudo cp -f "$NCDU_BIN" "$TARGET"
sudo chmod +x "$TARGET"
cd ~ && rm -rf "$TMP_DIR"
echo "ncdu kuruldu: $TARGET"
