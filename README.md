# Jubatus Package System (JPS)

Jubatus OS için modern paket yöneticisi. **Türkçe + İngilizce** (sistem dili otomatik).

## Kurulum

    curl -fsSL https://raw.githubusercontent.com/xyronixstudios-coder/Jubatus-Repo/main/install.sh | sudo bash

## Kullanım

    jps-64 help              # Yardım (TR/EN otomatik)
    jps-64 install <paket>   # Paket kur
    jps-64 remove <paket>    # Paket kaldır
    jps-64 list              # Mevcut paketler
    jps-64 search <kelime>   # Paket ara
    jps-64 update            # Depoyu güncelle
    jps-64 self-update       # JPS'i güncelle

## Mevcut Paketler (14)

| Paket | Açıklama | 64-bit | 32-bit |
|---|---|---|---|
| fastfetch | Jubatus temalı sistem bilgisi (turuncu ASCII) | ✅ | ✅ |
| btop | Modern sistem monitörü (turuncu tema) | ✅ | ✅ |
| bat | cat + syntax highlight | ✅ | ✅ |
| eza | Modern ls | ✅ | ✅ |
| ripgrep | rg - hızlı arama | ✅ | ✅ |
| fzf | Bulanık arama | ✅ | ✅ |
| zoxide | Akıllı cd | ✅ | ✅ |
| lazygit | Terminal git UI | ✅ | ✅ |
| jq | JSON işleyici | ✅ | ✅ |
| tldr | Kısa man sayfaları (Türkçe destekli) | ✅ | ✅ |
| htop | Klasik sistem monitörü | ✅ | ✅ |
| neofetch | Klasik sistem bilgisi | ✅ | ✅ |
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

## Lisans

Xyronix Studios - Eren Mut
