#!/bin/bash
# i18n yükleyici - JSON dil dosyalarını okur
# jq yoksa basit grep/sed fallback kullanır

JPS_LOCALE_DIR="${JPS_LOCALE_DIR:-/usr/local/share/jps/locale}"
JPS_LANG="${JPS_LANG:-${LANG%%_*}}"
[ -z "$JPS_LANG" ] && JPS_LANG="en"

_load_json_msg() {
    local key="$1"
    local file="$JPS_LOCALE_DIR/$JPS_LANG.json"
    [ -f "$file" ] || file="$JPS_LOCALE_DIR/en.json"
    [ -f "$file" ] || { echo "$key"; return; }

    if command -v jq >/dev/null 2>&1; then
        jq -r --arg k "$key" '.msg[$k] // $k' "$file" 2>/dev/null
    else
        # jq yoksa: basit sed ile (tırnak içindeki değeri al)
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
