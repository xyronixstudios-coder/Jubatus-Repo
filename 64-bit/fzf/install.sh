#!/bin/bash
set -euo pipefail
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"

FZF_VERSION="0.56.3"
ARCH=$(uname -m)
case "$ARCH" in
    x86_64)  FZF_ARCH="linux_amd64" ;;
    i?86)    FZF_ARCH="linux_386" ;;
    aarch64) FZF_ARCH="linux_arm64" ;;
    *) echo "[HATA] Desteklenmeyen mimari: $ARCH"; exit 1 ;;
esac

FZF_URL="https://github.com/junegunn/fzf/releases/download/v${FZF_VERSION}/fzf-${FZF_VERSION}-${FZF_ARCH}.tar.gz"
TARGET="/usr/local/bin/fzf"

echo ":: fzf ${FZF_VERSION} (${FZF_ARCH}) indiriliyor..."
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"
curl -fsSL --retry 3 --proto '=https' "$FZF_URL" -o fzf.tar.gz
tar -xzf fzf.tar.gz
FZF_BIN=$(find . -type f -name "fzf" -executable | head -1)
[ -z "$FZF_BIN" ] && { echo "[HATA] fzf binary bulunamadi"; exit 1; }
sudo cp -f "$FZF_BIN" "$TARGET"
sudo chmod +x "$TARGET"
cd ~ && rm -rf "$TMP_DIR"
echo "fzf kuruldu: $TARGET"
