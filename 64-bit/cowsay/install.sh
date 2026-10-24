#!/bin/bash
set -euo pipefail
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"

# cowsay, apt/pacman/dnf ile
if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get install -y cowsay lolcat figlet >/dev/null 2>&1
elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -S --noconfirm cowsay lolcat figlet >/dev/null 2>&1
elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y cowsay lolcat figlet >/dev/null 2>&1
elif command -v zypper >/dev/null 2>&1; then
    sudo zypper --non-interactive install cowsay lolcat figlet >/dev/null 2>&1
elif command -v apk >/dev/null 2>&1; then
    sudo apk add --no-cache cowsay lolcat figlet >/dev/null 2>&1
fi

echo "cowsay, lolcat, figlet kuruldu"
