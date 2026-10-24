#!/usr/bin/env bash
#
# Xyronix Kivi Editor - installer
# Author: Eren Mut (Xyronix Studios)
#
# Detects the Linux distribution via os-release, ID_LIKE, package
# manager presence, kernel signature and release files. Falls back to
# a manual instruction block if nothing matches.

set -e

BOLD="$(printf '\033[1m')"
GREEN="$(printf '\033[1;32m')"
YELLOW="$(printf '\033[1;33m')"
RED="$(printf '\033[1;31m')"
CYAN="$(printf '\033[1;36m')"
RESET="$(printf '\033[0m')"

say()  { printf '%s==>%s %s%s%s\n' "$CYAN" "$RESET" "$BOLD" "$*" "$RESET"; }
ok()   { printf '%s✓%s %s\n' "$GREEN" "$RESET" "$*"; }
warn() { printf '%s!%s %s\n' "$YELLOW" "$RESET" "$*"; }
err()  { printf '%s✗%s %s\n' "$RED" "$RESET" "$*" >&2; }

# ---------- 1. Detect distro ----------
detect_distro() {
    local id="" id_like="" name=""

    if [ -f /etc/os-release ]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        id="${ID:-}"
        id_like="${ID_LIKE:-}"
        name="${NAME:-$id}"
    fi

    # Known ID match
    case "$id" in
        debian|ubuntu|linuxmint|pop|raspbian|kali|mx|deepin|zorin|elementary|jubatus)
            echo "debian" ; return ;;
        arch|manjaro|endeavouros|garuda|artix|arcolinux|cachyos)
            echo "arch" ; return ;;
        fedora|rhel|centos|rocky|almalinux|ol|nobara)
            echo "fedora" ; return ;;
        opensuse*|suse|sles|sled)
            echo "suse" ; return ;;
        alpine)
            echo "alpine" ; return ;;
        void)
            echo "void" ; return ;;
        gentoo)
            echo "gentoo" ; return ;;
        nixos)
            echo "nixos" ; return ;;
    esac

    # ID_LIKE fallback
    case " $id_like " in
        *" debian "*|*" ubuntu "*) echo "debian" ; return ;;
        *" arch "*)               echo "arch"   ; return ;;
        *" fedora "*|*" rhel "*)  echo "fedora" ; return ;;
        *" suse "*|*" opensuse "*) echo "suse"  ; return ;;
    esac

    # Package manager presence
    if command -v apt-get >/dev/null 2>&1; then echo "debian" ; return; fi
    if command -v pacman  >/dev/null 2>&1; then echo "arch"   ; return; fi
    if command -v dnf     >/dev/null 2>&1; then echo "fedora" ; return; fi
    if command -v yum     >/dev/null 2>&1; then echo "fedora" ; return; fi
    if command -v zypper  >/dev/null 2>&1; then echo "suse"   ; return; fi
    if command -v apk     >/dev/null 2>&1; then echo "alpine" ; return; fi
    if command -v xbps-install >/dev/null 2>&1; then echo "void" ; return; fi
    if command -v emerge  >/dev/null 2>&1; then echo "gentoo" ; return; fi
    if command -v nix-env >/dev/null 2>&1; then echo "nixos"  ; return; fi

    # Release file fallbacks
    if [ -f /etc/debian_version ]; then echo "debian" ; return; fi
    if [ -f /etc/arch-release  ]; then echo "arch"   ; return; fi
    if [ -f /etc/fedora-release ]; then echo "fedora" ; return; fi
    if [ -f /etc/redhat-release ]; then echo "fedora" ; return; fi
    if [ -f /etc/gentoo-release ]; then echo "gentoo" ; return; fi

    # Kernel signature
    if [ -r /proc/version ]; then
        if grep -qi "debian" /proc/version; then echo "debian" ; return; fi
        if grep -qi "ubuntu" /proc/version; then echo "debian" ; return; fi
        if grep -qi "arch"   /proc/version; then echo "arch"   ; return; fi
        if grep -qi "fedora" /proc/version; then echo "fedora" ; return; fi
    fi

    # Give up
    echo "unknown"
}

print_manual_instructions() {
    warn "Could not detect your distribution automatically."
    echo
    echo "Please install the following packages with your package manager,"
    echo "then re-run this installer:"
    echo
    echo "  - ${BOLD}go${RESET}   (Go 1.20 or newer)"
    echo "  - ${BOLD}git${RESET}  (for fetching modules)"
    echo
    echo "Common commands:"
    echo "  Debian/Ubuntu:  sudo apt install golang-go git"
    echo "  Arch:           sudo pacman -S go git"
    echo "  Fedora:         sudo dnf install golang git"
    echo "  openSUSE:       sudo zypper install go git"
    echo "  Alpine:         sudo apk add go git"
    echo "  Void:           sudo xbps-install go git"
    echo "  Gentoo:         sudo emerge dev-lang/go dev-vcs/git"
    echo "  NixOS:          nix-env -iA nixpkgs.go nixpkgs.git"
    echo
    echo "If Go is already installed, you can skip this step:"
    echo "  make build && sudo make install"
    echo
}

# ---------- 2. Install Go toolchain ----------
install_go() {
    local distro="$1"
    if command -v go >/dev/null 2>&1; then
        ok "Go already installed: $(go version)"
        return 0
    fi

    say "Go not found. Installing via $distro package manager..."

    case "$distro" in
        debian)
            sudo apt-get update
            sudo apt-get install -y golang-go git
            ;;
        arch)
            sudo pacman -Sy --noconfirm go git
            ;;
        fedora)
            if command -v dnf >/dev/null 2>&1; then
                sudo dnf install -y golang git
            else
                sudo yum install -y golang git
            fi
            ;;
        suse)
            sudo zypper install -y go git
            ;;
        alpine)
            sudo apk add go git
            ;;
        void)
            sudo xbps-install -Sy go git
            ;;
        gentoo)
            sudo emerge dev-lang/go dev-vcs/git
            ;;
        nixos)
            nix-env -iA nixpkgs.go nixpkgs.git
            ;;
        *)
            print_manual_instructions
            exit 1
            ;;
    esac

    if ! command -v go >/dev/null 2>&1; then
        err "Go installation failed."
        print_manual_instructions
        exit 1
    fi
    ok "Go installed: $(go version)"
}

# ---------- 3. Build and install ----------
build_and_install() {
    say "Fetching Go dependencies..."
    go mod tidy

    say "Building kivi..."
    make build

    if [ ! -x ./kivi ]; then
        err "Build failed."
        exit 1
    fi
    ok "Built ./kivi"

    say "Installing to /usr/local/bin (needs sudo)..."
    sudo make install

    ok "Installed: $(command -v kivi)"
}

# ---------- main ----------
main() {
    printf '%s%s\n' "$BOLD" "$GREEN"
    echo "  ╭──────────────────────────────────────╮"
    echo "  │   Xyronix Kivi Editor - Installer    │"
    echo "  │   By Eren Mut · Xyronix Studios      │"
    echo "  ╰──────────────────────────────────────╯"
    printf '%s\n' "$RESET"

    local distro
    distro="$(detect_distro)"
    say "Detected distribution family: ${BOLD}${distro}${RESET}"

    install_go "$distro"
    build_and_install

    echo
    ok "Installation complete!"
    echo
    printf '  Run:      %skivi%s [file]\n' "$BOLD" "$RESET"
    printf '  Version:  %skivi --version%s\n' "$BOLD" "$RESET"
    printf '  Help:     %skivi --help%s\n' "$BOLD" "$RESET"
    echo
}

main "$@"
