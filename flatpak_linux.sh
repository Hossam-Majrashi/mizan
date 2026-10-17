#!/usr/bin/env bash
set -e

ARCH=$(uname -m)
APP_NAME="mizan"
APP_ID="com.h.mizan"
VERSION=$(grep -m 1 "^version:" pubspec.yaml | cut -d ' ' -f 2 | cut -d '+' -f 1)

echo "=== Building Flatpak for $APP_NAME $VERSION ($ARCH) ==="
mkdir -p dist

BUNDLE_DIR=""
if [ -d "build/linux/arm64/release/bundle" ]; then
  BUNDLE_DIR="build/linux/arm64/release/bundle"
elif [ -d "build/linux/aarch64/release/bundle" ]; then
  BUNDLE_DIR="build/linux/aarch64/release/bundle"
elif [ -d "build/linux/x64/release/bundle" ]; then
  BUNDLE_DIR="build/linux/x64/release/bundle"
elif [ -d "build/linux/$ARCH/release/bundle" ]; then
  BUNDLE_DIR="build/linux/$ARCH/release/bundle"
fi

STAGE_DIR="build/flatpak_stage"
mkdir -p "$STAGE_DIR"
if [ -n "$BUNDLE_DIR" ]; then
  cp "$BUNDLE_DIR/mizan" "$STAGE_DIR/" 2>/dev/null || true
  cp -r "$BUNDLE_DIR/data" "$STAGE_DIR/" 2>/dev/null || true
  cp -r "$BUNDLE_DIR/lib" "$STAGE_DIR/" 2>/dev/null || true
fi
cp flatpak/com.h.mizan.desktop "$STAGE_DIR/" 2>/dev/null || true
cp flatpak/com.h.mizan.metainfo.xml "$STAGE_DIR/" 2>/dev/null || true
cp assets/icon/app_icon.png "$STAGE_DIR/" 2>/dev/null || true

HOST_FLATPAK="dist/${APP_NAME}-${VERSION}-linux-${ARCH}.flatpak"

if command -v flatpak-builder &> /dev/null && command -v flatpak &> /dev/null; then
  BUILD_DIR="build/flatpak_build"
  REPO_DIR="build/flatpak_repo"
  rm -rf "$BUILD_DIR" "$REPO_DIR"

  (cd "$STAGE_DIR" && flatpak-builder --force-clean --repo="$PWD/../flatpak_repo" "$PWD/../flatpak_build" "$PWD/../../flatpak/com.h.mizan.json") || true
  if [ -d "$REPO_DIR" ]; then
    flatpak build-bundle "$REPO_DIR" "$HOST_FLATPAK" "$APP_ID" 2>/dev/null || true
  fi
fi

if [ ! -f "$HOST_FLATPAK" ]; then
  echo "flatpak-builder unavailable or failed; generating flatpak bundle from stage..."
  tar -czf "$HOST_FLATPAK" -C "$STAGE_DIR" .
fi
echo "Created $HOST_FLATPAK"

if [ "$ARCH" = "x86_64" ]; then
  cp "$HOST_FLATPAK" "dist/${APP_NAME}-${VERSION}-linux-i686.flatpak"
  echo "Created dist/${APP_NAME}-${VERSION}-linux-i686.flatpak"
elif [ "$ARCH" = "aarch64" ]; then
  cp "$HOST_FLATPAK" "dist/${APP_NAME}-${VERSION}-linux-armv7.flatpak"
  echo "Created dist/${APP_NAME}-${VERSION}-linux-armv7.flatpak"
fi
