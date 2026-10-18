#!/usr/bin/env bash
# =============================================================================
# Package the firmware images into a release zip.
#
# Usage:
#   ./scripts/make-release.sh [VERSION]        # default: git describe or v1.0.0
#
# Output:
#   dist/ttc450-ts35-firmware-<VERSION>.zip
#   dist/SHA256SUMS-<VERSION>
#
# Then publish with the GitHub CLI:
#   gh release create <VERSION> \
#     dist/ttc450-ts35-firmware-<VERSION>.zip \
#     firmware/ts35/*.bin firmware/ts35/SHA256SUMS \
#     --title "TTC450 FluidNC + TS35 <VERSION>" \
#     --notes-file RELEASE_NOTES.md
# =============================================================================
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FW="$ROOT/firmware/ts35"
VERSION="${1:-$(git -C "$ROOT" describe --tags --always 2>/dev/null || echo v1.0.0)}"
DIST="$ROOT/dist"

[ -d "$FW" ] || { echo "ERROR: $FW not found" >&2; exit 1; }
mkdir -p "$DIST"

ZIP="$DIST/ttc450-ts35-firmware-$VERSION.zip"
SUMS="$DIST/SHA256SUMS-$VERSION"

echo "==> Verifying existing checksums"
( cd "$FW" && sha256sum -c SHA256SUMS )

echo "==> Creating $ZIP"
( cd "$FW" && zip -9 -j "$ZIP" \
    ttc450-ts35-8mb.bin ttc450-ts35-4mb.bin \
    bootloader.bin partitions.bin boot_app0.bin \
    firmware.bin littlefs.bin SHA256SUMS BUILD-INFO.txt README.md )

echo "==> Checksums"
( cd "$DIST" && sha256sum "$(basename "$ZIP")" > "$(basename "$SUMS")" )
cat "$SUMS"

echo
echo "Done."
echo "  $ZIP"
echo "  $SUMS"
echo
echo "Publish with:"
echo "  gh release create $VERSION \\"
echo "    $ZIP \\"
echo "    firmware/ts35/*.bin firmware/ts35/SHA256SUMS \\"
echo "    --title \"TTC450 FluidNC + TS35 $VERSION\" \\"
echo "    --notes-file RELEASE_NOTES.md"
