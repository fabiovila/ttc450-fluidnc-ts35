#!/usr/bin/env bash
# =============================================================================
# TwoTrees TTC450 / MKS DLC32 V2.1 + MKS TS35-R V2.0 display
# Flashes the FluidNC build with the community TS35 module (PR #1805).
#
# Usage:
#   ./scripts/flash-ts35.sh [/dev/ttyUSB0]
#
# Requirements:
#   - esptool (pip install esptool)  OR  python3 -m esptool
#   - board powered from its 24 V supply (USB alone does NOT power the DLC32)
#   - a backup made with ./scripts/backup-flash.sh
#
# The file written is the full 4 MB image:
#   firmware/ts35/ttc450-ts35-4mb.bin
# It contains bootloader, partition table, app, LittleFS and both configs.
# =============================================================================
set -euo pipefail

detect_port() {
  for p in /dev/ttyUSB0 /dev/ttyACM0 /dev/ttyUSB1 /dev/ttyACM1; do
    [ -e "$p" ] && { echo "$p"; return; }
  done
  echo "/dev/ttyUSB0"
}

PORT="${1:-$(detect_port)}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
IMAGE="$ROOT/firmware/ts35/ttc450-ts35-4mb.bin"

if command -v esptool.py >/dev/null 2>&1; then
  ESPTOOL=(esptool.py)
elif python3 -c 'import esptool' >/dev/null 2>&1; then
  ESPTOOL=(python3 -m esptool)
else
  echo "ERROR: esptool not found. Install it with: python3 -m pip install esptool" >&2
  exit 1
fi

if [ ! -f "$IMAGE" ]; then
  echo "ERROR: image not found: $IMAGE" >&2
  exit 1
fi
if [ ! -e "$PORT" ]; then
  echo "ERROR: port '$PORT' does not exist. Common ports: /dev/ttyUSB0, /dev/ttyACM0" >&2
  exit 1
fi

echo "WARNING: this replaces the stock MKS firmware with FluidNC + TS35."
echo "         Board: $PORT"
echo "         Image: $IMAGE"
read -r -p "Continue? [y/N] " ans
case "$ans" in
  s|S|y|Y) ;;
  *) echo "Cancelled."; exit 0 ;;
esac

COMMON=(--chip esp32 --port "$PORT" --baud 921600
        --before default-reset --after hard-reset)

echo "==> Erasing flash"
"${ESPTOOL[@]}" "${COMMON[@]}" erase-flash

echo "==> Writing full image"
"${ESPTOOL[@]}" "${COMMON[@]}" write-flash -z \
  --flash-mode dio --flash-freq 80m --flash-size detect \
  0x0 "$IMAGE"

echo
echo "OK. First boot:"
echo "  1. The panel should show 'FLUIDNC TS35 / STARTING', then the DRO page."
echo "  2. On your phone/PC, join the WiFi network 'FluidNC' (password 12345678)."
echo "  3. Open http://192.168.0.1/ and configure your workshop WiFi:"
echo "       \$Sta/SSID=YOUR_NETWORK"
echo "       \$Sta/Password=YOUR_PASSWORD"
echo "       \$WiFi/Mode=STA>AP"
echo "       \$Bye"
echo "  4. Touch starts DISABLED (controls_enabled: false)."
echo "     Go to the INFO tab, read the raw touch values and calibrate before"
echo "     setting controls_enabled to true."
echo
echo "Full instructions: docs/en/ts35-firmware.md"
echo
echo "To return to the stock firmware, restore your backup:"
echo "  esptool.py --chip esp32 --port $PORT write_flash 0x0 backup/YOUR_BACKUP.bin"
