#!/bin/bash
set -euo pipefail
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"

ZOX_VERSION="0.9.6"
ARCH=$(uname -m)
case "$ARCH" in
    x86_64)  ZOX_ARCH="x86_64-unknown-linux-musl" ;;
    i?86)    ZOX_ARCH="i686-unknown-linux-musl" ;;
    aarch64) ZOX_ARCH="aarch64-unknown-linux-musl" ;;
    *) echo "[HATA] Desteklenmeyen mimari: $ARCH"; exit 1 ;;
esac

ZOX_URL="https://github.com/ajeetdsouza/zoxide/releases/download/v${ZOX_VERSION}/zoxide-${ZOX_VERSION}-${ZOX_ARCH}.tar.gz"
TARGET="/usr/local/bin/zoxide"

echo ":: zoxide ${ZOX_VERSION} (${ZOX_ARCH}) indiriliyor..."
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"
curl -fsSL --retry 3 --proto '=https' "$ZOX_URL" -o zoxide.tar.gz
tar -xzf zoxide.tar.gz
ZOX_BIN=$(find . -type f -name "zoxide" -executable | head -1)
[ -z "$ZOX_BIN" ] && { echo "[HATA] zoxide binary bulunamadi"; exit 1; }
sudo cp -f "$ZOX_BIN" "$TARGET"
sudo chmod +x "$TARGET"
cd ~ && rm -rf "$TMP_DIR"
echo "zoxide kuruldu: $TARGET"
