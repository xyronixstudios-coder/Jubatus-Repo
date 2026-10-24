#!/bin/bash
set -euo pipefail
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"

BTM_VERSION="0.10.2"
ARCH=$(uname -m)
case "$ARCH" in
    x86_64)  BTM_ARCH="x86_64-unknown-linux-musl" ;;
    i?86)    BTM_ARCH="i686-unknown-linux-musl" ;;
    aarch64) BTM_ARCH="aarch64-unknown-linux-musl" ;;
    *) echo "[HATA] Desteklenmeyen mimari: $ARCH"; exit 1 ;;
esac

BTM_URL="https://github.com/ClementTsang/bottom/releases/download/${BTM_VERSION}/bottom_${BTM_ARCH}.tar.gz"
TARGET="/usr/local/bin/btm"

echo ":: bottom ${BTM_VERSION} (${BTM_ARCH}) indiriliyor..."
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"
curl -fsSL --retry 3 --proto '=https' "$BTM_URL" -o btm.tar.gz
tar -xzf btm.tar.gz
BTM_BIN=$(find . -type f -name "btm" -executable | head -1)
[ -z "$BTM_BIN" ] && { echo "[HATA] btm binary bulunamadi"; exit 1; }
sudo cp -f "$BTM_BIN" "$TARGET"
sudo chmod +x "$TARGET"
cd ~ && rm -rf "$TMP_DIR"
echo "bottom kuruldu: $TARGET"
