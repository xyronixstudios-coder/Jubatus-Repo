#!/bin/bash
# JPS Progress Bar - kendi çizen, git çıktısı göstermeyen

_C_RESET="\033[0m"
_C_BOLD="\033[1m"
_C_CYAN="\033[36m"
_C_GREEN="\033[32m"
_C_YELLOW="\033[33m"
_C_RED="\033[31m"
_C_ORANGE="\033[38;5;208m"

_PROGRESS_ACTIVE=0
_PROGRESS_LABEL=""
_PROGRESS_PCT=0

progress_start() {
    _PROGRESS_LABEL="$1"
    _PROGRESS_PCT=0
    _PROGRESS_ACTIVE=1
    _progress_draw
}

progress_set() {
    [ "$_PROGRESS_ACTIVE" -eq 0 ] && return
    local pct="$1"
    [ "$pct" -lt 0 ] && pct=0
    [ "$pct" -gt 100 ] && pct=100
    _PROGRESS_PCT="$pct"
    _progress_draw
}

_progress_draw() {
    local width=30
    local filled=$(( _PROGRESS_PCT * width / 100 ))
    local empty=$(( width - filled ))
    local bar=""
    local i
    for ((i=0; i<filled; i++)); do bar+="█"; done
    for ((i=0; i<empty; i++)); do bar+="░"; done
    printf "\r\033[K  ${_C_ORANGE}⠿${_C_RESET} %-20s [${_C_ORANGE}%s${_C_RESET}] %3d%%" "$_PROGRESS_LABEL" "$bar" "$_PROGRESS_PCT"
}

progress_done() {
    [ "$_PROGRESS_ACTIVE" -eq 0 ] && return
    _PROGRESS_ACTIVE=0
    _PROGRESS_PCT=100
    _progress_draw
    printf "\r\033[K"
    echo -e "  ${_C_GREEN}✓${_C_RESET} ${_C_GREEN}${_C_BOLD}${_PROGRESS_LABEL}${_C_RESET}"
}

progress_fail() {
    [ "$_PROGRESS_ACTIVE" -eq 0 ] && return
    _PROGRESS_ACTIVE=0
    printf "\r\033[K"
    echo -e "  ${_C_RED}✗${_C_RESET} ${_C_RED}${_C_BOLD}${_PROGRESS_LABEL}${_C_RESET}"
}
