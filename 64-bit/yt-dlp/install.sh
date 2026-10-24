#!/bin/bash
set -euo pipefail
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"

TARGET="/usr/local/bin/yt-dlp"
YTDLP_URL="https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp"

echo ":: yt-dlp indiriliyor..."
curl -fsSL --retry 3 --proto '=https' "$YTDLP_URL" -o /tmp/yt-dlp
sudo cp -f /tmp/yt-dlp "$TARGET"
sudo chmod +x "$TARGET"
rm -f /tmp/yt-dlp
echo "yt-dlp kuruldu: $TARGET"
