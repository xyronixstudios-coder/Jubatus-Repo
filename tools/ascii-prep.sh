#!/bin/bash
# JubatusOS.txt -> pfetch uyumlu ASCII
# - ANSI renk kodlarini temizler
# - Satir basi/sonu bosluklari kirpar
# - Cok genis satirlari (istege bagli) kirpar
set -euo pipefail

SRC="${1:?kaynak dosya gerekli}"
DST="${2:?hedef dosya gerekli}"
MAX_WIDTH="${3:-60}"   # pfetch icin onerilen maksimum genislik

if [ ! -f "$SRC" ]; then
    echo "[HATA] Kaynak bulunamadi: $SRC" >&2
    exit 1
fi

# 1. ANSI escape kodlarini sil (\x1b[...m ve digerleri)
# 2. Satir sonundaki \r varsa sil
# 3. Satir basi/sonu bosluklari kirp
# 4. Bos satirlari koru ama tamamen bos olanlari at
# 5. MAX_WIDTH'den uzun satirlari kirp (istege bagli, yorumda)
sed -E 's/\x1b\[[0-9;]*[A-Za-z]//g' "$SRC" \
    | tr -d '\r' \
    | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//' \
    | awk -v w="$MAX_WIDTH" 'length($0) > 0 { print substr($0, 1, w) } length($0) == 0 { print "" }' \
    > "$DST"

echo ":: ASCII hazirlandi: $DST"
echo ":: Satir sayisi: $(wc -l < "$DST")"
echo ":: Maksimum satir genisligi: $(awk '{ if (length($0) > m) m = length($0) } END { print m }' "$DST")"
