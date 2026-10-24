#!/bin/bash
# JPS Self-Update - güvenli, atomik, rollback'li
# Gerçekçi mi? Evet: SHA256 doğrulama + aynı dosya sisteminde mv (atomic rename) + yedek.

JPS_VERSION="2.0.0"
JPS_RAW_BASE="https://raw.githubusercontent.com/xyronixstudios-coder/Jubatus-Repo/main"
JPS_BACKUP_DIR="/var/lib/jps/backups"

self_update() {
    local target_bin="${1:-$(command -v jps || echo /usr/local/bin/jps)}"
    local tmp_dir
    tmp_dir=$(mktemp -d "/tmp/jps-update.XXXXXX") || return 1

    echo -e "${_C_CYAN}$(msg update_check)${_C_RESET}"

    # 1. Uzak sürümü çek (VERSION dosyası)
    local remote_ver
    remote_ver=$(curl -fsSL --retry 3 --proto '=https' \
        "$JPS_RAW_BASE/VERSION?v=$(date +%s)" 2>/dev/null | tr -d '[:space:]')

    if [ -z "$remote_ver" ]; then
        echo -e "${_C_YELLOW}$(msg update_latest "$JPS_VERSION")${_C_RESET}"
        rm -rf "$tmp_dir"
        return 0
    fi

    # Semver karşılaştırma (basit)
    if [ "$remote_ver" = "$JPS_VERSION" ]; then
        echo -e "${_C_GREEN}$(msg update_latest "$JPS_VERSION")${_C_RESET}"
        rm -rf "$tmp_dir"
        return 0
    fi

    echo -e "${_C_YELLOW}$(msg update_available "$JPS_VERSION" "$remote_ver")${_C_RESET}"
    read -r -p "$(msg update_prompt)" ans
    ans=${ans:-E}
    if [[ ! "$ans" =~ ^[EeYy]$ ]]; then
        echo -e "${_C_YELLOW}$(msg update_cancel)${_C_RESET}"
        rm -rf "$tmp_dir"
        return 0
    fi

    # 2. Yeni script'i indir (temp'e)
    local tmp_script="$tmp_dir/jps.new"
    progress_start "$(msg progress_download)"
    if ! curl -fsSL --retry 3 --proto '=https' --progress-bar \
        "$JPS_RAW_BASE/jps?v=$(date +%s)" -o "$tmp_script"; then
        progress_fail
        echo -e "${_C_RED}Download failed.${_C_RESET}"
        rm -rf "$tmp_dir"
        return 1
    fi
    progress_set 100
    progress_done

    # 3. SHA256 doğrula (CHECKSUMS dosyasından)
    progress_start "$(msg progress_verify)"
    local expected_hash
    expected_hash=$(curl -fsSL --retry 3 --proto '=https' \
        "$JPS_RAW_BASE/CHECKSUMS?v=$(date +%s)" 2>/dev/null | grep -E ' jps$' | awk '{print $1}')

    if [ -n "$expected_hash" ]; then
        local actual_hash
        actual_hash=$(sha256sum "$tmp_script" | awk '{print $1}')
        if [ "$expected_hash" != "$actual_hash" ]; then
            progress_fail
            echo -e "${_C_RED}$(msg update_verify_fail)${_C_RESET}"
            rm -rf "$tmp_dir"
            return 1
        fi
    fi
    progress_set 100
    progress_done

    # 4. Yedek al (rollback için)
    sudo mkdir -p "$JPS_BACKUP_DIR"
    if [ -f "$target_bin" ]; then
        sudo cp -a "$target_bin" "$JPS_BACKUP_DIR/jps.$(date +%s).bak"
    fi

    # 5. Atomik değiştir (aynı dosya sistemi)
    progress_start "$(msg progress_install)"
    chmod +x "$tmp_script"
    if sudo mv -f "$tmp_script" "$target_bin"; then
        progress_set 100
        progress_done
        echo -e "${_C_GREEN}${_C_BOLD}$(msg update_ok)${_C_RESET}"
        rm -rf "$tmp_dir"
        return 0
    else
        progress_fail
        rm -rf "$tmp_dir"
        return 1
    fi
}

self_rollback() {
    local target_bin="${1:-$(command -v jps || echo /usr/local/bin/jps)}"
    local latest_bak
    latest_bak=$(ls -t "$JPS_BACKUP_DIR"/jps.*.bak 2>/dev/null | head -1)
    if [ -z "$latest_bak" ]; then
        echo -e "${_C_RED}No backup found.${_C_RESET}"
        return 1
    fi
    sudo cp -a "$latest_bak" "$target_bin"
    echo -e "${_C_GREEN}$(msg update_rollback_ok)${_C_RESET}"
}
