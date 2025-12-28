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

# Base64 encode assets (removing newlines)
echo "Encoding assets..."
BUZZER_BASE64=$(base64 -i "$ASSETS_DIR/fail-buzzer-01.mp3" | tr -d '\n')
JOY_BASE64=$(base64 -i "$ASSETS_DIR/joy.mp3" | tr -d '\n')
APPLAUSE_BASE64=$(base64 -i "$ASSETS_DIR/SMALL_CROWD_APPLAUSE-Yannick_Lemieux-recompressed.mp3" | tr -d '\n')
DANCING_BASE64=$(base64 -i "$ASSETS_DIR/images/dancing.gif" | tr -d '\n')

echo "Injecting assets into template..."

# Use awk for safe substitution (handles special characters in base64)
awk -v buzzer="$BUZZER_BASE64" \
    -v joy="$JOY_BASE64" \
    -v applause="$APPLAUSE_BASE64" \
    -v dancing="$DANCING_BASE64" \
    '{
        gsub(/\{\{BUZZER_BASE64\}\}/, buzzer);
        gsub(/\{\{JOY_BASE64\}\}/, joy);
        gsub(/\{\{APPLAUSE_BASE64\}\}/, applause);
        gsub(/\{\{DANCING_BASE64\}\}/, dancing);
        print;
    }' "$TEMPLATE" > "$OUTPUT"

echo "Build complete: $OUTPUT"
echo "File size: $(du -h "$OUTPUT" | cut -f1)"
