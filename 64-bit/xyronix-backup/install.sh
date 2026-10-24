#!/bin/bash
set -euo pipefail
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"

# 1. Bagimliliklar
for cmd in python3 pip3; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "[HATA] $cmd bulunamadi. Lutfen 'sudo apt install python3 python3-pip' calistir." >&2
        exit 1
    fi
done

# 2. Pillow (Windows simge donusumu icin, Linux'ta opsiyonel)
python3 -c "import PIL" 2>/dev/null || pip3 install --user Pillow 2>/dev/null || true

# 3. Projeyi kopyala
TARGET_DIR="/usr/local/share/jps/xyronix-backup"
sudo mkdir -p "$TARGET_DIR"

# GitHub'dan indir (veya repodan)
REPO_URL="https://github.com/xyronixstudios-coder/Jubatus-Repo/raw/main/packages/xyronix-backup"
# Alternatif: repodaki dosyalari kopyala (eger paket icinde varsa)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -d "$SCRIPT_DIR/src" ]; then
    # Paket icinde src/ varsa onu kullan
    sudo cp -r "$SCRIPT_DIR/src/"* "$TARGET_DIR/"
else
    # GitHub'dan indir
    for f in main.py core.py install.py xyronix-backup-logo.png; do
        curl -fsSL "$REPO_URL/$f" -o "/tmp/xyronix-$f" || { echo "[HATA] $f indirilemedi"; exit 1; }
        sudo cp "/tmp/xyronix-$f" "$TARGET_DIR/$f"
        rm -f "/tmp/xyronix-$f"
    done
fi

# 4. Calistirilabilir yap
sudo chmod +x "$TARGET_DIR/main.py" 2>/dev/null || true

# 5. Wrapper
sudo tee /usr/local/bin/xyronix-backup >/dev/null << 'WRAPPER'
#!/bin/bash
exec python3 /usr/local/share/jps/xyronix-backup/main.py "$@"
WRAPPER
sudo chmod +x /usr/local/bin/xyronix-backup

# 6. Masaustu kisayolu (opsiyonel)
if [ -f "$TARGET_DIR/install.py" ]; then
    ( cd "$TARGET_DIR" && python3 install.py ) || true
fi

echo "xyronix-backup kuruldu: /usr/local/bin/xyronix-backup"
