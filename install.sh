#!/bin/bash

# Renkler
C_RESET="\033[0m"
C_BOLD="\033[1m"
C_CYAN="\033[36m"
C_GREEN="\033[32m"
C_RED="\033[31m"

RAW_BASE="https://raw.githubusercontent.com/xyronixstudios-coder/Jubatus-Repo/main"

echo -e "${C_CYAN}${C_BOLD}==========================================${C_RESET}"
echo -e "${C_CYAN}${C_BOLD}    Jubatus Package System (JPS) Kurulumu ${C_RESET}"
echo -e "${C_CYAN}${C_BOLD}        Xyronix Studios - Eren Mut        ${C_RESET}"
echo -e "${C_CYAN}${C_BOLD}==========================================${C_RESET}"

ARCH=$(uname -m)

if [ "$ARCH" = "x86_64" ]; then
    echo -e "${C_GREEN}[+] 64-bit mimari tespit edildi. jps-64 indirilip kuruluyor...${C_RESET}"
    
    if [ -f "jps-64" ]; then
        sudo cp jps-64 /usr/local/bin/jps-64
    else
        echo -e "${C_CYAN}[+] GitHub depodan jps-64 çekiliyor...${C_RESET}"
        sudo curl -sSL "$RAW_BASE/jps-64" -o /usr/local/bin/jps-64 || sudo wget -qO /usr/local/bin/jps-64 "$RAW_BASE/jps-64"
    fi

    sudo chmod +x /usr/local/bin/jps-64
    sudo ln -sf /usr/local/bin/jps-64 /usr/local/bin/jps
    
    echo -e "${C_GREEN}${C_BOLD}[BAŞARILI] jps-64 ve jps komutları sisteme başarıyla kuruldu!${C_RESET}"
    echo -e "Kullanım: ${C_BOLD}jps-64 help${C_RESET} veya ${C_BOLD}jps help${C_RESET}"

elif [ "$ARCH" = "i386" ] || [ "$ARCH" = "i686" ]; then
    echo -e "${C_GREEN}[+] 32-bit mimari tespit edildi. jps-32 indirilip kuruluyor...${C_RESET}"
    
    if [ -f "jps-32" ]; then
        sudo cp jps-32 /usr/local/bin/jps-32
    else
        echo -e "${C_CYAN}[+] GitHub depodan jps-32 çekiliyor...${C_RESET}"
        sudo curl -sSL "$RAW_BASE/jps-32" -o /usr/local/bin/jps-32 || sudo wget -qO /usr/local/bin/jps-32 "$RAW_BASE/jps-32"
    fi

    sudo chmod +x /usr/local/bin/jps-32
    sudo ln -sf /usr/local/bin/jps-32 /usr/local/bin/jps
    
    echo -e "${C_GREEN}${C_BOLD}[BAŞARILI] jps-32 ve jps komutları sisteme başarıyla kuruldu!${C_RESET}"
    echo -e "Kullanım: ${C_BOLD}jps-32 help${C_RESET} veya ${C_BOLD}jps help${C_RESET}"

else
    echo -e "${C_RED}[HATA] Desteklenmeyen mimari: $ARCH${C_RESET}"
    exit 1
fi
