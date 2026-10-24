#!/bin/bash
set -euo pipefail
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"

# Gercek kullanici (sudo cagiran)
REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)
[ -z "$REAL_HOME" ] && REAL_HOME="$HOME"

# 1. Bagimliliklar: python3
if ! command -v python3 >/dev/null 2>&1; then
    echo "[HATA] python3 bulunamadi." >&2
    exit 1
fi

# 2. tkinter (GUI icin ZORUNLU) - sistem paketi
if ! python3 -c "import tkinter" 2>/dev/null; then
    echo ":: tkinter eksik, kuruluyor..."
    if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get install -y python3-tk >/dev/null 2>&1 || \
            { echo "[HATA] python3-tk kurulamadi." >&2; exit 1; }
    elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -S --noconfirm tk >/dev/null 2>&1 || \
            { echo "[HATA] tk kurulamadi." >&2; exit 1; }
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y python3-tkinter >/dev/null 2>&1 || \
            { echo "[HATA] python3-tkinter kurulamadi." >&2; exit 1; }
    elif command -v zypper >/dev/null 2>&1; then
        sudo zypper --non-interactive install python3-tk >/dev/null 2>&1 || \
            { echo "[HATA] python3-tk kurulamadi." >&2; exit 1; }
    elif command -v apk >/dev/null 2>&1; then
        sudo apk add --no-cache tk >/dev/null 2>&1 || \
            { echo "[HATA] tk kurulamadi." >&2; exit 1; }
    else
        echo "[HATA] Desteklenen paket yoneticisi yok." >&2
        exit 1
    fi
fi

# 3. Pillow (opsiyonel, Windows ikon icin)
python3 -c "import PIL" 2>/dev/null || pip3 install --user Pillow 2>/dev/null || true

# 4. Projeyi kopyala
TARGET_DIR="/usr/local/share/jps/xyronix-backup"
sudo mkdir -p "$TARGET_DIR"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ ! -d "$SCRIPT_DIR/src" ]; then
    echo "[HATA] src/ bulunamadi: $SCRIPT_DIR/src" >&2
    exit 1
fi

sudo cp -r "$SCRIPT_DIR/src/"* "$TARGET_DIR/"
sudo chmod +x "$TARGET_DIR/main.py" 2>/dev/null || true

# 5. Wrapper (terminal)
sudo tee /usr/local/bin/xyronix-backup >/dev/null << 'WRAPPER'
#!/bin/bash
exec python3 /usr/local/share/jps/xyronix-backup/main.py "$@"
WRAPPER
sudo chmod +x /usr/local/bin/xyronix-backup

# 6. .desktop (kullanici dizinine)
echo ":: Masaustu kisayolu olusturuluyor..."
ICON_PATH="$TARGET_DIR/xyronix-backup-logo.png"

DESKTOP_CONTENT="[Desktop Entry]
Name=Xyronix Backup V3 Pro
Comment=Xyronix Studios Delta Snapshot & Safe Restore Engine
Exec=python3 $TARGET_DIR/main.py
Icon=$ICON_PATH
Terminal=false
Type=Application
Categories=Utility;System;
StartupWMClass=xyronix-backup"

APPS_DIR="$REAL_HOME/.local/share/applications"
sudo mkdir -p "$APPS_DIR"
echo "$DESKTOP_CONTENT" | sudo tee "$APPS_DIR/xyronix-backup.desktop" >/dev/null
sudo chmod +x "$APPS_DIR/xyronix-backup.desktop"
sudo chown -R "$REAL_USER:$REAL_USER" "$APPS_DIR" 2>/dev/null || true

# Masaustu
for DESKTOP_DIR in "$REAL_HOME/Desktop" "$REAL_HOME/Masaüstü" "$REAL_HOME/Masaustu"; do
    if [ -d "$DESKTOP_DIR" ]; then
        echo "$DESKTOP_CONTENT" | sudo tee "$DESKTOP_DIR/xyronix-backup.desktop" >/dev/null
        sudo chmod +x "$DESKTOP_DIR/xyronix-backup.desktop"
        sudo chown "$REAL_USER:$REAL_USER" "$DESKTOP_DIR/xyronix-backup.desktop" 2>/dev/null || true
        sudo -u "$REAL_USER" gio set "$DESKTOP_DIR/xyronix-backup.desktop" metadata::trusted true 2>/dev/null || true
        break
    fi
done

echo "xyronix-backup kuruldu: /usr/local/bin/xyronix-backup"
