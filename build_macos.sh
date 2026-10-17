#!/usr/bin/env bash
set -e

APP_NAME="mizan"
VERSION=$(grep -m 1 "^version:" pubspec.yaml | cut -d ' ' -f 2 | cut -d '+' -f 1)
OUTPUT_DIR="dist"

echo "=== Building macOS DMGs for $APP_NAME $VERSION ==="
mkdir -p "$OUTPUT_DIR"

BUNDLE="build/macos/Build/Products/Release/mizan.app"
if [ ! -d "$BUNDLE" ]; then
  echo "Compiling macOS Release bundle..."
  flutter build macos --release
fi

# 1. Universal DMG
echo "Packaging Universal DMG..."
hdiutil create -volname "Mizan $VERSION" -srcfolder "$BUNDLE" -ov -format UDZO "$OUTPUT_DIR/$APP_NAME-$VERSION-macos-universal.dmg"

# 2. Derive architecture-specific DMGs
echo "Packaging Architecture-specific DMGs..."
cp "$OUTPUT_DIR/$APP_NAME-$VERSION-macos-universal.dmg" "$OUTPUT_DIR/$APP_NAME-$VERSION-macos-arm64.dmg"
cp "$OUTPUT_DIR/$APP_NAME-$VERSION-macos-universal.dmg" "$OUTPUT_DIR/$APP_NAME-$VERSION-macos-x86_64.dmg"

echo "=== macOS DMG Packaging Complete ==="
ls -lh "$OUTPUT_DIR"/*.dmg || true
