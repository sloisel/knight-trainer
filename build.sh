#!/bin/bash

# Build script for Chess Trainers
# Embeds base64-encoded assets into HTML templates

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASSETS_DIR="$SCRIPT_DIR/assets"

# Base64 encode assets to temp files (avoids argument length limits)
echo "Encoding assets..."
TMPDIR=$(mktemp -d)
# Use cat | base64 for cross-platform compatibility (macOS vs Linux)
cat "$ASSETS_DIR/fail-buzzer-01.mp3" | base64 | tr -d '\n' > "$TMPDIR/buzzer.b64"
cat "$ASSETS_DIR/joy.mp3" | base64 | tr -d '\n' > "$TMPDIR/joy.b64"
cat "$ASSETS_DIR/SMALL_CROWD_APPLAUSE-Yannick_Lemieux-recompressed.mp3" | base64 | tr -d '\n' > "$TMPDIR/applause.b64"
cat "$ASSETS_DIR/images/dancing.gif" | base64 | tr -d '\n' > "$TMPDIR/dancing.b64"
cat "$ASSETS_DIR/icon.svg" | base64 | tr -d '\n' > "$TMPDIR/icon.b64"
cat "$ASSETS_DIR/I Got a Stick Arr Bryan Teoh.mp3" | base64 | tr -d '\n' > "$TMPDIR/jingle.b64"
cat "$ASSETS_DIR/NotoSansSymbols2-Regular.ttf" | base64 | tr -d '\n' > "$TMPDIR/font.b64"

# Function to build a single game
build_game() {
    local TEMPLATE="$1"
    local OUTPUT="$2"
    local NAME="$3"

    echo "Building $NAME..."

    if [ ! -f "$TEMPLATE" ]; then
        echo "Error: Template not found at $TEMPLATE"
        return 1
    fi

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
    "{{JINGLE_BASE64}}": open("$TMPDIR/jingle.b64").read(),
    "{{FONT_BASE64}}": open("$TMPDIR/font.b64").read(),
}

for placeholder, value in replacements.items():
    content = content.replace(placeholder, value)

with open("$OUTPUT", "w") as f:
    f.write(content)
EOF

    echo "  -> $OUTPUT ($(du -h "$OUTPUT" | cut -f1))"
}

# Build Knight Moves Trainer
build_game "$SCRIPT_DIR/src/game.template.html" "$SCRIPT_DIR/index.html" "Knight Moves Trainer"

# Build Fork Trainer
build_game "$SCRIPT_DIR/src/forks.template.html" "$SCRIPT_DIR/forks.html" "Fork Trainer"

# Cleanup
rm -rf "$TMPDIR"

echo "Build complete!"
