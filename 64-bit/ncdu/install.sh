#!/bin/bash
set -euo pipefail
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"

NCDU_VERSION="2.7"
ARCH=$(uname -m)
case "$ARCH" in
    x86_64)  NCDU_ARCH="x86_64-linux-musl" ;;
    i?86)    NCDU_ARCH="i386-linux-musl" ;;
    aarch64) NCDU_ARCH="aarch64-linux-musl" ;;
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
