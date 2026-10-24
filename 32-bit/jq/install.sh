#!/bin/bash
set -euo pipefail
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"

JQ_VERSION="1.7.1"
ARCH=$(uname -m)
case "$ARCH" in
    x86_64)  JQ_ARCH="jq-linux-amd64" ;;
    i?86)    JQ_ARCH="jq-linux-386" ;;
    aarch64) JQ_ARCH="jq-linux-arm64" ;;
    *) echo "[HATA] Desteklenmeyen mimari: $ARCH"; exit 1 ;;
esac

JQ_URL="https://github.com/jqlang/jq/releases/download/jq-${JQ_VERSION}/${JQ_ARCH}"
TARGET="/usr/local/bin/jq"

echo ":: jq ${JQ_VERSION} (${JQ_ARCH}) indiriliyor..."
curl -fsSL --retry 3 --proto '=https' "$JQ_URL" -o /tmp/jq.bin
sudo cp -f /tmp/jq.bin "$TARGET"
sudo chmod +x "$TARGET"
rm -f /tmp/jq.bin
echo "jq kuruldu: $TARGET"
