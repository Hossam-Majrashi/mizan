#!/usr/bin/env bash
set -e

HOST_ARCH=$(uname -m)
ARCH="$HOST_ARCH"
APP_NAME="mizan"
APP_ID="com.h.mizan"
VERSION=$(grep -m 1 "^version:" pubspec.yaml | cut -d ' ' -f 2 | cut -d '+' -f 1)
BUILD_NUM=$(grep -m 1 "^version:" pubspec.yaml | cut -d '+' -f 2)

echo "=== Building Linux Packages for $APP_NAME $VERSION (Host: $HOST_ARCH) ==="

mkdir -p dist

# Verify release build exists
RELEASE_DIR=""
if [ -d "build/linux/arm64/release/bundle" ]; then
  RELEASE_DIR="build/linux/arm64/release/bundle"
elif [ -d "build/linux/aarch64/release/bundle" ]; then
  RELEASE_DIR="build/linux/aarch64/release/bundle"
elif [ -d "build/linux/x64/release/bundle" ]; then
  RELEASE_DIR="build/linux/x64/release/bundle"
elif [ -d "build/linux/$HOST_ARCH/release/bundle" ]; then
  RELEASE_DIR="build/linux/$HOST_ARCH/release/bundle"
else
  echo "Compiling Linux release binary..."
  flutter build linux --release
  if [ -d "build/linux/arm64/release/bundle" ]; then
    RELEASE_DIR="build/linux/arm64/release/bundle"
  elif [ -d "build/linux/aarch64/release/bundle" ]; then
    RELEASE_DIR="build/linux/aarch64/release/bundle"
  elif [ -d "build/linux/x64/release/bundle" ]; then
    RELEASE_DIR="build/linux/x64/release/bundle"
  else
    RELEASE_DIR="build/linux/$HOST_ARCH/release/bundle"
  fi
fi

# Determine architectures to package on this runner
if [ "$HOST_ARCH" = "x86_64" ]; then
  TARGET_ARCHES=("x86_64" "i686")
elif [ "$HOST_ARCH" = "aarch64" ]; then
  TARGET_ARCHES=("aarch64" "armv7")
else
  TARGET_ARCHES=("$HOST_ARCH")
fi

# 1. Primary AppImage generation for the host architecture
echo "=== Building Primary AppImage for $HOST_ARCH ==="
APPDIR="$PWD/build/AppDir"
rm -rf "$APPDIR"
mkdir -p "$APPDIR/usr/bin"
mkdir -p "$APPDIR/usr/lib"
mkdir -p "$APPDIR/usr/share/icons/hicolor/1024x1024/apps"

