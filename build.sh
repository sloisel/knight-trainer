#!/bin/bash

# Build script for Knight Moves Trainer
# Embeds base64-encoded assets into the HTML template

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE="$SCRIPT_DIR/src/game.template.html"
OUTPUT="$SCRIPT_DIR/index.html"
ASSETS_DIR="$SCRIPT_DIR/assets"

echo "Building Knight Moves Trainer..."

# Check template exists
if [ ! -f "$TEMPLATE" ]; then
    echo "Error: Template not found at $TEMPLATE"
    exit 1
fi

# Base64 encode assets to temp files (avoids argument length limits)
echo "Encoding assets..."
TMPDIR=$(mktemp -d)
# Use cat | base64 for cross-platform compatibility (macOS vs Linux)
cat "$ASSETS_DIR/fail-buzzer-01.mp3" | base64 | tr -d '\n' > "$TMPDIR/buzzer.b64"
cat "$ASSETS_DIR/joy.mp3" | base64 | tr -d '\n' > "$TMPDIR/joy.b64"
cat "$ASSETS_DIR/SMALL_CROWD_APPLAUSE-Yannick_Lemieux-recompressed.mp3" | base64 | tr -d '\n' > "$TMPDIR/applause.b64"
cat "$ASSETS_DIR/images/dancing.gif" | base64 | tr -d '\n' > "$TMPDIR/dancing.b64"
cat "$ASSETS_DIR/icon.svg" | base64 | tr -d '\n' > "$TMPDIR/icon.b64"

echo "Injecting assets into template..."

# Use Python for reliable substitution with large strings
python3 << EOF
import sys

with open("$TEMPLATE", "r") as f:
    content = f.read()

replacements = {
    "{{BUZZER_BASE64}}": open("$TMPDIR/buzzer.b64").read(),
    "{{JOY_BASE64}}": open("$TMPDIR/joy.b64").read(),
    "{{APPLAUSE_BASE64}}": open("$TMPDIR/applause.b64").read(),
    "{{DANCING_BASE64}}": open("$TMPDIR/dancing.b64").read(),
    "{{ICON_BASE64}}": open("$TMPDIR/icon.b64").read(),
}

for placeholder, value in replacements.items():
    content = content.replace(placeholder, value)

with open("$OUTPUT", "w") as f:
    f.write(content)
EOF

# Cleanup
rm -rf "$TMPDIR"

echo "Build complete: $OUTPUT"
echo "File size: $(du -h "$OUTPUT" | cut -f1)"
