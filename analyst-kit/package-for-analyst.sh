#!/bin/bash
# Package CZO extraction data + analyst kit into a zip for Chris
#
# Usage: ./package-for-analyst.sh <converter-root>
# Example: ./package-for-analyst.sh "E:/cssi/Cssi.Net/Components/Cssi.Schemas/Cssi.Schemas.Csio.Converters"

CONVERTER_ROOT="${1:-.}"
EXTRACTION_DIR="$CONVERTER_ROOT/.czo-extraction"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT_DIR="$SCRIPT_DIR"
DATE=$(date +%Y-%m-%d)
ZIP_NAME="CZO-Data-$DATE.zip"

if [ ! -d "$EXTRACTION_DIR/carriers" ]; then
    echo "Error: No .czo-extraction/carriers/ found at $CONVERTER_ROOT"
    echo "Run /czo-extractor:extract <Carrier> first to generate extractions."
    exit 1
fi

echo "Packaging CZO data for analyst..."

# Create temp staging directory
STAGING=$(mktemp -d)
mkdir -p "$STAGING/carriers"

# Copy extraction data
cp -r "$EXTRACTION_DIR/carriers" "$STAGING/"
cp "$EXTRACTION_DIR/inventory.json" "$STAGING/" 2>/dev/null
cp "$EXTRACTION_DIR/config.json" "$STAGING/" 2>/dev/null

# Copy analyst kit files
cp "$SCRIPT_DIR/AGENTS.md" "$STAGING/"
cp "$SCRIPT_DIR/SETUP.md" "$STAGING/"
cp -r "$SCRIPT_DIR/.codex" "$STAGING/" 2>/dev/null

# Count carriers
CARRIER_COUNT=$(ls -d "$STAGING/carriers"/*/ 2>/dev/null | wc -l)

# Create zip
cd "$STAGING" && zip -r "$OUTPUT_DIR/$ZIP_NAME" . -x "*.git*"

echo ""
echo "Done! Created: $OUTPUT_DIR/$ZIP_NAME"
echo "Contains $CARRIER_COUNT carrier(s)."
echo ""
echo "Send this to the analyst. They unzip it and run:"
echo "  cd <unzipped-folder>"
echo "  codex"

# Cleanup
rm -rf "$STAGING"
