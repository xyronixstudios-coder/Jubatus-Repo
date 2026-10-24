# 🥝 Xyronix Kivi Editor

> Go ile yazılmış modern, modeless (modsuz) terminal metin editörü.
> **Eren Mut** tarafından · [Xyronix Studios](https://github.com/xyronixstudios-coder)

[![Lisans: GPL v2](https://img.shields.io/badge/Lisans-GPL%20v2-blue.svg)](https://www.gnu.org/licenses/old-licenses/gpl-2.0.html)
[![Go Sürümü](https://img.shields.io/badge/Go-1.20%2B-00ADD8.svg)](https://go.dev/)

[🇬🇧 English](README.md)

---

## 🥝 Kivi Nedir?

**Xyronix Kivi Editor** (kısaca: **kivi**), GNU nano'dan esinlenmiş
ama 2026 için modernize edilmiş hafif, **modsuz** bir terminal metin
editörüdür.

**vi/vim**'in aksine kivi **modsuzdur**: her basılabilir tuş anında
metne yazılır, komutlar sadece `Ctrl` kombinasyonlarındadır. `hjkl`
yok, `:wq` yok, `Esc`'e basıp moddan çıkmak yok.

**nano**'dan farkları:

- Modern **kivi-yeşili** renk teması
- Gerçek **fare desteği**: tıkla, sürükle-seç, tekerlek kaydır
- Seçimi bırakınca otomatik kopyala (OSC 52)
- **UTF-8** doğal destek, çoklu dil
- Terminal boyutu değişince **anında yeniden çizim** (SIGWINCH)
- Temiz **Go** kod tabanı (bubbletea + lipgloss)

---

## ✨ Özellikler

| Kategori | Özellik |
|----------|---------|
| **Düzenleme** | Modsuz, hjkl yok, insert mode yok |
| **Girdi** | Tam UTF-8, CJK geniş karakter |
| **Fare** | Tıkla, sürükle-seç, tekerlek, otomatik kopyala |
| **Görünüm** | Kivi-yeşili tema, satır numaraları, tilde |
| **Boyut** | SIGWINCH ile canlı çizim |
| **Tuşlar** | Nano uyumlu (^O, ^X, ^W, ^K, ^U, ^A, ^E) |
| **G/Ç** | Aç, kaydet, farklı kaydet, kaydetme uyarısıyla çık |
| **Arama** | İleri arama, başa sarma |

---

## 🚀 Kurulum

### Hızlı kurulum

    git clone git@github.com:xyronixstudios-coder/Xyronix-Kivi-Editor.git
    cd Xyronix-Kivi-Editor
    ./install.sh

Desteklenen: **Debian** (Debian, Ubuntu, Mint, Pop, Kali, Jubatus),
**Arch** (Manjaro, EndeavourOS), **Fedora** (RHEL, CentOS, Rocky),
**SUSE**, **Alpine**, **Void**, **Gentoo**, **NixOS**.

### Elle derleme

    make
    sudo make install

---

## 🎮 Kullanım

    kivi                    # boş buffer
    kivi notlar.txt         # dosya aç
    kivi ~/config/app.conf  # yol
    kivi --version          # sürüm + yapımcı
    kivi --help             # yardım

---

## ⌨️ Klavye Kısayolları

| Tuş | Eylem |
|-----|-------|
| `Ctrl+O` | Kaydet |
| `Ctrl+X` | Çık (değişiklik varsa sorar) |
| `Ctrl+R` | Dosya aç |
| `Ctrl+W` | Ara |
| `Alt+W`  | Tekrar ara |
| `Ctrl+K` | Kes (satır veya seçim) |
| `Ctrl+U` | Yapıştır |
| `Ctrl+C` | Kopyala / imleç konumu |
| `Ctrl+A` | Satır başı |
| `Ctrl+E` | Satır sonu |
| `Ctrl+Y` | Sayfa yukarı |
| `Ctrl+V` | Sayfa aşağı |
| `Ctrl+G` | Yardım |

---

## 🖱️ Fare Desteği

| Eylem | Etki |
|-------|------|
| **Sol tık** | İmleci koy |
| **Sol sürükle** | Metin seç |
| **Bırak** | Otomatik kopyala (OSC 52) |
| **Tekerlek** | Kaydır |

---

## 📜 Lisans

**GNU Genel Kamu Lisansı v2.0** — bkz. [LICENSE](LICENSE).

Bu program özgür yazılımdır; Özgür Yazılım Vakfı tarafından yayımlanan
GNU Genel Kamu Lisansı'nın (ya sürüm 2, ya da daha sonraki bir sürüm)
koşulları altında yeniden dağıtabilir ve/veya değiştirebilirsiniz.

---

## 🙏 Emeği Geçenler

- **Yapımcı:** Eren Mut
- **Stüdyo:** [Xyronix Studios](https://github.com/xyronixstudios-coder)
- **Kullanılan kütüphaneler:** [bubbletea](https://github.com/charmbracelet/bubbletea),
  [lipgloss](https://github.com/charmbracelet/lipgloss)
- **İlham:** GNU nano, Pico

---

<p align="center">Türkiye'de 🥝 ile yapıldı</p>
