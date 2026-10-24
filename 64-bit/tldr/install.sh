#!/bin/bash
set -euo pipefail
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"

# tlrc (Rust tldr client) kullaniyoruz - tldr-pages/tlrc
TLRC_VERSION="1.11.0"
ARCH=$(uname -m)
case "$ARCH" in
    x86_64)  TLRC_ARCH="x86_64-unknown-linux-musl" ;;
    i?86)    TLRC_ARCH="i686-unknown-linux-musl" ;;
    aarch64) TLRC_ARCH="aarch64-unknown-linux-musl" ;;
    *) echo "[HATA] Desteklenmeyen mimari: $ARCH"; exit 1 ;;
esac

TLRC_URL="https://github.com/tldr-pages/tlrc/releases/download/v${TLRC_VERSION}/tlrc-v${TLRC_VERSION}-${TLRC_ARCH}.tar.gz"
TARGET="/usr/local/bin/tldr"

echo ":: tldr (tlrc ${TLRC_VERSION}, ${TLRC_ARCH}) indiriliyor..."
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

if ! curl -fsSL --retry 3 --proto '=https' "$TLRC_URL" -o tlrc.tar.gz; then
    echo "[HATA] tldr indirilemedi: $TLRC_URL" >&2
    exit 1
fi

tar -xzf tlrc.tar.gz
TLRC_BIN=$(find . -type f -name "tldr" -executable | head -1)
if [ -z "$TLRC_BIN" ]; then
    echo "[HATA] tldr binary bulunamadi" >&2
    find . -type f | head -20 >&2
    exit 1
fi

sudo cp -f "$TLRC_BIN" "$TARGET"
sudo chmod +x "$TARGET"
cd ~ && rm -rf "$TMP_DIR"

echo "tldr (tlrc) kuruldu: $TARGET"
