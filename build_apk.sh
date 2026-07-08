#!/bin/bash
set -e

# TamuKu — Production APK Build Script
# Usage: ./build_apk.sh
# Requires: API_KEY, S3_ACCESS_KEY, S3_SECRET_KEY as env vars or arguments

VERSION=$(grep 'version:' pubspec.yaml | head -1 | awk '{print $2}' | cut -d'+' -f1)
BUILD_NUM=$(grep 'version:' pubspec.yaml | head -1 | awk '{print $2}' | cut -d'+' -f2)

echo "Building TamuKu v${VERSION}+${BUILD_NUM}"

# Validate secrets
if [ -z "$API_KEY" ]; then
    echo "ERROR: API_KEY not set. Usage: API_KEY=xxx ./build_apk.sh"
    exit 1
fi

if [ -z "$S3_ACCESS_KEY" ] || [ -z "$S3_SECRET_KEY" ]; then
    echo "ERROR: S3 keys not set. Usage: S3_ACCESS_KEY=xxx S3_SECRET_KEY=yyy ./build_apk.sh"
    exit 1
fi

# Clean
flutter clean
flutter pub get

# Build release APK with production secrets
flutter build apk --release \
    --dart-define=API_KEY="$API_KEY" \
    --dart-define=S3_ACCESS_KEY="$S3_ACCESS_KEY" \
    --dart-define=S3_SECRET_KEY="$S3_SECRET_KEY"

# Copy to Downloads
OUTPUT="build/app/outputs/flutter-apk/app-release.apk"
DEST="$HOME/Downloads/TamuKu App/tamuku-v${VERSION}.apk"

if [ -f "$OUTPUT" ]; then
    mkdir -p "$(dirname "$DEST")"
    cp "$OUTPUT" "$DEST"
    echo "APK ready: $DEST"
    echo "Size: $(du -h "$DEST" | cut -f1)"
else
    echo "ERROR: Build failed — APK not found"
    exit 1
fi
