#!/bin/bash
# JPS install fonksiyonlari

install_package() {
    local pkg="$1"
    echo -e "${C_ORANGE}${C_BOLD}╔══════════════════════════════════════╗${C_RESET}"
    echo -e "${C_ORANGE}${C_BOLD}║  JPS-${JPS_ARCH_BITS} Paket Kurulumu: $pkg${C_RESET}"
    echo -e "${C_ORANGE}${C_BOLD}╚══════════════════════════════════════╝${C_RESET}"

    # [1/3] Depo
    progress_start "$(msg repo_sync_start)"
    sync_repo >/dev/null 2>&1
    progress_set 100
    progress_done

    # [2/3] Paket ara
    progress_start "$(msg pkg_search "$pkg")"
    local pkg_path="$INSTALL_DIR/${JPS_ARCH_BITS}-bit/$pkg"
    if [ ! -d "$pkg_path" ]; then
        progress_fail
        echo -e "${C_RED}$(msg pkg_not_found "$pkg" "${JPS_ARCH_BITS}-bit")${C_RESET}"
        return 1
    fi
    progress_set 100
    progress_done

    # [3/3] Bagimliliklar
    echo -e "${C_CYAN}:: Bagimliliklar kontrol ediliyor...${C_RESET}"
    if [ -f "$pkg_path/depends.txt" ]; then
        while IFS= read -r dep; do
            [ -z "$dep" ] && continue
            if command -v "$dep" >/dev/null 2>&1; then
                echo -e "${C_GREEN}  ✓ $dep${C_RESET}"
            else
                echo -e "${C_YELLOW}  ! $dep eksik (kurulum icin gerekli olabilir)${C_RESET}"
            fi
        done < "$pkg_path/depends.txt"
    fi

    # Kurulum: install.sh arka planda, bar artimli ilerler
    local log_file
    log_file=$(mktemp "/tmp/jps-install-${pkg}.XXXXXX.log")

    progress_start "$(msg progress_install) $pkg"

    # install.sh'i arka planda baslat
    ( cd "$pkg_path" && sudo bash install.sh ) > "$log_file" 2>&1 &
    local install_pid=$!

    # Bar'i artimli guncelle (0 -> 95), install.sh bitene kadar
    local pct=0
    while kill -0 "$install_pid" 2>/dev/null; do
        sleep 0.5
        if [ $pct -lt 95 ]; then
            pct=$((pct + 3))
            [ $pct -gt 95 ] && pct=95
            progress_set "$pct"
        fi
    done

    # install.sh bitti mi, basarili mi?
    wait "$install_pid"
    local rc=$?

    if [ $rc -ne 0 ]; then
        progress_fail
        echo -e "${C_RED}$(msg pkg_install_fail "$pkg")${C_RESET}"
        echo -e "${C_YELLOW}:: Hata logu: $log_file${C_RESET}"
        tail -20 "$log_file" | sed 's/^/  /'
        return 1
    fi

    progress_set 100
    progress_done
    rm -f "$log_file"
    echo -e "${C_GREEN}${C_BOLD}$(msg pkg_install_ok "$pkg")${C_RESET}"
}
