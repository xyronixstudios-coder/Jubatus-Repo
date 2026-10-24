import os
import sys
import platform
import subprocess
import shutil
from pathlib import Path

def ensure_pillow():
    try:
        from PIL import Image
        return Image
    except ImportError:
        print("[*] Windows simge dönüşümü için Pillow kütüphanesi yükleniyor...")
        subprocess.run([sys.executable, "-m", "pip", "install", "Pillow"], check=True)
        from PIL import Image
        return Image

def setup_linux(current_dir):
    main_py = current_dir / "main.py"
    logo_png = current_dir / "xyronix-backup-logo.png"
    
    # Simgeyi sistem ikon dizinine kopyala ki Wayland/X11 her ortamda bulabilsin
    icons_dir = Path.home() / ".local" / "share" / "icons"
    icons_dir.mkdir(parents=True, exist_ok=True)
    system_icon_path = icons_dir / "xyronix-backup-logo.png"
    if logo_png.exists():
        shutil.copy(logo_png, system_icon_path)

    icon_target = str(system_icon_path if system_icon_path.exists() else logo_png)

    desktop_file_content = f"""[Desktop Entry]
Name=Xyronix Backup V3 Pro
Comment=Xyronix Studios Delta Snapshot & Safe Restore Engine
Exec=python3 "{main_py}"
Icon={icon_target}
Terminal=false
Type=Application
Categories=Utility;System;
StartupWMClass=xyronix-backup
"""

    apps_dir = Path.home() / ".local" / "share" / "applications"
    apps_dir.mkdir(parents=True, exist_ok=True)
    
    desktop_file_path = apps_dir / "xyronix-backup.desktop"
    with open(desktop_file_path, "w", encoding="utf-8") as f:
        f.write(desktop_file_content)
    os.chmod(desktop_file_path, 0o755)

    desktop_path = Path.home() / "Desktop"
    if not desktop_path.exists():
        desktop_path = Path.home() / "Masaüstü"
    
    if desktop_path.exists():
        dest_desktop = desktop_path / "xyronix-backup.desktop"
        with open(dest_desktop, "w", encoding="utf-8") as f:
            f.write(desktop_file_content)
        os.chmod(dest_desktop, 0o755)
        
        # Anahtar / dişli simgesi (güvenilmeyen başlatıcı) sorununu önlemek için güvenilir yap
        try:
            subprocess.run(["gio", "set", str(dest_desktop), "metadata::trusted", "true"], check=False)
        except Exception:
            pass

    print("[✔] Linux (X11/Wayland) kurulumu tamamlandı! Özel Xyronix logosuyla masaüstüne eklendi.")

def setup_windows(current_dir):
    Image = ensure_pillow()
    main_py = current_dir / "main.py"
    logo_png = current_dir / "xyronix-backup-logo.png"
    logo_ico = current_dir / "xyronix-backup-logo.ico"

    # Windows .lnk kısayolları için PNG'yi ICO formatına dönüştür
    if logo_png.exists():
        try:
            img = Image.open(logo_png)
            img.save(logo_ico, format='ICO', sizes=[(256, 256), (128, 128), (64, 64), (32, 32), (16, 16)])
        except Exception as e:
            print(f"[!] ICO dönüştürme uyarısı: {e}")

    icon_to_use = str(logo_ico if logo_ico.exists() else logo_png)

    desktop = os.path.join(os.path.expanduser("~"), "Desktop")
    shortcut_path = os.path.join(desktop, "Xyronix Backup V3 Pro.lnk")
    
    ps_script = f"""
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut("{shortcut_path}")
    $Shortcut.TargetPath = "python"
    $Shortcut.Arguments = '"{main_py}"'
    $Shortcut.WorkingDirectory = "{current_dir}"
    $Shortcut.IconLocation = "{icon_to_use}"
    $Shortcut.Save()
    """
    
    ps_path = current_dir / "create_shortcut.ps1"
    with open(ps_path, "w", encoding="utf-8") as f:
        f.write(ps_script)
        
    subprocess.run(["powershell", "-ExecutionPolicy", "Bypass", "-File", str(ps_path)], check=True)
    if ps_path.exists():
        os.remove(ps_path)
        
    print("[✔] Windows kurulumu tamamlandı! Özel simgeli kısayol masaüstüne eklendi.")

if __name__ == "__main__":
    current_dir = Path(__file__).resolve().parent
    system = platform.system()
    
    print(f"Xyronix Kurulum Sihirbazı Başlatıldı... İşletim Sistemi: {system}")
    
    if system == "Linux":
        setup_linux(current_dir)
    elif system == "Windows":
        setup_windows(current_dir)
    else:
        print(f"[!] Desteklenmeyen işletim sistemi: {system}")
