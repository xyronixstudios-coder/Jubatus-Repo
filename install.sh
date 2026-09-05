#!/bin/bash

# Renkler
C_RESET="\033[0m"
C_BOLD="\033[1m"
C_CYAN="\033[36m"
C_GREEN="\033[32m"
C_RED="\033[31m"

echo -e "${C_CYAN}${C_BOLD}==========================================${C_RESET}"
echo -e "${C_CYAN}${C_BOLD}    Jubatus Package System (JPS) Kurulumu ${C_RESET}"
echo -e "${C_CYAN}${C_BOLD}        Xyronix Studios - Eren Mut        ${C_RESET}"
echo -e "${C_CYAN}${C_BOLD}==========================================${C_RESET}"

ARCH=$(uname -m)

if [ "$ARCH" = "x86_64" ]; then
    echo -e "${C_GREEN}[+] 64-bit mimari tespit edildi. jps-64 kuruluyor...${C_RESET}"
    if [ -f "jps-64" ]; then
        sudo cp jps-64 /usr/local/bin/jps-64
        sudo chmod +x /usr/local/bin/jps-64
        # jps komutu yazıldığında da jps-64 çalışsın diye sembolik bağ
        sudo ln -sf /usr/local/bin/jps-64 /usr/local/bin/jps
        echo -e "${C_GREEN}${C_BOLD}[BAŞARILI] jps-64 ve jps komutları sisteme eklendi!${C_RESET}"
        echo "Kullanım: jps-64 help veya jps help"
    else
        echo -e "${C_RED}[HATA] jps-64 dosyası dizinde bulunamadı!${C_RESET}"
        exit 1
    fi
elif [ "$ARCH" = "i386" ] || [ "$ARCH" = "i686" ]; then
    echo -e "${C_GREEN}[+] 32-bit mimari tespit edildi. jps-32 kuruluyor...${C_RESET}"
    if [ -f "jps-32" ]; then
        sudo cp jps-32 /usr/local/bin/jps-32
        sudo chmod +x /usr/local/bin/jps-32
        sudo ln -sf /usr/local/bin/jps-32 /usr/local/bin/jps
        echo -e "${C_GREEN}${C_BOLD}[BAŞARILI] jps-32 ve jps komutları sisteme eklendi!${C_RESET}"
        echo "Kullanım: jps-32 help veya jps help"
    else
        echo -e "${C_RED}[HATA] jps-32 dosyası dizinde bulunamadı!${C_RESET}"
        exit 1
    fi
else
    echo -e "${C_RED}[HATA] Desteklenmeyen mimari: $ARCH${C_RESET}"
    exit 1
fi
