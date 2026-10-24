#!/bin/bash
# i18n yükleyici - JSON dil dosyalarını okur
# Öncelik: JPS_LANG > LC_ALL > LC_MESSAGES > LANG > en
# Örnek: LANG=tr_TR.UTF-8 -> "tr"

# 1. Dil tespit et
if [ -z "${JPS_LANG:-}" ]; then
    # Sistem dilini al (LC_ALL > LC_MESSAGES > LANG sırası)
    _sys_lang="${LC_ALL:-${LC_MESSAGES:-${LANG:-}}}"
    
    # "tr_TR.UTF-8" -> "tr", "en_US.UTF-8" -> "en"
    _lang_code="${_sys_lang%%_*}"     # alt çizgiden önce
    _lang_code="${_lang_code%%.*}"    # noktadan önce
    _lang_code="${_lang_code%%@*}"    # @ işaretinden önce
    
    # Geçerli mi? (sadece harf, 2-3 karakter)
    if [[ "$_lang_code" =~ ^[a-z]{2,3}$ ]]; then
        JPS_LANG="$_lang_code"
    else
        JPS_LANG="en"
    fi
fi

# 2. Dil dosyası var mı? Yoksa en'e düş
_jps_find_locale_dir() {
    if [ -n "${JPS_LOCALE_DIR:-}" ] && [ -d "$JPS_LOCALE_DIR" ]; then
        echo "$JPS_LOCALE_DIR"; return
    fi
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    if [ -d "$script_dir/locale" ]; then
        echo "$script_dir/locale"; return
    fi
    if [ -d "/usr/local/share/jps/locale" ]; then
        echo "/usr/local/share/jps/locale"; return
    fi
    echo ""
}

JPS_LOCALE_DIR="$(_jps_find_locale_dir)"

# Dil dosyası yoksa ingilizceye düş
if [ ! -f "$JPS_LOCALE_DIR/$JPS_LANG.json" ]; then
    if [ "$JPS_LANG" != "en" ]; then
        # Sessizce en'e düş (kullanıcıya uyarı verme)
        JPS_LANG="en"
    fi
fi

# 3. JSON'dan mesaj oku
_load_json_msg() {
    local key="$1"
    local file="$JPS_LOCALE_DIR/$JPS_LANG.json"
    [ -f "$file" ] || file="$JPS_LOCALE_DIR/en.json"
    [ -f "$file" ] || { echo "$key"; return; }

    if command -v jq >/dev/null 2>&1; then
        jq -r --arg k "$key" '.msg[$k] // $k' "$file" 2>/dev/null
    else
        sed -n "s/.*\"$key\"[[:space:]]*:[[:space:]]*\"\\(.*\\)\".*/\\1/p" "$file" | head -1
    fi
}

msg() {
    local key="$1"
    shift
    local template
    template=$(_load_json_msg "$key")
    if [ $# -gt 0 ]; then
        printf "$template" "$@"
    else
        printf "%s" "$template"
    fi
}
