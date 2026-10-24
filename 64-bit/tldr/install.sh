#!/bin/bash
set -euo pipefail
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"

ARCH=$(uname -m)
case "$ARCH" in
    x86_64)  TLDR_ARCH="x86_64" ;;
    i?86)    TLDR_ARCH="i686" ;;
    aarch64) TLDR_ARCH="aarch64" ;;
    *) echo "[HATA] Desteklenmeyen mimari: $ARCH"; exit 1 ;;
esac

TLDR_URL="https://github.com/tldr-pages/tldr/releases/latest/download/tldr-${TLDR_ARCH}-unknown-linux-musl.tar.gz"
TARGET="/usr/local/bin/tldr"

echo ":: tldr (${TLDR_ARCH}) indiriliyor..."
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"
curl -fsSL --retry 3 --proto '=https' "$TLDR_URL" -o tldr.tar.gz
tar -xzf tldr.tar.gz
TLDR_BIN=$(find . -type f -name "tldr" -executable | head -1)
[ -z "$TLDR_BIN" ] && { echo "[HATA] tldr binary bulunamadi"; exit 1; }
sudo cp -f "$TLDR_BIN" "$TARGET"
sudo chmod +x "$TARGET"
cd ~ && rm -rf "$TMP_DIR"
echo "tldr kuruldu: $TARGET"
