#!/usr/bin/env bash
# =============================================================================
# TwoTrees TTC450 / MKS DLC32 V2.1 - full 8 MB flash backup
#
# Usage:
#   ./scripts/backup-flash.sh [/dev/ttyUSB0]
#
# Requirements:
#   - esptool (pip install esptool)  OR  python3 -m esptool
#   - board powered from its 24 V supply (USB alone does NOT power the DLC32)
#
# The backup includes NVS (WiFi credentials), SPIFFS (WebUI) and the firmware.
# Keep the .bin somewhere safe before erasing/flashing anything.
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
OUTDIR="$ROOT/backup"
STAMP="$(date +%Y%m%d-%H%M%S)"
OUT="$OUTDIR/ttc450-stock-$STAMP.bin"

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
  echo "Hint: run 'ls /dev/ttyUSB* /dev/ttyACM*' with the board connected." >&2
  exit 1
fi

mkdir -p "$OUTDIR"

echo "==> Reading 8 MB of flash from $PORT"
echo "    (the board must be powered from 24 V, not just USB)"
"${ESPTOOL[@]}" --chip esp32 --port "$PORT" --baud 460800 \
  read_flash 0x000000 0x800000 "$OUT"

SIZE="$(stat -c%s "$OUT" 2>/dev/null || stat -f%z "$OUT")"
if [ "$SIZE" -ne 8388608 ]; then
  echo "ERROR: backup is $SIZE bytes, expected 8388608 (8 MB)." >&2
  exit 1
fi

sha256sum "$OUT" > "$OUT.sha256" 2>/dev/null || shasum -a 256 "$OUT" > "$OUT.sha256"

echo
echo "OK: backup saved to:"
echo "    $OUT"
echo "    $OUT.sha256"
echo
echo "To restore later:"
echo "    ${ESPTOOL[*]} --chip esp32 --port $PORT --baud 460800 write_flash 0x0 '$OUT'"
