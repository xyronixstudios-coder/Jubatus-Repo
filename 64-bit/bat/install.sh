#!/bin/bash
set -euo pipefail
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"

BAT_VERSION="0.24.0"
ARCH=$(uname -m)
case "$ARCH" in
    x86_64)  BAT_ARCH="x86_64-unknown-linux-musl" ;;
    i?86)    BAT_ARCH="i686-unknown-linux-gnu" ;;
    aarch64) BAT_ARCH="aarch64-unknown-linux-gnu" ;;
    *) echo "[HATA] Desteklenmeyen mimari: $ARCH"; exit 1 ;;
esac

BAT_URL="https://github.com/sharkdp/bat/releases/download/v${BAT_VERSION}/bat-v${BAT_VERSION}-${BAT_ARCH}.tar.gz"
TARGET="/usr/local/bin/bat"

echo ":: bat ${BAT_VERSION} (${BAT_ARCH}) indiriliyor..."
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

curl -fsSL --retry 3 --proto '=https' "$BAT_URL" -o bat.tar.gz
tar -xzf bat.tar.gz
BAT_BIN=$(find . -type f -name "bat" -executable | head -1)
if [ -z "$BAT_BIN" ]; then echo "[HATA] bat binary bulunamadi"; exit 1; fi

sudo cp -f "$BAT_BIN" "$TARGET"
sudo chmod +x "$TARGET"
cd ~ && rm -rf "$TMP_DIR"

echo "bat kuruldu: $TARGET"
