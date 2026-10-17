# Mizan (ميزان)

> Precision Pixel-by-Pixel Video Quality Comparison & Upscaling Detector.

[![Build & Release CI](https://github.com/Hossam-Majrashi/mizan/actions/workflows/build.yml/badge.svg)](https://github.com/Hossam-Majrashi/mizan/actions/workflows/build.yml)

Mizan compares two video files pixel by pixel to determine with mathematical certainty which one has the highest visual quality. Processing occurs entirely offline on your device, ensuring privacy and speed without cloud uploads.

---

## Key Features

- **Effective Resolution & Upscaling Detection**: Uses high-frequency gradient density analysis to expose videos that claim 1080p or 4K but are actually upscaled from 720p or lower.
- **Pixel-Level Picture Quality**: Calculates 3x3 Laplacian edge sharpness, Wang-Bovik compression and blocking artifacts, noise estimation, and SSIM / PSNR fidelity.
- **Frame Rate & Duplicate Detection**: Analyzes declared vs. unique frames, identifying duplicated frames (e.g. 60 fps videos with repeated 30 fps frames) and variable frame rate (VFR) inconsistencies.
- **Strict Priority Verdict Engine**: Evaluates files in prioritized order: Effective Resolution & Pixel Quality -> Unique Frame Rate -> Bitrate & Codec -> Audio (tie-breaker only).
- **Interactive Visual Inspection**: Compare frames side by side or using a Split Slider with pinch/scroll zoom up to 600%.
- **100% Offline & Private**: Zero cloud uploads, zero tracking, zero ads.

---

## Screenshots & Interface

- **Mobile Interface (`screens/mobile`)**: Streamlined vertical ergonomics with quick video swapping and system picker integration.
- **Desktop Interface (`screens/desktop`)**: Wide two-column workspace with dual drag-and-drop slots and docked control center.
- **Web Interface (`screens/web`)**: Adaptive responsive layout with browser decoding compatibility indicators.

---

## Running Locally

### Prerequisites
- [Flutter SDK](https://flutter.dev) (v3.13+ / Dart 3.3+)
- Optional: `ffmpeg` and `ffprobe` installed on system path for enhanced decoding performance.

### Quick Start
```bash
# 1. Clone repository
git clone https://github.com/Hossam-Majrashi/mizan.git
cd mizan

# 2. Install dependencies & generate localizations
flutter pub get
flutter gen-l10n

# 3. Run on your platform
flutter run
```

---

## Automated Builds & Releases

GitHub Actions automatically builds and tests on every push and release tag:
- **Linux**: `.tar.gz`, `.deb`, `.rpm`, `.pkg.tar.zst`, and `.AppImage` (x86_64 and arm64).
- **Android**: Per-ABI `.apk` files and production `.aab` bundle.
- **Windows**: Portable `.zip` and Inno Setup installer.
- **macOS**: Universal Apple Silicon / Intel `.dmg`.
- **Web**: Standalone `.zip` distribution.

Ready-made packages can be downloaded directly from the [GitHub Releases](https://github.com/Hossam-Majrashi/mizan/releases) page.

---

## Verification & Quality Gates

Run the verification test suite and rule checker locally:
```bash
# Run all unit and widget tests
flutter test

# Run verification gates
bash tool/check_rules.sh
```

---

## License & Third-Party Notice
Distributed under the MIT License. Mizan utilizes FFmpeg for media stream extraction under LGPL/GPL terms.

Developer: **حسام حسن مجرشي (Hossam Majrashi)**  
Portfolio: [hossam-majrashi.github.io/Works](https://hossam-majrashi.github.io/Works/)
