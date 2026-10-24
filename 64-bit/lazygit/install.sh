#!/bin/bash
set -euo pipefail
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"

LG_VERSION="0.44.1"
ARCH=$(uname -m)
case "$ARCH" in
    x86_64)  LG_ARCH="Linux_x86_64" ;;
    i?86)    LG_ARCH="Linux_i386" ;;
    aarch64) LG_ARCH="Linux_arm64" ;;
    *) echo "[HATA] Desteklenmeyen mimari: $ARCH"; exit 1 ;;
esac

LG_URL="https://github.com/jesseduffield/lazygit/releases/download/v${LG_VERSION}/lazygit_${LG_VERSION}_${LG_ARCH}.tar.gz"
TARGET="/usr/local/bin/lazygit"

echo ":: lazygit ${LG_VERSION} (${LG_ARCH}) indiriliyor..."
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"
curl -fsSL --retry 3 --proto '=https' "$LG_URL" -o lg.tar.gz
tar -xzf lg.tar.gz
LG_BIN=$(find . -type f -name "lazygit" -executable | head -1)
[ -z "$LG_BIN" ] && { echo "[HATA] lazygit binary bulunamadi"; exit 1; }
sudo cp -f "$LG_BIN" "$TARGET"
sudo chmod +x "$TARGET"
cd ~ && rm -rf "$TMP_DIR"
echo "lazygit kuruldu: $TARGET"
