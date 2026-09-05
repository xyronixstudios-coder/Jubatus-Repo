#!/bin/bash

C_RESET="\033[0m"
C_BOLD="\033[1m"
C_CYAN="\033[36m"
C_GREEN="\033[32m"
C_RED="\033[31m"

RAW_BASE_URL="https://raw.githubusercontent.com/xyronixstudios-coder/Jubatus-Repo/main"

echo -e "${C_CYAN}${C_BOLD}==========================================${C_RESET}"
echo -e "${C_CYAN}${C_BOLD}   Jubatus Package System (JPS) Kurulumu  ${C_RESET}"
echo -e "${C_CYAN}${C_BOLD}        Xyronix Studios - Eren Mut        ${C_RESET}"
echo -e "${C_CYAN}${C_BOLD}==========================================${C_RESET}"

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

echo -e "${C_GREEN}[+] GitHub depodan $SCRIPT_NAME indiriliyor...${C_RESET}"
curl -sSL "$RAW_BASE_URL/$SCRIPT_NAME?v=$(date +%s)" -o "/usr/local/bin/$SCRIPT_NAME" || wget -qO "/usr/local/bin/$SCRIPT_NAME" "$RAW_BASE_URL/$SCRIPT_NAME?v=$(date +%s)"

if [ $? -ne 0 ] || [ ! -s "/usr/local/bin/$SCRIPT_NAME" ]; then
    echo -e "${C_RED}[-] $SCRIPT_NAME indirilemedi. Lütfen bağlantınızı kontrol edin.${C_RESET}"
    exit 1
fi

chmod +x "/usr/local/bin/$SCRIPT_NAME"
ln -sf "/usr/local/bin/$SCRIPT_NAME" /usr/local/bin/jps

echo -e "${C_GREEN}${C_BOLD}[BAŞARILI] $SCRIPT_NAME ve jps komutları sisteme başarıyla kuruldu!${C_RESET}"
echo -e "${C_CYAN}Kullanım: $SCRIPT_NAME help veya jps help${C_RESET}"
