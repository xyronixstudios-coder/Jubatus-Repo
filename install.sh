#!/bin/bash
set -euo pipefail
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"

RAW_BASE_URL="https://raw.githubusercontent.com/xyronixstudios-coder/Jubatus-Repo/main"

C_RESET="\033[0m"
C_BOLD="\033[1m"
C_CYAN="\033[36m"
C_GREEN="\033[32m"
C_RED="\033[31m"
C_ORANGE="\033[38;5;208m"

echo -e "${C_ORANGE}${C_BOLD}==========================================${C_RESET}"
echo -e "${C_ORANGE}${C_BOLD}   Jubatus Package System (JPS) Kurulumu  ${C_RESET}"
echo -e "${C_ORANGE}${C_BOLD}        Xyronix Studios - Eren Mut        ${C_RESET}"
echo -e "${C_ORANGE}${C_BOLD}==========================================${C_RESET}"

ARCH=$(uname -m)

if [ "$ARCH" = "x86_64" ]; then
    echo -e "${C_GREEN}[+] 64-bit mimari tespit edildi. jps-64 kuruluyor...${C_RESET}"
    SCRIPT_NAME="jps-64"
elif [[ "$ARCH" =~ ^i[3-6]86$ ]]; then
    echo -e "${C_GREEN}[+] 32-bit mimari tespit edildi. jps-32 kuruluyor...${C_RESET}"
    SCRIPT_NAME="jps-32"
else
    echo -e "${C_RED}[-] Desteklenmeyen mimari: $ARCH${C_RESET}"
    exit 1
fi

# 1. Ana script'i indir
echo -e "${C_GREEN}[+] GitHub depodan $SCRIPT_NAME indiriliyor...${C_RESET}"
curl -sSL --retry 3 --proto '=https' "$RAW_BASE_URL/$SCRIPT_NAME?v=$(date +%s)" -o "/usr/local/bin/$SCRIPT_NAME" || \
    wget -qO "/usr/local/bin/$SCRIPT_NAME" "$RAW_BASE_URL/$SCRIPT_NAME?v=$(date +%s)"

if [ $? -ne 0 ] || [ ! -s "/usr/local/bin/$SCRIPT_NAME" ]; then
    echo -e "${C_RED}[-] $SCRIPT_NAME indirilemedi.${C_RESET}"
    exit 1
fi

chmod +x "/usr/local/bin/$SCRIPT_NAME"
ln -sf "/usr/local/bin/$SCRIPT_NAME" /usr/local/bin/jps

# 2. lib/ ve locale/ dizinlerini kur
echo -e "${C_GREEN}[+] JPS kutuphaneleri kuruluyor...${C_RESET}"
sudo mkdir -p /usr/local/share/jps/lib /usr/local/share/jps/locale

for f in i18n.sh progress.sh selfupdate.sh install.sh; do
    curl -sSL --retry 3 --proto '=https' "$RAW_BASE_URL/lib/$f?v=$(date +%s)" -o "/tmp/jps-lib-$f"
    sudo cp -f "/tmp/jps-lib-$f" "/usr/local/share/jps/lib/$f"
    rm -f "/tmp/jps-lib-$f"
done

for lang in tr en; do
    curl -sSL --retry 3 --proto '=https' "$RAW_BASE_URL/locale/$lang.json?v=$(date +%s)" -o "/tmp/jps-locale-$lang.json"
    sudo cp -f "/tmp/jps-locale-$lang.json" "/usr/local/share/jps/locale/$lang.json"
    rm -f "/tmp/jps-locale-$lang.json"
done

sudo chmod +x /usr/local/share/jps/lib/*.sh

echo -e "${C_GREEN}${C_BOLD}[BAŞARILI] JPS sisteme başarıyla kuruldu!${C_RESET}"
echo -e "${C_ORANGE}Kullanım: jps-64 help veya jps-32 help${C_RESET}"
