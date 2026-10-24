#!/bin/bash
set -euo pipefail
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"

# chafa statik binary release
CHAFA_VERSION="1.14.5"
ARCH=$(uname -m)
case "$ARCH" in
    x86_64)  CHAFA_ARCH="x86_64" ;;
    i?86)    CHAFA_ARCH="i686" ;;
    aarch64) CHAFA_ARCH="aarch64" ;;
    *) echo "[HATA] Desteklenmeyen mimari: $ARCH"; exit 1 ;;
esac

CHAFA_URL="https://github.com/hpjansson/chafa/releases/download/${CHAFA_VERSION}/chafa-${CHAFA_ARCH}.tar.gz"
TARGET="/usr/local/bin/chafa"

echo ":: chafa ${CHAFA_VERSION} (${CHAFA_ARCH}) indiriliyor..."
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"
curl -fsSL --retry 3 --proto '=https' "$CHAFA_URL" -o chafa.tar.gz
tar -xzf chafa.tar.gz
CHAFA_BIN=$(find . -type f -name "chafa" -executable | head -1)
[ -z "$CHAFA_BIN" ] && { echo "[HATA] chafa binary bulunamadi"; exit 1; }
sudo cp -f "$CHAFA_BIN" "$TARGET"
sudo chmod +x "$TARGET"
cd ~ && rm -rf "$TMP_DIR"
echo "chafa kuruldu: $TARGET"
