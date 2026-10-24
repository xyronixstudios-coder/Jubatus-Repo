#!/bin/bash
set -euo pipefail
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"

NCDU_VERSION="2.7"
ARCH=$(uname -m)
case "$ARCH" in
    x86_64)  NCDU_ARCH="linux-x86_64" ;;
    i?86)    NCDU_ARCH="linux-i386" ;;
    aarch64) NCDU_ARCH="linux-aarch64" ;;
    *) echo "[HATA] Desteklenmeyen mimari: $ARCH"; exit 1 ;;
esac

# Dogru URL: linux-x86_64 (x86_64 degil!)
NCDU_URL="https://dev.yorhel.nl/download/ncdu-${NCDU_VERSION}-${NCDU_ARCH}.tar.gz"
TARGET="/usr/local/bin/ncdu"

echo ":: ncdu ${NCDU_VERSION} (${NCDU_ARCH}) indiriliyor..."
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

if ! curl -fsSL --retry 3 --proto '=https' "$NCDU_URL" -o ncdu.tar.gz; then
    echo "[HATA] ncdu indirilemedi: $NCDU_URL" >&2
    exit 1
fi

tar -xzf ncdu.tar.gz
NCDU_BIN=$(find . -type f -name "ncdu" -executable | head -1)
if [ -z "$NCDU_BIN" ]; then
    echo "[HATA] ncdu binary bulunamadi" >&2
    find . -type f -executable | head -10 >&2
    exit 1
fi

sudo cp -f "$NCDU_BIN" "$TARGET"
sudo chmod +x "$TARGET"
cd ~ && rm -rf "$TMP_DIR"
echo "ncdu kuruldu: $TARGET"
