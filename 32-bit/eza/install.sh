#!/bin/bash
set -euo pipefail
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"

EZA_VERSION="0.20.13"
ARCH=$(uname -m)
case "$ARCH" in
    x86_64)  EZA_ARCH="x86_64-unknown-linux-musl" ;;
    i?86)    EZA_ARCH="i686-unknown-linux-musl" ;;
    aarch64) EZA_ARCH="aarch64-unknown-linux-musl" ;;
    *) echo "[HATA] Desteklenmeyen mimari: $ARCH"; exit 1 ;;
esac

EZA_URL="https://github.com/eza-community/eza/releases/download/v${EZA_VERSION}/eza_${EZA_ARCH}.tar.gz"
TARGET="/usr/local/bin/eza"

echo ":: eza ${EZA_VERSION} (${EZA_ARCH}) indiriliyor..."
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"
curl -fsSL --retry 3 --proto '=https' "$EZA_URL" -o eza.tar.gz
tar -xzf eza.tar.gz
EZA_BIN=$(find . -type f -name "eza" -executable | head -1)
[ -z "$EZA_BIN" ] && { echo "[HATA] eza binary bulunamadi"; exit 1; }
sudo cp -f "$EZA_BIN" "$TARGET"
sudo chmod +x "$TARGET"
cd ~ && rm -rf "$TMP_DIR"
echo "eza kuruldu: $TARGET"
