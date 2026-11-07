#!/usr/bin/env bash
# =============================================================================
# Package the firmware images into a release zip.
#
# Usage:
#   ./scripts/make-release.sh [VERSION]        # default: git describe or v1.0.0
#
# Output:
#   dist/ttc450-ts35-firmware-<VERSION>.zip
#   dist/ttc450-webui-<VERSION>.zip
#   dist/SHA256SUMS-<VERSION>
#
# Then publish with the GitHub CLI:
#   gh release create <VERSION> \
#     dist/ttc450-ts35-firmware-<VERSION>.zip \
#     dist/ttc450-webui-<VERSION>.zip \
#     firmware/ts35/*.bin firmware/ts35/SHA256SUMS firmware/ts35/BUILD-INFO.txt \
#     --title "TTC450 FluidNC + TS35 <VERSION>" \
#     --notes-file RELEASE_NOTES.md
# =============================================================================
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FW="$ROOT/firmware/ts35"
UI="$ROOT/ui"
VERSION="${1:-$(git -C "$ROOT" describe --tags --always 2>/dev/null || echo v1.0.0)}"
DIST="$ROOT/dist"

[ -d "$FW" ] || { echo "ERROR: $FW not found" >&2; exit 1; }
[ -d "$UI" ] || { echo "ERROR: $UI not found" >&2; exit 1; }
mkdir -p "$DIST"

ZIP="$DIST/ttc450-ts35-firmware-$VERSION.zip"
UIZIP="$DIST/ttc450-webui-$VERSION.zip"
SUMS="$DIST/SHA256SUMS-$VERSION"

echo "==> Verifying existing checksums"
( cd "$FW" && sha256sum -c SHA256SUMS )
( cd "$UI" && sha256sum -c SHA256SUMS )

echo "==> Creating $ZIP"
( cd "$FW" && zip -9 -j "$ZIP" \
    ttc450-ts35-8mb.bin ttc450-ts35-4mb.bin \
    bootloader.bin partitions.bin boot_app0.bin \
    firmware.bin littlefs.bin SHA256SUMS BUILD-INFO.txt README.md )

echo "==> Creating $UIZIP"
( cd "$UI" && zip -9 -j "$UIZIP" \
    index.html.gz help-en.html macros.json favicon.ico \
    webui-original.html.gz README.md README.pt-BR.md \
    COMECE-AQUI.txt SHA256SUMS )

echo "==> Checksums"
( cd "$DIST" && sha256sum "$(basename "$ZIP")" "$(basename "$UIZIP")" > "$(basename "$SUMS")" )
cat "$SUMS"

echo
echo "Done."
echo "  $ZIP"
echo "  $UIZIP"
echo "  $SUMS"
echo
echo "Publish with:"
echo "  gh release create $VERSION \\"
echo "    $ZIP \\"
echo "    $UIZIP \\"
echo "    firmware/ts35/*.bin firmware/ts35/SHA256SUMS firmware/ts35/BUILD-INFO.txt \\"
echo "    --title \"TTC450 FluidNC + TS35 $VERSION\" \\"
echo "    --notes-file RELEASE_NOTES.md"
