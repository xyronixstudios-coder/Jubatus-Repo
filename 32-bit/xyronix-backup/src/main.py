import os
import shutil
from pathlib import Path
from datetime import datetime
import json
import tkinter as tk
from tkinter import ttk, filedialog, messagebox
import threading
import time

class XyronixBackupV3Pro:
    def __init__(self, root):
        self.root = root
        self.root.title("Xyronix Backup — Simple. Safe. Yours. (V3 Pro)")
        self.root.geometry("540x720")
        self.root.config(bg="#0f172a")

        # X11 ve Wayland'de masaüstü kısayoluyla eşleşmesi için kritik sınıf tanımı
        try:
            self.root.wm_class("xyronix-backup", "XyronixBackup")
        except Exception:
            pass

        # Logoyu pencere ikonu olarak ayarla
        try:
            icon_path = Path(__file__).parent / "xyronix-backup-logo.png"
            if icon_path.exists():
                self.logo_img = tk.PhotoImage(file=str(icon_path))
                self.root.iconphoto(True, self.logo_img)
        except Exception as e:
            print(f"Logo yüklenemedi: {e}")

        home = Path.home()
        def find_dir(possible_names):
            for name in possible_names:
                p = home / name
                if p.exists() and p.is_dir():
                    return p
            return home / possible_names[0]

        self.available_dirs = {
            "Masaüstü": find_dir(["Masaüstü", "Desktop"]),
            "Belgeler": find_dir(["Belgeler", "Documents"]),
            "Müzik": find_dir(["Müzik", "Music"]),
            "Resimler": find_dir(["Resimler", "Pictures"]),
            "Videolar": find_dir(["Videolar", "Videos"]),
            "İndirilenler": find_dir(["İndirilenler", "Downloads"])
        }

        self.usb_path = ""
        self.vars = {}
        self.total_bytes = 0
        
        self.is_running = False
        self.is_paused = False
        self.is_cancelled = False

        self.create_widgets()

    def create_widgets(self):
        top_bar = tk.Frame(self.root, bg="#0f172a")
        top_bar.pack(fill="x", padx=10, pady=(10, 0))

        brand_label = tk.Label(top_bar, text="Xyronix Backup V3 Pro", font=("Segoe UI", 11, "bold"), fg="#38bdf8", bg="#0f172a")
        brand_label.pack(side="left")

        self.about_btn = tk.Button(top_bar, text="ℹ️ Hakkında", command=self.show_about_popup, 
                                   bg="#38bdf8", fg="#000000", font=("Segoe UI", 8, "bold"), relief="flat", cursor="hand2", padx=8, pady=2)
        self.about_btn.pack(side="right")

        style = ttk.Style()
        style.theme_use('default')
        style.configure('TNotebook', background='#0f172a', borderwidth=0)
        style.configure('TNotebook.Tab', background='#1e293b', foreground='#f8fafc', padding=[15, 8], font=('Segoe UI', 9, 'bold'))
        style.map('TNotebook.Tab', background=[('selected', '#38bdf8')], foreground=[('selected', '#0f172a')])

        self.notebook = ttk.Notebook(self.root)
        self.notebook.pack(fill='both', expand=True, padx=10, pady=10)

        self.tab_backup = tk.Frame(self.notebook, bg="#0f172a")
        self.notebook.add(self.tab_backup, text="  💾 Yedekle  ")

        self.tab_restore = tk.Frame(self.notebook, bg="#0f172a")
        self.notebook.add(self.tab_restore, text="  ♻️ Geri Yükle  ")

        self.setup_backup_tab()
        self.setup_restore_tab()

    def show_about_popup(self):
        about_window = tk.Toplevel(self.root)
        about_window.title("Hakkında")
        about_window.geometry("320x200")
        about_window.config(bg="#0f172a")
        about_window.resizable(False, False)
        about_window.transient(self.root)
        about_window.grab_set()

        title_lbl = tk.Label(about_window, text="Xyronix Backup", font=("Segoe UI", 13, "bold"), fg="#f8fafc", bg="#0f172a")
        title_lbl.pack(pady=(20, 5))

        dev_lbl = tk.Label(about_window, text="Yapımcı: Xyronix Studios - Eren Mut", font=("Segoe UI", 9), fg="#94a3b8", bg="#0f172a")
        dev_lbl.pack(pady=2)

        ver_lbl = tk.Label(about_window, text="Sürüm: V3 Pro", font=("Segoe UI", 9, "bold"), fg="#38bdf8", bg="#0f172a")
        ver_lbl.pack(pady=2)

        close_btn = tk.Button(about_window, text="Kapat", command=about_window.destroy, 
                              bg="#38bdf8", fg="#000000", font=("Segoe UI", 9, "bold"), relief="flat", cursor="hand2", padx=15, pady=4)
        close_btn.pack(pady=15)

    def setup_backup_tab(self):
        header_frame = tk.Frame(self.tab_backup, bg="#0f172a")
        header_frame.pack(fill="x", padx=10, pady=(10, 5))

        title_label = tk.Label(header_frame, text="AKILLI SNAPSHOT YEDEKLEME V3", font=("Segoe UI", 14, "bold"), fg="#f8fafc", bg="#0f172a")
        title_label.pack(anchor="w")
        sub_label = tk.Label(header_frame, text="Xyronix Studios — Delta Snapshot & Safe Restore Engine", font=("Segoe UI", 8), fg="#38bdf8", bg="#0f172a")
        sub_label.pack(anchor="w")

        frame = tk.LabelFrame(self.tab_backup, text=" Yedeklenecek Klasörler ", fg="#94a3b8", bg="#1e293b", 
                              font=("Segoe UI", 9, "bold"), bd=1, relief="solid")
        frame.pack(fill="x", padx=10, pady=5)

        for name in self.available_dirs.keys():
            default_val = True if name in ["Masaüstü", "Belgeler", "Resimler", "İndirilenler"] else False
            var = tk.BooleanVar(value=default_val)
            self.vars[name] = var
            
            chk = tk.Checkbutton(frame, text=name, variable=var, fg="#f1f5f9", bg="#1e293b", 
                                 selectcolor="#0f172a", activebackground="#1e293b", activeforeground="#f1f5f9", 
                                 font=("Segoe UI", 9), command=self.update_stats)
            chk.pack(anchor="w", padx=10, pady=3)

        usb_frame = tk.Frame(self.tab_backup, bg="#1e293b", bd=1, relief="solid")
        usb_frame.pack(fill="x", padx=10, pady=5)

        self.usb_btn = tk.Button(usb_frame, text="📁 Hedef Klasör / USB Seç", command=self.select_usb, 
                                 bg="#38bdf8", fg="#000000", font=("Segoe UI", 9, "bold"), relief="flat", cursor="hand2", padx=10, pady=4)
        self.usb_btn.pack(fill="x", padx=8, pady=6)

        self.usb_label = tk.Label(usb_frame, text="Seçilen Hedef: Henüz seçilmedi", fg="#f43f5e", bg="#1e293b", font=("Segoe UI", 8))
        self.usb_label.pack(anchor="w", padx=8, pady=(0, 6))

        stats_frame = tk.Frame(self.tab_backup, bg="#0f172a")
        stats_frame.pack(fill="x", padx=10, pady=5)

        self.stats_label = tk.Label(stats_frame, text="Hesaplanıyor...", fg="#fbbf24", bg="#0f172a", font=("Segoe UI", 9, "bold"))
        self.stats_label.pack(anchor="w")

        progress_frame = tk.Frame(self.tab_backup, bg="#0f172a")
        progress_frame.pack(fill="x", padx=10, pady=5)

        self.progress_var = tk.DoubleVar()
        self.progress_bar = ttk.Progressbar(progress_frame, orient="horizontal", length=480, mode="determinate", variable=self.progress_var)
        self.progress_bar.pack(fill="x", pady=3)

        self.status_label = tk.Label(progress_frame, text="Durum: Bekleniyor...", fg="#94a3b8", bg="#0f172a", font=("Segoe UI", 8))
        self.status_label.pack(anchor="w")

        self.backup_btn = tk.Button(self.tab_backup, text="YEDEKLEMEYİ BAŞLAT", command=self.start_backup_thread, 
                                    bg="#22c55e", fg="#000000", font=("Segoe UI", 10, "bold"), relief="flat", state="disabled", cursor="hand2", pady=6)
        self.backup_btn.pack(fill="x", padx=10, pady=5)

        control_frame = tk.Frame(self.tab_backup, bg="#0f172a")
        control_frame.pack(fill="x", padx=10, pady=5)

        self.pause_btn = tk.Button(control_frame, text="⏸ DURAKLAT", command=self.toggle_pause, 
                                   bg="#eab308", fg="#000000", font=("Segoe UI", 8, "bold"), relief="flat", state="disabled", cursor="hand2")
        self.pause_btn.pack(side="left", expand=True, fill="x", padx=(0, 3))

        self.cancel_btn = tk.Button(control_frame, text="⏹ İPTAL ET", command=self.cancel_task, 
                                    bg="#ef4444", fg="#000000", font=("Segoe UI", 8, "bold"), relief="flat", state="disabled", cursor="hand2")
        self.cancel_btn.pack(side="right", expand=True, fill="x", padx=(3, 0))

        self.update_stats()

    def setup_restore_tab(self):
        header_frame = tk.Frame(self.tab_restore, bg="#0f172a")
        header_frame.pack(fill="x", padx=10, pady=(10, 5))

        title_label = tk.Label(header_frame, text="SİSTEMİ GERİ YÜKLE", font=("Segoe UI", 14, "bold"), fg="#f8fafc", bg="#0f172a")
        title_label.pack(anchor="w")
        sub_label = tk.Label(header_frame, text="Xyronix Studios — İstediğiniz tarihli yedeği tam olarak geri yükleyin.", font=("Segoe UI", 8), fg="#38bdf8", bg="#0f172a")
        sub_label.pack(anchor="w")

        target_frame = tk.Frame(self.tab_restore, bg="#1e293b", bd=1, relief="solid")
        target_frame.pack(fill="x", padx=10, pady=10)

        self.restore_target_btn = tk.Button(target_frame, text="📁 Yedeklerin Olduğu USB / Klasörü Seç", command=self.select_restore_source, 
                                            bg="#38bdf8", fg="#000000", font=("Segoe UI", 9, "bold"), relief="flat", cursor="hand2", padx=10, pady=6)
        self.restore_target_btn.pack(fill="x", padx=8, pady=8)

        self.restore_source_label = tk.Label(target_frame, text="Seçilen Kaynak: Henüz seçilmedi", fg="#f43f5e", bg="#1e293b", font=("Segoe UI", 8))
        self.restore_source_label.pack(anchor="w", padx=8, pady=(0, 8))

        list_frame = tk.LabelFrame(self.tab_restore, text=" Mevcut Yedek Noktaları (Tarihler) ", fg="#94a3b8", bg="#1e293b", 
                                   font=("Segoe UI", 9, "bold"), bd=1, relief="solid")
        list_frame.pack(fill="both", expand=True, padx=10, pady=5)

        self.backup_listbox = tk.Listbox(list_frame, bg="#0f172a", fg="#f1f5f9", font=("Segoe UI", 9), selectbackground="#38bdf8", selectforeground="#0f172a", bd=0)
        self.backup_listbox.pack(fill="both", expand=True, padx=8, pady=8)

        self.restore_btn = tk.Button(self.tab_restore, text="SEÇİLEN YEDEĞİ GERİ YÜKLE", command=self.start_restore_thread, 
                                     bg="#22c55e", fg="#000000", font=("Segoe UI", 10, "bold"), relief="flat", state="disabled", cursor="hand2", pady=8)
        self.restore_btn.pack(fill="x", padx=10, pady=10)

        self.restore_source_path = ""

    def get_dir_size(self, path):
        total = 0
        if path.exists() and path.is_dir():
            for dirpath, dirnames, filenames in os.walk(path):
                for f in filenames:
                    fp = os.path.join(dirpath, f)
                    try:
                        total += os.path.getsize(fp)
                    except OSError:
                        continue
        return total

    def format_size(self, size_bytes):
        if size_bytes < 1024 * 1024 * 1024:
            return f"{size_bytes / (1024**2):.2f} MB"
        return f"{size_bytes / (1024**3):.2f} GB"

    def update_stats(self):
        if self.is_running:
            return
        total_bytes = 0
        for name, var in self.vars.items():
            if var.get():
                total_bytes += self.get_dir_size(self.available_dirs[name])
        
        self.total_bytes = total_bytes
        self.stats_label.config(text=f"📦 Toplam Seçilen Boyut: {self.format_size(total_bytes)}")

    def select_usb(self):
        if self.is_running:
            return
        dir_path = filedialog.askdirectory(title="Yedekleme Hedefini Seçin")
        if dir_path:
            self.usb_path = dir_path
            display_path = (dir_path[:38] + '...') if len(dir_path) > 40 else dir_path
            self.usb_label.config(text=f"Seçilen Hedef: {display_path}", fg="#22c55e")
            self.backup_btn.config(state="normal")

    def select_restore_source(self):
        dir_path = filedialog.askdirectory(title="XyronixBackup Klasörünün Olduğu Yeri Seçin")
        if dir_path:
            self.restore_source_path = dir_path
            display_path = (dir_path[:38] + '...') if len(dir_path) > 40 else dir_path
            self.restore_source_label.config(text=f"Seçilen Kaynak: {display_path}", fg="#22c55e")
            
            self.backup_listbox.delete(0, tk.END)
            xyronix_dir = Path(dir_path) / "XyronixBackup"
            if xyronix_dir.exists() and xyronix_dir.is_dir():
                subdirs = sorted([d.name for d in xyronix_dir.iterdir() if d.is_dir()], reverse=True)
                for sd in subdirs:
                    self.backup_listbox.insert(tk.END, sd)
                if subdirs:
                    self.restore_btn.config(state="normal")
                else:
                    messagebox.showinfo("Bilgi", "Seçilen dizinde hiç yedek noktası bulunamadı!")
            else:
                messagebox.showerror("Hata", "Bu dizinde 'XyronixBackup' klasörü bulunamadı!")

    def start_backup_thread(self):
        if not self.usb_path or self.is_running:
            return

        if self.total_bytes == 0:
            messagebox.showwarning("Uyarı", "Yedeklenecek hiç dosya seçmediniz!")
            return

        self.is_running = True
        self.is_paused = False
        self.is_cancelled = False

        self.backup_btn.config(state="disabled", text="YEDEKLENİYOR...", fg="#000000")
        self.usb_btn.config(state="disabled")
        self.pause_btn.config(state="normal", text="⏸ DURAKLAT", fg="#000000")
        self.cancel_btn.config(state="normal", fg="#000000")

        threading.Thread(target=self.execute_smart_backup, daemon=True).start()

    def start_restore_thread(self):
        selected_indices = self.backup_listbox.curselection()
        if not selected_indices:
            messagebox.showwarning("Uyarı", "Lütfen listeden geri yüklemek istediğiniz bir yedek tarihi seçin!")
            return

        backup_name = self.backup_listbox.get(selected_indices[0])
        backup_dir = Path(self.restore_source_path) / "XyronixBackup" / backup_name

        if not backup_dir.exists():
            messagebox.showerror("Hata", "Yedek klasörü bulunamadı!")
            return

        if not messagebox.askyesno("Onay", f"'{backup_name}' yedeği bilgisayara geri yüklenecek. Mevcut dosyalarınız güncellenecek. Emin misiniz?"):
            return

        self.is_running = True
        self.restore_btn.config(state="disabled", text="GERİ YÜKLENİYOR...", fg="#000000")

        threading.Thread(target=self.execute_restore, args=(backup_dir,), daemon=True).start()

    def toggle_pause(self):
        if self.is_paused:
            self.is_paused = False
            self.pause_btn.config(text="⏸ DURAKLAT", bg="#eab308", fg="#000000")
            self.status_label.config(text="Durum: Devam ediyor...")
        else:
            self.is_paused = True
            self.pause_btn.config(text="▶ DEVAM ET", bg="#38bdf8", fg="#000000")
            self.status_label.config(text="Durum: ⏸ Duraklatıldı")

    def cancel_task(self):
        self.is_cancelled = True
        self.is_paused = False
        self.status_label.config(text="Durum: İptal ediliyor...")

    def update_progress_ui(self, percent, file_name, action="Kopyalanıyor"):
        self.progress_var.set(percent)
        self.status_label.config(text=f"{action} (%{int(percent)}): {file_name}")

    def execute_smart_backup(self):
        timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M")
        backup_path = Path(self.usb_path) / "XyronixBackup" / timestamp
        xyronix_base = Path(self.usb_path) / "XyronixBackup"
        manifest_path = xyronix_base / "manifest.json"

        old_manifest = {}
        if manifest_path.exists():
            try:
                with open(manifest_path, "r", encoding="utf-8") as f:
                    old_manifest = json.load(f)
            except Exception:
                old_manifest = {}

        existing_backups = sorted([d for d in xyronix_base.iterdir() if d.is_dir() and d.name != timestamp], reverse=True)
        latest_backup_dir = existing_backups[0] if existing_backups else None

        new_manifest = {}

        try:
            os.makedirs(backup_path, exist_ok=True)
            
            tasks_to_copy = []
            tasks_to_link = []

            for name, var in self.vars.items():
                if var.get():
                    src = self.available_dirs[name]
                    if src.exists() and src.is_dir():
                        for dirpath, dirnames, filenames in os.walk(src):
                            for f in filenames:
                                fp = Path(dirpath) / f
                                try:
                                    stat = fp.stat()
                                    fsize = stat.st_size
                                    fmtime = stat.st_mtime
                                    rel_path = str(fp.relative_to(src.parent))
                                    
                                    new_manifest[rel_path] = {"size": fsize, "mtime": fmtime}

                                    is_changed = True
                                    if rel_path in old_manifest:
                                        if old_manifest[rel_path]["size"] == fsize and old_manifest[rel_path]["mtime"] == fmtime:
                                            is_changed = False

                                    if is_changed:
                                        tasks_to_copy.append((fp, backup_path / rel_path, fsize))
                                    else:
                                        tasks_to_link.append((rel_path, backup_path / rel_path))
                                except OSError:
                                    continue

            total_delta_bytes = sum([item[2] for item in tasks_to_copy])
            try:
                _, _, free = shutil.disk_usage(self.usb_path)
            except Exception as e:
                self.root.after(0, lambda err=e: messagebox.showerror("Hata", f"Disk alanı okunamadı: {err}"))
                return

            if free < total_delta_bytes:
                req = self.format_size(total_delta_bytes)
                fr = self.format_size(free)
                self.root.after(0, lambda r=req, f=fr: messagebox.showerror("Yetersiz Alan! ❌", f"Hedef sürücüde yeterli alan yok!\n\nGereken Delta: {r}\nBoş Alan: {f}"))
                return

            execution_tasks = []
            for fp, dest, fsize in tasks_to_copy:
                execution_tasks.append(('copy', fp, dest, fsize))
            for rel_path, dest in tasks_to_link:
                prev_file = (latest_backup_dir / rel_path) if latest_backup_dir else None
                fsize = new_manifest[rel_path]["size"]
                execution_tasks.append(('link', prev_file, dest, fsize))

            total_all_bytes = sum(item[3] for item in execution_tasks)
            processed_bytes = 0
            self.root.after(0, lambda: self.progress_var.set(0))

            if not execution_tasks:
                self.root.after(0, lambda: messagebox.showinfo("Bilgi", "Yedeklenecek dosya bulunamadı!"))
            else:
                for task_type, src, dest, fsize in execution_tasks:
                    if self.is_cancelled:
                        break

                    while self.is_paused:
                        if self.is_cancelled:
                            break
                        time.sleep(0.1)

                    if self.is_cancelled:
                        break

                    try:
                        dest.parent.mkdir(parents=True, exist_ok=True)
                        if task_type == 'copy':
                            shutil.copy2(src, dest)
                            action_text = "Kopyalanıyor"
                        else:
                            if src and src.exists():
                                try:
                                    os.link(src, dest)
                                except OSError:
                                    shutil.copy2(src, dest)
                            action_text = "Snapshot Bağlanıyor"

                        processed_bytes += fsize
                        percent = (processed_bytes / total_all_bytes) * 100 if total_all_bytes > 0 else 100
                        file_display = dest.name
                        
                        self.root.after(0, lambda p=percent, fn=file_display, act=action_text: self.update_progress_ui(p, fn, act))
                    except Exception as e:
                        print(f"İşlem hatası {dest}: {e}")

                with open(manifest_path, "w", encoding="utf-8") as f:
                    json.dump(new_manifest, f, ensure_ascii=False, indent=2)

                if self.is_cancelled:
                    self.root.after(0, lambda: messagebox.showwarning("İptal Edildi ⚠️", "Yedekleme kullanıcı tarafından iptal edildi."))
                else:
                    self.root.after(0, lambda: messagebox.showinfo("Başarılı! 🎉", f"Xyronix Akıllı Snapshot V3 Pro tamamlandı!\n\nKonum:\n{backup_path}"))
        
        except Exception as e:
            self.root.after(0, lambda err=e: messagebox.showerror("Hata", f"Yedekleme sırasında hata oluştu: {err}"))
        finally:
            self.root.after(0, self.reset_ui)

    def execute_restore(self, backup_dir):
        home = Path.home()
        try:
            for item in backup_dir.iterdir():
                if item.is_dir():
                    target_dir = home / item.name
                    target_dir.mkdir(parents=True, exist_ok=True)
                    shutil.copytree(item, target_dir, dirs_exist_ok=True)

            self.root.after(0, lambda: messagebox.showinfo("Başarılı! ♻️", "Seçilen snapshot yedeği başarıyla bilgisayara geri yüklendi!"))
        except Exception as e:
            self.root.after(0, lambda err=e: messagebox.showerror("Hata", f"Geri yükleme hatası: {err}"))
        finally:
            self.root.after(0, self.reset_restore_ui)

    def reset_ui(self):
        self.is_running = False
        self.is_paused = False
        self.is_cancelled = False
        self.progress_var.set(0)
        self.status_label.config(text="Durum: Hazır")
        self.backup_btn.config(state="normal", text="YEDEKLEMEYİ BAŞLAT", fg="#000000")
        self.usb_btn.config(state="normal")
        self.pause_btn.config(state="disabled", text="⏸ DURAKLAT", bg="#eab308", fg="#000000")
        self.cancel_btn.config(state="disabled", fg="#000000")
        self.update_stats()

    def reset_restore_ui(self, *args):
        self.is_running = False
        if hasattr(self, 'restore_btn'):
            self.restore_btn.config(state="normal", text="SEÇİLEN YEDEĞİ GERİ YÜKLE", fg="#000000")

if __name__ == "__main__":
    root = tk.Tk()
    app = XyronixBackupV3Pro(root)
    root.mainloop()
