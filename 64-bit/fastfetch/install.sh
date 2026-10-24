#!/bin/bash
set -euo pipefail
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"

FF_VERSION="2.69.0"
FF_URL="https://github.com/fastfetch-cli/fastfetch/releases/download/${FF_VERSION}/fastfetch-linux-amd64.tar.gz"

TARGET="/usr/local/bin/fastfetch"
REAL_BIN="/usr/local/bin/fastfetch.real"
CONFIG_DIR="/usr/local/share/jps/fastfetch"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
    echo "[HATA] curl veya wget bulunamadi." >&2
    exit 1
fi

echo ":: Fastfetch ${FF_VERSION} indiriliyor..."
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

if command -v curl >/dev/null 2>&1; then
    curl -fsSL --retry 3 --proto '=https' "$FF_URL" -o ff.tar.gz
else
    wget -q "$FF_URL" -O ff.tar.gz
fi

tar -xzf ff.tar.gz

# SADECE ELF binary sec (shell script degil!)
FF_BIN=""
while IFS= read -r f; do
    if file "$f" | grep -q "ELF"; then
        FF_BIN="$f"
        break
    fi
done < <(find . -type f -name "fastfetch")

if [ -z "$FF_BIN" ] || [ ! -f "$FF_BIN" ]; then
    echo "[HATA] fastfetch ELF binary bulunamadi." >&2
    echo "Bulunan dosyalar:" >&2
    find . -type f -name "fastfetch*" -exec file {} \; >&2
    exit 1
fi

echo ":: Binary: $FF_BIN"
sudo cp -f "$FF_BIN" "$REAL_BIN"
sudo chmod +x "$REAL_BIN"
cd ~
rm -rf "$TMP_DIR"

# Dogrulama
if ! file "$REAL_BIN" | grep -q "ELF"; then
    echo "[HATA] Kopyalanan dosya ELF degil!" >&2
    file "$REAL_BIN" >&2
    exit 1
fi

# Config ve logo
sudo mkdir -p "$CONFIG_DIR"
sudo cp -f "$SCRIPT_DIR/jubatus-logo.txt" "$CONFIG_DIR/jubatus-logo.txt"
sudo cp -f "$SCRIPT_DIR/config.jsonc" "$CONFIG_DIR/config.jsonc"

# Wrapper
sudo tee "$TARGET" >/dev/null << 'WRAPPER_EOF'
#!/bin/bash
exec /usr/local/bin/fastfetch.real --config /usr/local/share/jps/fastfetch/config.jsonc "$@"
WRAPPER_EOF
sudo chmod +x "$TARGET"

echo "fastfetch (Jubatus temali) kuruldu: $TARGET"
echo "Surum kontrol: $($REAL_BIN --version 2>&1 | head -1)"
