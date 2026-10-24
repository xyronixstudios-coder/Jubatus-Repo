#!/bin/bash
set -euo pipefail
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"

# 1. Bagimliliklar
if ! command -v go >/dev/null 2>&1; then
    echo "[HATA] go bulunamadi. Lutfen 'sudo apt install golang' calistir." >&2
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$SCRIPT_DIR/src"

if [ ! -d "$SRC_DIR" ]; then
    echo "[HATA] src/ bulunamadi: $SRC_DIR" >&2
    exit 1
fi

# 2. Build
echo ":: Kivi build ediliyor..."
TMP_BUILD=$(mktemp -d)
cd "$SRC_DIR"
go build -o "$TMP_BUILD/kivi" ./cmd/kivi 2>/dev/null || \
    go build -o "$TMP_BUILD/kivi" . 2>/dev/null || \
    go build -o "$TMP_BUILD/kivi" ./...

if [ ! -f "$TMP_BUILD/kivi" ]; then
    echo "[HATA] kivi build edilemedi." >&2
    exit 1
fi

# 3. Kur
sudo cp -f "$TMP_BUILD/kivi" /usr/local/bin/kivi
sudo chmod +x /usr/local/bin/kivi
cd ~
rm -rf "$TMP_BUILD"

# 4. Docs (README, LICENSE)
TARGET_DIR="/usr/local/share/jps/xyronix-kivi"
sudo mkdir -p "$TARGET_DIR"
sudo cp -f "$SRC_DIR/README.md" "$TARGET_DIR/" 2>/dev/null || true
sudo cp -f "$SRC_DIR/README.tr.md" "$TARGET_DIR/" 2>/dev/null || true
sudo cp -f "$SRC_DIR/LICENSE" "$TARGET_DIR/" 2>/dev/null || true

echo "xyronix-kivi (kivi) kuruldu: /usr/local/bin/kivi"
echo "Calistir: kivi --help"
