#!/bin/bash
set -euo pipefail
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"

# Termux chafa-static .deb kullaniyoruz (statik binary)
CHAFA_VERSION="1.18.3"
ARCH=$(uname -m)
case "$ARCH" in
    x86_64)  CHAFA_ARCH="x86_64" ;;
    i?86)    CHAFA_ARCH="i686" ;;
    aarch64) CHAFA_ARCH="aarch64" ;;
    *) echo "[HATA] Desteklenmeyen mimari: $ARCH"; exit 1 ;;
esac

# Termux mirror'dan statik .deb
CHAFA_URL="https://mirror.bouwhuis.network/termux/termux-main/pool/main/c/chafa-static/chafa-static_${CHAFA_VERSION}_${CHAFA_ARCH}.deb"
TARGET="/usr/local/bin/chafa"

echo ":: chafa ${CHAFA_VERSION} (${CHAFA_ARCH}) indiriliyor..."
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

if ! curl -fsSL --retry 3 --proto '=https' "$CHAFA_URL" -o chafa.deb; then
    echo "[HATA] chafa indirilemedi, apt fallback..."
    # apt fallback (Debian/Ubuntu)
    if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get install -y chafa >/dev/null 2>&1 && { echo "chafa kuruldu (apt)"; exit 0; }
    fi
    echo "[HATA] chafa kurulamadi" >&2
    exit 1
fi

# .deb ac
ar x chafa.deb
tar -xf data.tar.* 2>/dev/null || tar -xf data.tar.xz 2>/dev/null || true

CHAFA_BIN=$(find . -type f -name "chafa" -executable | head -1)
if [ -z "$CHAFA_BIN" ]; then
    echo "[HATA] chafa binary bulunamadi" >&2
    exit 1
fi

sudo cp -f "$CHAFA_BIN" "$TARGET"
sudo chmod +x "$TARGET"
cd ~ && rm -rf "$TMP_DIR"
echo "chafa kuruldu: $TARGET"
