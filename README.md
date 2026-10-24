# Jubatus Package System (JPS)

Jubatus OS için modern paket yöneticisi. **Türkçe + İngilizce** (sistem dili otomatik).

[![Version](https://img.shields.io/badge/version-2.0.0-orange)](https://github.com/xyronixstudios-coder/Jubatus-Repo)
[![Packages](https://img.shields.io/badge/packages-22-orange)](https://github.com/xyronixstudios-coder/Jubatus-Repo)

## Kurulum

    curl -fsSL https://raw.githubusercontent.com/xyronixstudios-coder/Jubatus-Repo/main/install.sh | sudo bash

## Kullanım

    jps-64 help              # Yardım (TR/EN otomatik)
    jps-64 install <paket>   # Paket kur
    jps-64 remove <paket>    # Paket kaldır
    jps-64 list              # Mevcut paketler
    jps-64 search <kelime>   # Paket ara
    jps-64 info              # Sistem bilgisi
    jps-64 update            # Depoyu güncelle
    jps-64 self-update       # JPS'i güncelle

## Mevcut Paketler (22)

### Sistem & Monitör
| Paket | Açıklama | 64-bit | 32-bit |
|---|---|---|---|
| fastfetch | Jubatus temalı sistem bilgisi (turuncu ASCII) | ✅ | ✅ |
| btop | Modern sistem monitörü (turuncu tema) | ✅ | ✅ |
| bottom | btm - Rust sistem monitörü | ✅ | ✅ |
| htop | Klasik sistem monitörü | ✅ | ✅ |
| neofetch | Klasik sistem bilgisi | ✅ | ✅ |
| ncdu | Disk kullanımı analizi | ✅ | ✅ |

### Geliştirici Araçları
| Paket | Açıklama | 64-bit | 32-bit |
|---|---|---|---|
| neovim | Modern vim | ✅ | ✅ |
| bat | cat + syntax highlight | ✅ | ✅ |
| eza | Modern ls | ✅ | ✅ |
| ripgrep | rg - hızlı arama | ✅ | ✅ |
| fzf | Bulanık arama | ✅ | ✅ |
| zoxide | Akıllı cd | ✅ | ✅ |
| lazygit | Terminal git UI | ✅ | ✅ |
| delta | Git diff güzelleştirici | ✅ | ✅ |
| jq | JSON işleyici | ✅ | ✅ |
| tldr | Kısa man sayfaları (Türkçe) | ✅ | ✅ |

### Medya & Eğlence
| Paket | Açıklama | 64-bit | 32-bit |
|---|---|---|---|
| chafa | Terminalde resim görüntüleme | ✅ | ✅ |
| cmatrix | Matrix efekti | ✅ | ✅ |
| cowsay | İnek konuşturma | ✅ | ✅ |
| yt-dlp | YouTube indirici | ✅ | ✅ |

### Xyronix Projeleri
| Paket | Açıklama | 64-bit | 32-bit |
|---|---|---|---|
| xyronix-backup | Xyronix Backup V3 Pro (GUI) | ✅ | ✅ |
| xyronix-kivi | Xyronix Kivi Editor (TUI) | ✅ | ✅ |

## Dil Desteği

- 🇹🇷 Türkçe (tr)
- 🇬🇧 İngilizce (en)
- Sistem dili otomatik algılanır (`LANG`/`LC_ALL`)
- `JPS_LANG=tr jps-64 help` ile zorla

## Jubatus Teması

Tüm paketler **turuncu** (`#ff8c00` / `38;5;208`) Jubatus temasıyla gelir:
- `fastfetch` → turuncu ASCII logo
- `btop` → turuncu tema

## Bağımlılık Kurulumu

JPS eksik bağımlılıkları **otomatik kurar**:
- Debian/Ubuntu → `apt`
- Arch → `pacman`
- Fedora → `dnf`
- openSUSE → `zypper`
- Void → `xbps`
- Alpine → `apk`

## Lisans

Xyronix Studios - Eren Mut
