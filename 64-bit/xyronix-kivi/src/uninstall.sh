#!/usr/bin/env bash
# Xyronix Kivi Editor - uninstaller
set -e

if [ "$EUID" -ne 0 ]; then
    echo "Please run with sudo: sudo ./uninstall.sh"
    exit 1
fi

echo "Removing kivi..."
make uninstall
rm -f /usr/local/bin/kivi
echo "✓ kivi removed."
