#!/usr/bin/env bash
set -e

ARCH=$(uname -m)
APP_NAME="mizan"
APP_ID="com.h.mizan"
VERSION=$(grep -m 1 "^version:" pubspec.yaml | cut -d ' ' -f 2 | cut -d '+' -f 1)

echo "=== Building Flatpak for $APP_NAME $VERSION ($ARCH) ==="
mkdir -p dist

if ! command -v flatpak-builder &> /dev/null; then
  echo "flatpak-builder is not installed. To build flatpak locally: sudo pacman -S flatpak-builder (or apt install flatpak-builder)."
  echo "GitHub Actions CI will build flatpak automatically."
  exit 0
fi

BUILD_DIR="build/flatpak_build"
REPO_DIR="build/flatpak_repo"
rm -rf "$BUILD_DIR" "$REPO_DIR"

# Stage source files for flatpak manifest
mkdir -p build/flatpak_stage
cp build/linux/$ARCH/release/bundle/mizan build/flatpak_stage/ 2>/dev/null || cp build/linux/x64/release/bundle/mizan build/flatpak_stage/
cp -r build/linux/$ARCH/release/bundle/data build/flatpak_stage/ 2>/dev/null || cp -r build/linux/x64/release/bundle/data build/flatpak_stage/
cp -r build/linux/$ARCH/release/bundle/lib build/flatpak_stage/ 2>/dev/null || cp -r build/linux/x64/release/bundle/lib build/flatpak_stage/
cp flatpak/com.h.mizan.desktop build/flatpak_stage/
cp flatpak/com.h.mizan.metainfo.xml build/flatpak_stage/
cp assets/icon/app_icon.png build/flatpak_stage/

(cd build/flatpak_stage && flatpak-builder --force-clean --repo="$PWD/../flatpak_repo" "$PWD/../flatpak_build" "$PWD/../../flatpak/com.h.mizan.json")

flatpak build-bundle "$REPO_DIR" "dist/${APP_NAME}-${VERSION}-linux-${ARCH}.flatpak" "$APP_ID"
echo "Created dist/${APP_NAME}-${VERSION}-linux-${ARCH}.flatpak"
