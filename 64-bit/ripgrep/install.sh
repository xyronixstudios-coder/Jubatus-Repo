#!/bin/bash
set -euo pipefail
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"

RG_VERSION="14.1.1"
ARCH=$(uname -m)
case "$ARCH" in
    x86_64)  RG_ARCH="x86_64-unknown-linux-musl" ;;
    i?86)    RG_ARCH="i686-unknown-linux-musl" ;;
    aarch64) RG_ARCH="aarch64-unknown-linux-gnu" ;;
    *) echo "[HATA] Desteklenmeyen mimari: $ARCH"; exit 1 ;;
esac

RG_URL="https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/ripgrep-${RG_VERSION}-${RG_ARCH}.tar.gz"
TARGET="/usr/local/bin/rg"

echo ":: ripgrep ${RG_VERSION} (${RG_ARCH}) indiriliyor..."
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"
curl -fsSL --retry 3 --proto '=https' "$RG_URL" -o rg.tar.gz
tar -xzf rg.tar.gz
RG_BIN=$(find . -type f -name "rg" -executable | head -1)
[ -z "$RG_BIN" ] && { echo "[HATA] rg binary bulunamadi"; exit 1; }
sudo cp -f "$RG_BIN" "$TARGET"
sudo chmod +x "$TARGET"
cd ~ && rm -rf "$TMP_DIR"
echo "ripgrep kuruldu: $TARGET"
