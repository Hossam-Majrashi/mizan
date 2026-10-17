#!/usr/bin/env bash
set -e

ARCH=$(uname -m)
APP_NAME="mizan"
APP_ID="com.h.mizan"
VERSION=$(grep -m 1 "^version:" pubspec.yaml | cut -d ' ' -f 2 | cut -d '+' -f 1)
BUILD_NUM=$(grep -m 1 "^version:" pubspec.yaml | cut -d '+' -f 2)

echo "=== Building Linux Packages for $APP_NAME $VERSION ($ARCH) ==="

mkdir -p dist

# Verify release build exists
RELEASE_DIR="build/linux/$ARCH/release/bundle"
if [ ! -d "$RELEASE_DIR" ]; then
  # Fallback check standard x64 directory
  if [ -d "build/linux/x64/release/bundle" ]; then
    RELEASE_DIR="build/linux/x64/release/bundle"
  else
    echo "Compiling Linux release binary..."
    flutter build linux --release
    RELEASE_DIR="build/linux/$ARCH/release/bundle"
    if [ ! -d "$RELEASE_DIR" ]; then
      RELEASE_DIR="build/linux/x64/release/bundle"
    fi
  fi
fi

# 1. tar.gz package
echo "[1/5] Creating .tar.gz bundle..."
TAR_NAME="${APP_NAME}-${VERSION}-linux-${ARCH}.tar.gz"
tar -czf "dist/${TAR_NAME}" -C "$RELEASE_DIR" .
echo "Created dist/${TAR_NAME}"

# 2. .deb package
echo "[2/5] Creating .deb package..."
DEB_ARCH="amd64"
if [ "$ARCH" = "aarch64" ]; then
  DEB_ARCH="arm64"
fi
DEB_DIR="build/deb_${ARCH}"
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
  dpkg-deb --build --root-owner-group "$DEB_DIR" "dist/${APP_NAME}-${VERSION}-linux-${ARCH}.deb"
  echo "Created dist/${APP_NAME}-${VERSION}-linux-${ARCH}.deb"
else
  echo "dpkg-deb not installed; skipping .deb creation"
fi

# 3. .rpm package
echo "[3/5] Checking rpmbuild..."
if command -v rpmbuild &> /dev/null; then
  RPM_ROOT="$PWD/build/rpmbuild"
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

  rpmbuild --define "_topdir $RPM_ROOT" -bb "$RPM_ROOT/SPECS/mizan.spec"
  cp "$RPM_ROOT"/RPMS/*/*.rpm "dist/${APP_NAME}-${VERSION}-linux-${ARCH}.rpm" || true
  echo "Created dist/${APP_NAME}-${VERSION}-linux-${ARCH}.rpm"
else
  echo "rpmbuild not installed; skipping .rpm creation"
fi

# 4. Arch Linux package (.pkg.tar.zst)
echo "[4/5] Checking makepkg..."
if command -v makepkg &> /dev/null; then
  ARCH_DIR="$PWD/build/archpkg"
  rm -rf "$ARCH_DIR"
  mkdir -p "$ARCH_DIR"
  
  cat <<EOF > "$ARCH_DIR/PKGBUILD"
pkgname=$APP_NAME
pkgver=$VERSION
pkgrel=1
pkgdesc="Pixel-by-pixel video quality comparison"
arch=('$ARCH')
url="https://hossam-majrashi.github.io/Works/"
license=('MIT')

package() {
  install -d "\$pkgdir/usr/bin"
  install -d "\$pkgdir/usr/lib/$APP_NAME"
  install -d "\$pkgdir/usr/share/applications"
  install -d "\$pkgdir/usr/share/icons/hicolor/1024x1024/apps"

  cp -r "$PWD/$RELEASE_DIR"/* "\$pkgdir/usr/lib/$APP_NAME/"
  ln -sf "/usr/lib/$APP_NAME/mizan" "\$pkgdir/usr/bin/mizan"
  install -m 644 "$PWD/flatpak/com.h.mizan.desktop" "\$pkgdir/usr/share/applications/$APP_ID.desktop"
  install -m 644 "$PWD/assets/icon/app_icon.png" "\$pkgdir/usr/share/icons/hicolor/1024x1024/apps/$APP_ID.png"
}
EOF

  (cd "$ARCH_DIR" && makepkg -f --nodeps)
  cp "$ARCH_DIR"/*.pkg.tar.zst "dist/${APP_NAME}-${VERSION}-linux-${ARCH}.pkg.tar.zst" || true
  echo "Created dist/${APP_NAME}-${VERSION}-linux-${ARCH}.pkg.tar.zst"
else
  echo "makepkg not installed; skipping .pkg.tar.zst creation"
fi

# 5. AppImage
echo "[5/5] Checking appimagetool..."
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

if command -v appimagetool &> /dev/null; then
  appimagetool "$APPDIR" "dist/${APP_NAME}-${VERSION}-linux-${ARCH}.AppImage"
  echo "Created dist/${APP_NAME}-${VERSION}-linux-${ARCH}.AppImage"
else
  echo "appimagetool not installed; created AppDir in build/AppDir"
fi

echo "=== Linux Package Build Completed ==="
ls -lh dist/ || true
