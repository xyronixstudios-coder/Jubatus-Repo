#!/bin/bash
# JPS install fonksiyonlari (i18n'li, bagimlilik kuran)

# Dagitim algila ve paket kur
_jps_pkg_install() {
    local pkgs=("$@")
    [ ${#pkgs[@]} -eq 0 ] && return 0

    if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update -qq >/dev/null 2>&1 || true
        sudo apt-get install -y "${pkgs[@]}" >/dev/null 2>&1
    elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -S --noconfirm --needed "${pkgs[@]}" >/dev/null 2>&1
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y "${pkgs[@]}" >/dev/null 2>&1
    elif command -v zypper >/dev/null 2>&1; then
        sudo zypper --non-interactive install "${pkgs[@]}" >/dev/null 2>&1
    elif command -v xbps-install >/dev/null 2>&1; then
        sudo xbps-install -y "${pkgs[@]}" >/dev/null 2>&1
    elif command -v apk >/dev/null 2>&1; then
        sudo apk add --no-cache "${pkgs[@]}" >/dev/null 2>&1
    else
        return 1
    fi
}

# Bagimlilik adini dagitima gore cevir
_jps_dep_to_pkg() {
    local dep="$1"
    # pip3 -> python3-pip, go -> golang, make -> make (bazen build-essential)
    case "$dep" in
        pip3|pip)  echo "python3-pip" ;;
        python3)   echo "python3" ;;
        go)        echo "golang" ;;
        make)      echo "make" ;;
        gcc)       echo "gcc" ;;
        git)       echo "git" ;;
        curl)      echo "curl" ;;
        tar)       echo "tar" ;;
        bzip2)     echo "bzip2" ;;
        jq)        echo "jq" ;;
        *)         echo "$dep" ;;
    esac
}

install_package() {
    local pkg="$1"
    echo -e "${C_ORANGE}${C_BOLD}╔══════════════════════════════════════╗${C_RESET}"
    echo -e "${C_ORANGE}${C_BOLD}║  $(msg pkg_install_header "$JPS_ARCH_BITS" "$pkg")${C_RESET}"
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

    # [3/3] Bagimliliklar (EKSIKSE KUR)
    echo -e "${C_CYAN}:: $(msg deps_checking)${C_RESET}"
    if [ -f "$pkg_path/depends.txt" ]; then
        local missing_pkgs=()
        while IFS= read -r dep; do
            [ -z "$dep" ] && continue
            if command -v "$dep" >/dev/null 2>&1; then
                printf "${C_GREEN}$(msg dep_ok '%s')${C_RESET}\n" "$dep"
            else
                printf "${C_YELLOW}$(msg dep_missing '%s')${C_RESET}\n" "$dep"
                missing_pkgs+=("$(_jps_dep_to_pkg "$dep")")
            fi
        done < "$pkg_path/depends.txt"

        if [ ${#missing_pkgs[@]} -gt 0 ]; then
            echo -e "${C_CYAN}:: Eksik bagimliliklar kuruluyor: ${missing_pkgs[*]}${C_RESET}"
            if _jps_pkg_install "${missing_pkgs[@]}"; then
                echo -e "${C_GREEN}  ✓ Bagimliliklar kuruldu${C_RESET}"
            else
                echo -e "${C_RED}  ✗ Bagimliliklar kurulamadi (paket yoneticisi bulunamadi)${C_RESET}"
                echo -e "${C_YELLOW}  ! Devam ediliyor, install.sh kendi kontrolunu yapacak${C_RESET}"
            fi
        fi
    fi

    # Kurulum
    local log_file
    log_file=$(mktemp "/tmp/jps-install-${pkg}.XXXXXX.log")

    progress_start "$(msg progress_install) $pkg"

    ( cd "$pkg_path" && sudo bash install.sh ) > "$log_file" 2>&1 &
    local install_pid=$!

    local pct=0
    while kill -0 "$install_pid" 2>/dev/null; do
        sleep 0.5
        if [ $pct -lt 95 ]; then
            pct=$((pct + 3))
            [ $pct -gt 95 ] && pct=95
            progress_set "$pct"
        fi
    done

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
