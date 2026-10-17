# BUILD_NOTES.md - Compilation, Packaging, and CI/CD Reference

## 1. Local Build Commands

### Android
```bash
# Debug APK
flutter build apk --debug

# Production APKs (per-ABI: armeabi-v7a, arm64-v8a, x86_64)
flutter build apk --split-per-abi --release

# Production Google Play App Bundle (AAB)
flutter build appbundle --release
```

### Linux Desktop
```bash
# Compile release binary
flutter build linux --release

# Package into all formats (tar.gz, deb, rpm, pkg.tar.zst, AppImage)
bash build_linux.sh

# Build Flatpak bundle
bash flatpak_linux.sh
```

### Web
```bash
flutter build web --release
```

### Windows (run on Windows host or PowerShell)
```powershell
flutter build windows --release
.\build_windows.ps1 -Arch x64
```

### macOS (run on macOS host with Xcode)
```bash
flutter build macos --release
bash build_macos.sh
```

## 2. Platform & Architecture Status Matrix

| Platform | Architecture | Build Command | Status | Reason / Environment |
|---|---|---|---|---|
| Linux Desktop | x86_64 | `flutter build linux --release` | **Built & Verified** | Built on Linux host (CachyOS x86_64) |
| Linux Desktop | aarch64 | `flutter build linux --release` | **Source Ready** | GitHub Actions runner `ubuntu-24.04-arm` builds native ARM64 |
| Android | arm64-v8a | `flutter build apk --split-per-abi` | **Built & Verified** | Android SDK 37 toolchain verified |
| Android | armeabi-v7a | `flutter build apk --split-per-abi` | **Built & Verified** | Standard 32-bit ARM Android ABI |
| Android | x86_64 | `flutter build apk --split-per-abi` | **Built & Verified** | Android emulator ABI |
| Web | WASM / JS | `flutter build web --release` | **Source Ready** | Built via web toolchain |
| Windows | x64 | `flutter build windows --release` | **Source Ready** | Built on GitHub `windows-latest` runner |
| Windows | arm64 | `flutter build windows --release` | **Source Ready** | Built on Windows ARM runner |
| macOS | Universal / Apple Silicon | `flutter build macos --release` | **Source Ready** | Built on GitHub `macos-14` runner |

## 3. GitHub Actions CI/CD Pipeline
- **Workflow File**: `.github/workflows/build.yml`
- **Triggers**:
  - `git push` to `main`
  - Pull requests targeting `main`
  - Release tag pushes (`git tag v1.0.0 && git push origin v1.0.0`)
  - Manual trigger via GitHub Actions tab (`workflow_dispatch`)
- **Optional Secrets**:
  - `ANDROID_KEYSTORE_BASE64`: Base64 encoded `.jks` keystore for release APK signing.
  - `ANDROID_KEY_ALIAS`: Keystore alias name.
  - `ANDROID_KEY_PASSWORD`: Keystore key password.
  - `ANDROID_STORE_PASSWORD`: Keystore store password.
- **Artifacts**: All packages automatically uploaded as GitHub workflow artifacts and published to GitHub Releases on tag pushes.
