#!/bin/bash
# CHECKSUMS dosyasini otomatik uret
set -euo pipefail

cd "$(dirname "$0")/.."

{
    echo "# JPS checksums - auto-generated"
    echo "# Format: <sha256>  <filename>"
    for f in jps-64 jps-32; do
        [ -f "$f" ] && sha256sum "$f"
    done
} > CHECKSUMS

echo "CHECKSUMS guncellendi:"
cat CHECKSUMS
