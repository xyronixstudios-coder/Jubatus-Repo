#!/bin/bash

echo "=========================================="
echo "    Jubatus Package System (JPS) Kurulumu "
echo "        Xyronix Studios - Eren Mut        "
echo "=========================================="

# Kullanıcının 64-bit mi yoksa 32-bit mi kullandığını tespit et
ARCH=$(uname -m)

if [ "$ARCH" = "x86_64" ]; then
    echo "[+] 64-bit mimari tespit edildi. jps-64 kuruluyor..."
    sudo cp jps-64 /usr/local/bin/jps-64
    sudo chmod +x /usr/local/bin/jps-64
    echo "[BAŞARILI] jps-64 komutu sisteme eklendi!"
    echo "Kullanmak için: jps-64 help"
elif [ "$ARCH" = "i386" ] || [ "$ARCH" = "i686" ]; then
    echo "[+] 32-bit mimari tespit edildi. jps-32 kuruluyor..."
    sudo cp jps-32 /usr/local/bin/jps-32
    sudo chmod +x /usr/local/bin/jps-32
    echo "[BAŞARILI] jps-32 komutu sisteme eklendi!"
    echo "Kullanmak için: jps-32 help"
else
    echo "[HATA] Desteklenmeyen mimari: $ARCH"
    exit 1
fi
