#!/bin/bash
set -euo pipefail
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"

BTOP_VERSION="1.4.0"
ARCH=$(uname -m)
case "$ARCH" in
    x86_64)  BTOP_ARCH="x86_64" ;;
    i?86)    BTOP_ARCH="i686" ;;
    aarch64) BTOP_ARCH="aarch64" ;;
    *) echo "[HATA] Desteklenmeyen mimari: $ARCH"; exit 1 ;;
esac

BTOP_URL="https://github.com/aristocratos/btop/releases/download/v${BTOP_VERSION}/btop-${BTOP_ARCH}-linux-musl.tbz"
TARGET="/usr/local/bin/btop"
CONFIG_DIR="/usr/local/share/jps/btop"

echo ":: btop ${BTOP_VERSION} (${BTOP_ARCH}) indiriliyor..."
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

curl -fsSL --retry 3 --proto '=https' "$BTOP_URL" -o btop.tbz
tar -xjf btop.tbz
BTOP_BIN=$(find . -type f -name "btop" -executable | head -1)
if [ -z "$BTOP_BIN" ]; then echo "[HATA] btop binary bulunamadi"; exit 1; fi

sudo cp -f "$BTOP_BIN" "$TARGET"
sudo chmod +x "$TARGET"
cd ~ && rm -rf "$TMP_DIR"

# Jubatus temasi (turuncu)
sudo mkdir -p "$CONFIG_DIR"
sudo tee "$CONFIG_DIR/btop.conf" >/dev/null << 'CONF_EOF'
color_theme = "jubatus"
theme[main_bg] = "#1a1a1a"
theme[main_fg] = "#e0e0e0"
theme[title] = "#ff8c00"
theme[hi_fg] = "#ff8c00"
theme[selected_bg] = "#ff8c00"
theme[selected_fg] = "#000000"
theme[inactive_fg] = "#666666"
theme[proc_misc] = "#ff8c00"
theme[cpu_box] = "#ff8c00"
theme[mem_box] = "#ff8c00"
theme[net_box] = "#ff8c00"
theme[proc_box] = "#ff8c00"
theme[div_line] = "#444444"
theme[temp_start] = "#00ff00"
theme[temp_mid] = "#ffff00"
theme[temp_end] = "#ff0000"
theme[cpu_start] = "#00ff00"
theme[cpu_mid] = "#ffff00"
theme[cpu_end] = "#ff0000"
theme[free_start] = "#00ff00"
theme[free_mid] = "#ffff00"
theme[free_end] = "#ff0000"
theme[cached_start] = "#00aaff"
theme[cached_mid] = "#0088ff"
theme[cached_end] = "#0055ff"
theme[available_start] = "#ffaa00"
theme[available_mid] = "#ff8800"
theme[available_end] = "#ff5500"
theme[used_start] = "#ff5500"
theme[used_mid] = "#ff3300"
theme[used_end] = "#ff0000"
theme[download_start] = "#00ff00"
theme[download_mid] = "#00aa00"
theme[download_end] = "#005500"
theme[upload_start] = "#00aaff"
theme[upload_mid] = "#0088ff"
theme[upload_end] = "#0055ff"
CONF_EOF

# Kullanici config'ine kopyala
mkdir -p "$HOME/.config/btop"
cp -f "$CONFIG_DIR/btop.conf" "$HOME/.config/btop/btop.conf"

echo "btop (Jubatus temali) kuruldu: $TARGET"
