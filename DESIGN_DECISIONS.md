# DESIGN_DECISIONS.md - Mizan Interface & Experience Architecture

## 1. User Primary Task
The user possesses two copies of a video (different sources, encodings, or resolutions) and wants to determine with mathematical certainty which file has superior actual picture quality, or if they are virtually identical.

## 2. Layout Ergonomics Across Platforms
- **Mobile (`lib/screens/mobile`)**:
  - Vertical flow with stacked slots: Slot A on top, prominent center swap button, Slot B below.
  - Sticky bottom Compare button with high touch targets (52px height).
  - Modal progress sheet with cancellation during analysis.
- **Desktop (`lib/screens/desktop`)**:
  - Dual-column side-by-side workspace taking advantage of wide displays.
  - Slot A on the left (Cyan accent) and Slot B on the right (Emerald accent).
  - Central swap action and bottom docked control bar with analysis depth indicator.
  - Full desktop drag-and-drop support on both card drop targets.
- **Web (`lib/screens/web`)**:
  - Responsive layout dynamically switching between two-column side-by-side (>= 760px) and stacked column (< 760px) via `LayoutBuilder`.
  - Browser codec compatibility notice banner explaining native browser video capabilities.

## 3. Results Screen Ergonomics
- **Verdict Top Card**: Large definitive statement (e.g. "Best Quality: video_b.mp4") with confidence pill (High, Medium, Low) and natural-language rationale.
- **Interactive Frame Inspector**: Allows users to visually verify the math via either a Side-by-Side view or a Split Slider view with pinch/scroll pixel-level zooming.
- **Comprehensive A vs B Table**: Shows detailed rows for Effective Resolution, Sharpness, Compression Artifacts, Noise, SSIM, PSNR, Unique FPS, Codec, Bitrate, and Audio, with clear winner badges per row.
- **Export Capabilities**: One-tap text report copying and JSON export.

## 4. Theme & Color Palette
- Strict adherence to mandatory dark mode `#212327` (page) and `#232627` (surface), and light mode `#efeef1` (page) and `#fefefe` (surface).
- Precision accents: Video A in Cyan (`#00B4D8`), Video B in Emerald (`#00C853`), and system balance in Teal (`#00BFA5`).