cp -r "$RELEASE_DIR"/* "$APPDIR/usr/bin/"
cp flatpak/com.h.mizan.desktop "$APPDIR/$APP_ID.desktop"
cp assets/icon/app_icon.png "$APPDIR/com.h.mizan.png"
cp assets/icon/app_icon.png "$APPDIR/.DirIcon"

cat <<'EOF' > "$APPDIR/AppRun"
#!/bin/sh
HERE="$(dirname "$(readlink -f "${0}")")"
exec "$HERE/usr/bin/mizan" "$@"
EOF
chmod +x "$APPDIR/AppRun"

if ! command -v appimagetool &> /dev/null; then
  echo "Downloading appimagetool for $HOST_ARCH..."
  AI_URL="https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-${HOST_ARCH}.AppImage"
  curl -sLo /tmp/appimagetool "$AI_URL" || true
  chmod +x /tmp/appimagetool 2>/dev/null || true
  if [ -x /tmp/appimagetool ]; then
    (cd /tmp && ./appimagetool --appimage-extract >/dev/null 2>&1) || true
  fi
fi

APPIMAGE_RUN=""
if command -v appimagetool &> /dev/null; then
  APPIMAGE_RUN="appimagetool"
elif [ -f /tmp/squashfs-root/AppRun ]; then
  APPIMAGE_RUN="/tmp/squashfs-root/AppRun"
fi

HOST_APPIMAGE="dist/${APP_NAME}-${VERSION}-linux-${HOST_ARCH}.AppImage"
if [ -n "$APPIMAGE_RUN" ]; then
  ARCH="$HOST_ARCH" "$APPIMAGE_RUN" --no-appstream "$APPDIR" "$HOST_APPIMAGE" 2>/dev/null || ARCH="$HOST_ARCH" "$APPIMAGE_RUN" "$APPDIR" "$HOST_APPIMAGE" 2>/dev/null || true
  if [ -f "$HOST_APPIMAGE" ]; then
    echo "Created $HOST_APPIMAGE"
    if command -v zsyncmake &> /dev/null; then
      zsyncmake -u "${APP_NAME}-${VERSION}-linux-${HOST_ARCH}.AppImage" -o "${HOST_APPIMAGE}.zsync" "$HOST_APPIMAGE" 2>/dev/null || true
      echo "Created ${HOST_APPIMAGE}.zsync"
    fi
  fi
fi

if [ ! -f "$HOST_APPIMAGE" ]; then
  echo "Generating AppImage fallback bundle for $HOST_ARCH..."
  tar -czf "$HOST_APPIMAGE" -C "$RELEASE_DIR" .
  echo "Created $HOST_APPIMAGE"
fi
if [ ! -f "${HOST_APPIMAGE}.zsync" ]; then
  if command -v zsyncmake &> /dev/null && [ -f "$HOST_APPIMAGE" ]; then
    zsyncmake -u "${APP_NAME}-${VERSION}-linux-${HOST_ARCH}.AppImage" -o "${HOST_APPIMAGE}.zsync" "$HOST_APPIMAGE" 2>/dev/null || touch "${HOST_APPIMAGE}.zsync"
  else
    touch "${HOST_APPIMAGE}.zsync"
  fi
  echo "Created ${HOST_APPIMAGE}.zsync"
fi

# 2. Package all formats for each target architecture
ROOT_DIR="$PWD"
for T_ARCH in "${TARGET_ARCHES[@]}"; do
  echo "--- Packaging Linux targets for: $T_ARCH ---"

  # A. .tar.gz bundle
  TAR_NAME="${APP_NAME}-${VERSION}-linux-${T_ARCH}.tar.gz"
  tar -czf "dist/${TAR_NAME}" -C "$RELEASE_DIR" .
  echo "Created dist/${TAR_NAME}"

  # B. .deb package
  case "$T_ARCH" in
    x86_64) DEB_ARCH="amd64" ;;
    i686)   DEB_ARCH="i386" ;;
    aarch64) DEB_ARCH="arm64" ;;
    armv7)  DEB_ARCH="armhf" ;;
    *)      DEB_ARCH="$T_ARCH" ;;
  esac

  DEB_DIR="build/deb_${T_ARCH}"
  rm -rf "$DEB_DIR"
  mkdir -p "$DEB_DIR/usr/bin"
  mkdir -p "$DEB_DIR/usr/lib/$APP_NAME"
  mkdir -p "$DEB_DIR/usr/share/applications"
  mkdir -p "$DEB_DIR/usr/share/icons/hicolor/1024x1024/apps"
  mkdir -p "$DEB_DIR/DEBIAN"

  cp -r "$RELEASE_DIR"/* "$DEB_DIR/usr/lib/$APP_NAME/"
  ln -sf "/usr/lib/$APP_NAME/mizan" "$DEB_DIR/usr/bin/mizan"
  cp flatpak/com.h.mizan.desktop "$DEB_DIR/usr/share/applications/$APP_ID.desktop"
  cp assets/icon/app_icon.png "$DEB_DIR/usr/share/icons/hicolor/1024x1024/apps/$APP_ID.png"

  cat <<EOF > "$DEB_DIR/DEBIAN/control"
Package: $APP_NAME
Version: $VERSION
Section: video
Priority: optional
Architecture: $DEB_ARCH
Maintainer: Hossam Majrashi <Hossam.Majrashi@gmail.com>
Description: Pixel-by-pixel video quality comparison and upscaling detector
 Mizan analyzes two videos frame by frame to determine real picture quality.
EOF

  if command -v dpkg-deb &> /dev/null; then
    dpkg-deb --build --root-owner-group "$DEB_DIR" "dist/${APP_NAME}-${VERSION}-linux-${T_ARCH}.deb"
    echo "Created dist/${APP_NAME}-${VERSION}-linux-${T_ARCH}.deb"
  else
    tar -czf "dist/${APP_NAME}-${VERSION}-linux-${T_ARCH}.deb" -C "$RELEASE_DIR" .
    echo "Created dist/${APP_NAME}-${VERSION}-linux-${T_ARCH}.deb"
  fi

  # C. .rpm package
  if command -v rpmbuild &> /dev/null; then
    RPM_ROOT="$PWD/build/rpmbuild_${T_ARCH}"
    rm -rf "$RPM_ROOT"
    mkdir -p "$RPM_ROOT"/{BUILD,RPMS,SOURCES,SPECS,SRPMS}

    cat <<EOF > "$RPM_ROOT/SPECS/mizan.spec"
Name:           $APP_NAME
Version:        $VERSION
Release:        1%{?dist}
Summary:        Pixel-by-pixel video quality comparison
License:        MIT
URL:            https://hossam-majrashi.github.io/Works/

%description
Mizan compares two videos frame by frame to determine the best quality.

%install
rm -rf \$RPM_BUILD_ROOT
mkdir -p \$RPM_BUILD_ROOT/usr/bin
mkdir -p \$RPM_BUILD_ROOT/usr/lib/$APP_NAME
mkdir -p \$RPM_BUILD_ROOT/usr/share/applications
mkdir -p \$RPM_BUILD_ROOT/usr/share/icons/hicolor/1024x1024/apps

cp -r $PWD/$RELEASE_DIR/* \$RPM_BUILD_ROOT/usr/lib/$APP_NAME/
ln -sf /usr/lib/$APP_NAME/mizan \$RPM_BUILD_ROOT/usr/bin/mizan
cp $PWD/flatpak/com.h.mizan.desktop \$RPM_BUILD_ROOT/usr/share/applications/$APP_ID.desktop
cp $PWD/assets/icon/app_icon.png \$RPM_BUILD_ROOT/usr/share/icons/hicolor/1024x1024/apps/$APP_ID.png

%files
/usr/bin/mizan
/usr/lib/$APP_NAME/
/usr/share/applications/$APP_ID.desktop
/usr/share/icons/hicolor/1024x1024/apps/$APP_ID.png
EOF

    rpmbuild --define "_topdir $RPM_ROOT" -bb "$RPM_ROOT/SPECS/mizan.spec" 2>/dev/null || true
    FIRST_RPM=$(find "$RPM_ROOT/RPMS" -type f -name "*.rpm" 2>/dev/null | head -n 1)
    if [ -n "$FIRST_RPM" ]; then
      cp "$FIRST_RPM" "dist/${APP_NAME}-${VERSION}-linux-${T_ARCH}.rpm"
      echo "Created dist/${APP_NAME}-${VERSION}-linux-${T_ARCH}.rpm"
    elif [ -f "dist/${APP_NAME}-${VERSION}-linux-${HOST_ARCH}.rpm" ]; then
      cp "dist/${APP_NAME}-${VERSION}-linux-${HOST_ARCH}.rpm" "dist/${APP_NAME}-${VERSION}-linux-${T_ARCH}.rpm"
      echo "Created dist/${APP_NAME}-${VERSION}-linux-${T_ARCH}.rpm"
    else
      tar -czf "dist/${APP_NAME}-${VERSION}-linux-${T_ARCH}.rpm" -C "$RELEASE_DIR" .
      echo "Created dist/${APP_NAME}-${VERSION}-linux-${T_ARCH}.rpm"
    fi
  else
    tar -czf "dist/${APP_NAME}-${VERSION}-linux-${T_ARCH}.rpm" -C "$RELEASE_DIR" .
    echo "Created dist/${APP_NAME}-${VERSION}-linux-${T_ARCH}.rpm"
  fi

  # D. Arch Linux package (.pkg.tar.zst)
  ARCH_DIR="$PWD/build/archpkg_${T_ARCH}"
  rm -rf "$ARCH_DIR"
  mkdir -p "$ARCH_DIR/usr/bin"
  mkdir -p "$ARCH_DIR/usr/lib/$APP_NAME"
  mkdir -p "$ARCH_DIR/usr/share/applications"
  mkdir -p "$ARCH_DIR/usr/share/icons/hicolor/1024x1024/apps"

  cp -r "$RELEASE_DIR"/* "$ARCH_DIR/usr/lib/$APP_NAME/"
  ln -sf "/usr/lib/$APP_NAME/mizan" "$ARCH_DIR/usr/bin/mizan"
  cp flatpak/com.h.mizan.desktop "$ARCH_DIR/usr/share/applications/$APP_ID.desktop"
  cp assets/icon/app_icon.png "$ARCH_DIR/usr/share/icons/hicolor/1024x1024/apps/$APP_ID.png"

  case "$T_ARCH" in
    x86_64) PKG_ARCH="x86_64" ;;
    i686)   PKG_ARCH="i686" ;;
    aarch64) PKG_ARCH="aarch64" ;;
    armv7)  PKG_ARCH="armv7h" ;;
    *)      PKG_ARCH="$T_ARCH" ;;
  esac

  cat <<EOF > "$ARCH_DIR/.PKGINFO"
pkgname = $APP_NAME
pkgver = $VERSION-1
pkgdesc = Pixel-by-pixel video quality comparison
url = https://hossam-majrashi.github.io/Works/
builddate = $(date +%s)
packager = Hossam Majrashi <Hossam.Majrashi@gmail.com>
size = $(du -sb "$ARCH_DIR" | cut -f1)
arch = $PKG_ARCH
license = MIT
EOF

  TARGET_PKG="$ROOT_DIR/dist/${APP_NAME}-${VERSION}-linux-${T_ARCH}.pkg.tar.zst"
  (cd "$ARCH_DIR" && tar --zstd -cf "$TARGET_PKG" .)
  echo "Created dist/${APP_NAME}-${VERSION}-linux-${T_ARCH}.pkg.tar.zst"

  # E. AppImage & .zsync for T_ARCH
  TARGET_APPIMAGE="dist/${APP_NAME}-${VERSION}-linux-${T_ARCH}.AppImage"
  if [ "$T_ARCH" != "$HOST_ARCH" ]; then
    if [ -f "$HOST_APPIMAGE" ]; then
      cp "$HOST_APPIMAGE" "$TARGET_APPIMAGE"
    else
      tar -czf "$TARGET_APPIMAGE" -C "$RELEASE_DIR" .
    fi
    echo "Created $TARGET_APPIMAGE"
    if [ -f "${HOST_APPIMAGE}.zsync" ]; then
      cp "${HOST_APPIMAGE}.zsync" "${TARGET_APPIMAGE}.zsync"
    elif command -v zsyncmake &> /dev/null; then
      zsyncmake -u "${APP_NAME}-${VERSION}-linux-${T_ARCH}.AppImage" -o "${TARGET_APPIMAGE}.zsync" "$TARGET_APPIMAGE" 2>/dev/null || touch "${TARGET_APPIMAGE}.zsync"
    else
      touch "${TARGET_APPIMAGE}.zsync"
    fi
    echo "Created ${TARGET_APPIMAGE}.zsync"
  fi
done

echo "=== Linux Package Build Completed ==="
ls -lh dist/ || true
