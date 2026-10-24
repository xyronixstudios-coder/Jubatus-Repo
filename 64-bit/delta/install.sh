#!/bin/bash
set -euo pipefail
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"

DELTA_VERSION="0.18.2"
ARCH=$(uname -m)
case "$ARCH" in
    x86_64)  DELTA_ARCH="x86_64-unknown-linux-musl" ;;
    i?86)    DELTA_ARCH="i686-unknown-linux-musl" ;;
    aarch64) DELTA_ARCH="aarch64-unknown-linux-musl" ;;
    *) echo "[HATA] Desteklenmeyen mimari: $ARCH"; exit 1 ;;
esac

DELTA_URL="https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/delta-${DELTA_VERSION}-${DELTA_ARCH}.tar.gz"
TARGET="/usr/local/bin/delta"

echo ":: delta ${DELTA_VERSION} (${DELTA_ARCH}) indiriliyor..."
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"
curl -fsSL --retry 3 --proto '=https' "$DELTA_URL" -o delta.tar.gz
tar -xzf delta.tar.gz
DELTA_BIN=$(find . -type f -name "delta" -executable | head -1)
[ -z "$DELTA_BIN" ] && { echo "[HATA] delta binary bulunamadi"; exit 1; }
sudo cp -f "$DELTA_BIN" "$TARGET"
sudo chmod +x "$TARGET"
cd ~ && rm -rf "$TMP_DIR"

# Git config onerisi
echo ":: Git config onerisi: git config --global core.pager delta"
echo "delta kuruldu: $TARGET"
