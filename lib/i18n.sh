#!/bin/bash
# i18n yükleyici - JSON dil dosyalarını okur
# Öncelik: $JPS_LOCALE_DIR > script dizini/locale > /usr/local/share/jps/locale

JPS_LANG="${JPS_LANG:-${LANG%%_*}}"
[ -z "$JPS_LANG" ] && JPS_LANG="en"

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
