#!/bin/bash
set -euo pipefail
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"

# Gercek kullanici (sudo cagiran)
REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)
[ -z "$REAL_HOME" ] && REAL_HOME="$HOME"

# 1. Bagimliliklar
if ! command -v python3 >/dev/null 2>&1; then
    echo "[HATA] python3 bulunamadi." >&2
    exit 1
fi

# 2. Pillow (GUI icin)
python3 -c "import PIL" 2>/dev/null || pip3 install --user Pillow 2>/dev/null || true

# 3. Projeyi kopyala
TARGET_DIR="/usr/local/share/jps/xyronix-backup"
sudo mkdir -p "$TARGET_DIR"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ ! -d "$SCRIPT_DIR/src" ]; then
    echo "[HATA] src/ bulunamadi: $SCRIPT_DIR/src" >&2
    exit 1
fi

sudo cp -r "$SCRIPT_DIR/src/"* "$TARGET_DIR/"
sudo chmod +x "$TARGET_DIR/main.py" 2>/dev/null || true

# 4. Wrapper (terminal)
sudo tee /usr/local/bin/xyronix-backup >/dev/null << 'WRAPPER'
#!/bin/bash
exec python3 /usr/local/share/jps/xyronix-backup/main.py "$@"
WRAPPER
sudo chmod +x /usr/local/bin/xyronix-backup

# 5. .desktop dosyasini KULLANICI dizinine yaz (root degil)
echo ":: Masaustu kisayolu olusturuluyor..."
ICON_PATH="$TARGET_DIR/xyronix-backup-logo.png"

# Ikonu sistem ikon dizinine de kopyala (Wayland/X11 icin)
sudo mkdir -p /usr/share/icons/hicolor/256x256/apps
sudo cp -f "$ICON_PATH" /usr/share/icons/hicolor/256x256/apps/xyronix-backup.png 2>/dev/null || true

# .desktop icerigi
DESKTOP_CONTENT="[Desktop Entry]
Name=Xyronix Backup V3 Pro
Comment=Xyronix Studios Delta Snapshot & Safe Restore Engine
Exec=python3 $TARGET_DIR/main.py
Icon=$ICON_PATH
Terminal=false
Type=Application
Categories=Utility;System;
StartupWMClass=xyronix-backup"

# Kullanici applications dizini
APPS_DIR="$REAL_HOME/.local/share/applications"
sudo mkdir -p "$APPS_DIR"
echo "$DESKTOP_CONTENT" | sudo tee "$APPS_DIR/xyronix-backup.desktop" >/dev/null
sudo chmod +x "$APPS_DIR/xyronix-backup.desktop"
sudo chown -R "$REAL_USER:$REAL_USER" "$APPS_DIR" 2>/dev/null || true

# Masaustu (Desktop/Masaustu)
for DESKTOP_DIR in "$REAL_HOME/Desktop" "$REAL_HOME/Masaüstü" "$REAL_HOME/Masaustu"; do
    if [ -d "$DESKTOP_DIR" ]; then
        echo "$DESKTOP_CONTENT" | sudo tee "$DESKTOP_DIR/xyronix-backup.desktop" >/dev/null
        sudo chmod +x "$DESKTOP_DIR/xyronix-backup.desktop"
        sudo chown "$REAL_USER:$REAL_USER" "$DESKTOP_DIR/xyronix-backup.desktop" 2>/dev/null || true
        # GNOME icin guvenilir yap
        sudo -u "$REAL_USER" gio set "$DESKTOP_DIR/xyronix-backup.desktop" metadata::trusted true 2>/dev/null || true
        echo ":: Masaustu kisayolu: $DESKTOP_DIR/xyronix-backup.desktop"
        break
    fi
done

echo ":: Applications: $APPS_DIR/xyronix-backup.desktop"
echo "xyronix-backup kuruldu: /usr/local/bin/xyronix-backup"
