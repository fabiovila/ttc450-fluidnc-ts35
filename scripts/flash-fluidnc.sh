#!/usr/bin/env bash
# =============================================================================
# TwoTrees TTC450 / MKS DLC32 V2.1 - install stock FluidNC (WiFi build)
#
# Usage:
#   ./scripts/flash-fluidnc.sh [/dev/ttyUSB0] [--keep-nvs]
#
# Without --keep-nvs the flash is erased first (recommended on a first install,
# because the MKS partition layout differs from FluidNC's).
#
# This installs STOCK FluidNC, without TS35 display support. If you want to
# keep the TS35 panel, use ./scripts/flash-ts35.sh instead.
#
# Requirements:
#   - esptool (pip install esptool)  OR  python3 -m esptool
#   - curl and unzip
#   - board powered from its 24 V supply (USB alone does NOT power the DLC32)
#
# WARNING: this replaces the stock firmware. Back it up first with
#          ./scripts/backup-flash.sh
# =============================================================================
set -euo pipefail

detect_port() {
  for p in /dev/ttyUSB0 /dev/ttyACM0 /dev/ttyUSB1 /dev/ttyACM1; do
    [ -e "$p" ] && { echo "$p"; return; }
  done
  echo "/dev/ttyUSB0"
}

PORT=""
KEEP_NVS=0
for arg in "$@"; do
  case "$arg" in
    --keep-nvs) KEEP_NVS=1 ;;
    /dev/*)     PORT="$arg" ;;
    *) echo "Unknown argument: $arg" >&2; exit 1 ;;
  esac
done
[ -n "$PORT" ] || PORT="$(detect_port)"

VERSION="${FLUIDNC_VERSION:-v4.1.1}"
ZIP="fluidnc-$VERSION-win64.zip"
URL="https://github.com/bdring/FluidNC/releases/download/$VERSION/$ZIP"
WORK="${TMPDIR:-/tmp}/fluidnc-$VERSION"

if command -v esptool.py >/dev/null 2>&1; then
  ESPTOOL=(esptool.py)
elif python3 -c 'import esptool' >/dev/null 2>&1; then
  ESPTOOL=(python3 -m esptool)
else
  echo "ERROR: esptool not found. Install it with: python3 -m pip install esptool" >&2
  exit 1
fi

if [ ! -e "$PORT" ]; then
  echo "ERROR: port '$PORT' does not exist. Common ports: /dev/ttyUSB0, /dev/ttyACM0" >&2
  exit 1
fi

mkdir -p "$WORK"
if [ ! -f "$WORK/$ZIP" ]; then
  echo "==> Downloading FluidNC $VERSION"
  curl -L --fail --progress-bar -o "$WORK/$ZIP" "$URL"
fi

if [ ! -d "$WORK/fluidnc-$VERSION-win64/wifi" ]; then
  echo "==> Extracting"
  unzip -q -o "$WORK/$ZIP" -d "$WORK"
fi

BASE="$WORK/fluidnc-$VERSION-win64"
echo
echo "WARNING: the current firmware will be replaced by FluidNC."
echo "         Board: $PORT"
if [ "$KEEP_NVS" -eq 1 ]; then
  echo "         NVS will be preserved (--keep-nvs)."
else
  echo "         The flash will be ERASED first (old NVS/SPIFFS removed)."
fi
read -r -p "Continue? [y/N] " ans
case "$ans" in
  s|S|y|Y) ;;
  *) echo "Cancelled."; exit 0 ;;
esac

COMMON=(--chip esp32 --port "$PORT" --baud 921600
        --before default-reset --after hard-reset)

if [ "$KEEP_NVS" -eq 0 ]; then
  echo "==> Erasing flash"
  "${ESPTOOL[@]}" "${COMMON[@]}" erase-flash
fi

echo "==> Writing FluidNC WiFi build"
"${ESPTOOL[@]}" "${COMMON[@]}" write-flash -z \
  --flash-mode dio --flash-freq 80m --flash-size detect \
  0x1000  "$BASE/wifi/bootloader.bin" \
  0x8000  "$BASE/wifi/partitions.bin" \
  0xe000  "$BASE/common/boot_app0.bin" \
  0x10000 "$BASE/wifi/firmware.bin" \
  0x3d0000 "$BASE/wifi/littlefs.bin"

echo
echo "OK. Next:"
echo "  1. Unplug and replug USB (or reset the board)."
echo "  2. On your phone/PC, join the WiFi network 'FluidNC' (password: 12345678)."
echo "  3. Open http://192.168.0.1/ and upload, via the WebUI file manager (LocalFS):"
echo "       config/config_cnc.yaml"
echo "       config/config_laser.yaml"
echo "  4. In the console, select the mode:"
echo "       \$Config/Filename=config_cnc.yaml"
echo "       \$Bye"
echo "     or:"
echo "       \$Config/Filename=config_laser.yaml"
echo "       \$Bye"
echo "  5. Configure your WiFi:"
echo "       \$Sta/SSID=YOUR_NETWORK"
echo "       \$Sta/Password=YOUR_PASSWORD"
echo "       \$WiFi/Mode=STA>AP"
echo "       \$Bye"
echo
echo "If esptool cannot enter boot mode, hold the BOOT button on the DLC32"
echo "(if present) while plugging USB, or use the FluidNC Web Installer."
