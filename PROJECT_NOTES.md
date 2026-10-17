# PROJECT_NOTES.md - Mizan Engineering Notes

## Standing Edit Rule
"Any edit or feature addition MUST be applied across all three platform folders (screens/mobile, screens/desktop, screens/web) that exist in this project, each with its own platform-specific design."

## 1. Assumptions
- **Design folder reference**: No initial `design/` folder existed in the repository; UI/UX architecture was derived cleanly from Section 07 and the strict specifications in `Flutter_Template_EN_Mizan.txt`.
- **System Video Decoder**: System `ffmpeg` and `ffprobe` are utilized when present for optimal decoding performance; pure-Dart container headers parsing is provided as a deterministic fallback.
- **Privacy Model**: The app operates 100% offline. Zero network permissions requested in the main Android manifest.

## 2. Skills Learned & Applied
- **Video Quality Metrics**: Implemented modified 3x3 Laplacian variance for sharpness, Wang-Bovik generalized DCT/block boundary metrics for blockiness/compression artifacts, high-frequency median absolute deviation for noise, and windowed SSIM/PSNR for pixel fidelity.
- **Upscaling & Effective Resolution Detection**: High-frequency edge spectrum analysis determines whether 1080p/4K content contains native high-frequency detail or interpolated lower-resolution source.
- **Desktop Window Management**: Integrated `window_manager` to configure 800x600 minimum size constraints and startup centering.
- **Multi-Platform Icons**: Generated high-resolution 1024x1024 master icon, Android mipmaps, Linux, and Web icons via custom Dart drawing script.
- **Google Play Compliance**: No `INTERNET` permission, storage picker isolation, targetSdk 35+, 16 KB page-alignment compatibility.

## 3. Feature / Platform / Status / Reason Matrix

| Feature | Platform | Status | Reason / Implementation |
|---|---|---|---|
| Video Probing | Linux / macOS / Windows | Fully Working | Uses `ffprobe` JSON stream parser with container header fallback |
| Video Probing | Android | Fully Working | Native file descriptor probing with header fallback |
| Video Probing | Web | Supported | Decodes container metadata supported by browser HTML5 engines |
| Frame Decoding | Linux / macOS / Windows | Fully Working | Decodes sampled frames via ffmpeg pipe; temporary files deleted immediately |
| Frame Decoding | Android | Fully Working | Native frame extraction with deterministic fallback |
| Frame Decoding | Web | Supported | Canvas frame rasterization for natively supported codecs (H.264, VP9) |
| Drag and Drop | Desktop / Web | Fully Working | Integrated `desktop_drop` on both Video A and Video B slots |
| Pixel Analysis | All Platforms | Fully Working | Pure-Dart image processing running in isolate (SSIM, PSNR, Laplacian variance) |
| Settings & Theme | All Platforms | Fully Working | Persisted in `SharedPreferences` (ThemeMode, Language, Depth, Tolerance) |

## 4. State Management & Storage
- Single `SettingsService` backed by `SharedPreferences` and Flutter's built-in `ListenableBuilder` / `ChangeNotifier`.
- Clean separation: logic and processing in `services/`, view models in `models/`, reusable widgets in `widgets/`, and platform screens in `screens/`.
