# ميزان (Mizan)

> أداة دقيقة لمقارنة جودة الفيديو بكسل ببكسل وكشف الدقة الوهمية والرفع المصطنع (Upscaling Detector).

[![Build & Release CI](https://github.com/Hossam-Majrashi/mizan/actions/workflows/build.yml/badge.svg)](https://github.com/Hossam-Majrashi/mizan/actions/workflows/build.yml)

---

## العربية

يقارن تطبيق **ميزان** ملفي فيديو بدقة رياضية متناهية إطاراً بإطار وبكسل ببكسل لتحديد أيهما يمتلك الصورة الحقيقية الأفضل جودة. تتم جميع المعالجات والحسابات محلياً بنسبة 100% على جهازك دون الحاجة للاتصال بالإنترنت أو رفع الملفات لأي خادم سحابي، مما يضمن أقصى درجات الخصوصية والسرعة.

---

### لقطات الشاشة

#### الصفحه الرئيسيه
<img width="1920" height="1040" alt="1" src="https://github.com/user-attachments/assets/2dd2bc58-300d-479c-9741-3030ee5509d1" />

#### صفحه المقارنه
<img width="1920" height="1040" alt="2" src="https://github.com/user-attachments/assets/8678bd29-ce5c-49a5-82df-12aa9b8993ec" />

#### الاعدادات
<img width="1920" height="1040" alt="3" src="https://github.com/user-attachments/assets/8de65cac-22a7-4832-a4d1-45369200ca85" />

---

### المميزات الرئيسية

- **كشف الدقة الحقيقية والرفع المصطنع (Effective Resolution & Upscaling Detection)**: كشف الفيديوهات التي تدعي أنها بدقة 1080p أو 4K ولكنها في الواقع مجرد رفع دقة وهمي (Upscaling) من 720p أو أقل عبر تحليل تدرجات التردد العالي (High-Frequency Gradient Density).
- **تحليل جودة البكسل المتقدمة (Pixel-Level Picture Quality)**: قياس حدة الحواف بمصفوفة Laplacian 3x3، واكتشاف تشوهات الضغط والـ Blocking وفق معايير Wang-Bovik، وتقدير مستويات التشويش (Noise)، وحساب قياسات التطابق البصري SSIM و PSNR.
- **تحليل معدل الإطارات وكشف التكرار (Frame Rate & Duplicate Detection)**: تحليل الإطارات المصرح بها مقارنة بالإطارات الفريدة فعلياً، واكتشاف الإطارات المكررة المصطنعة (مثل فيديوهات 60 إطاراً في الثانية التي تكرر إطارات 30 إطاراً) ومشاكل معدل الإطارات المتغير (VFR).
- **محرك الحكم الصارم بالأولويات (Strict Priority Verdict Engine)**: تقييم رياضي حاسم ومبني على شجرة أولويات ثابتة: الدقة الفعلية وجودة البكسل أولاً -> ثم معدل الإطارات الفريد -> ثم معدل البت والترميز -> ثم الصوت كفاصل تعادل فقط.
- **معاينة بصرية تفاعلية دقيقة (Interactive Visual Inspection)**: مقارنة الإطارات المتزامنة جنباً إلى جنب أو عبر شريط التمرير المنزلق (Split Slider) مع إمكانية التكبير حتى 600%.
- **خصوصية مطلقة وعمل بدون إنترنت (100% Offline & Private)**: لا حاجة لأي اتصال بالشبكة، بدون إعلانات، وبدون تتبع أو جمع بيانات.

---

### التشغيل المحلي والتطوير

#### المتطلبات
- [Flutter SDK](https://flutter.dev) (الإصدار v3.13 أو أحدث / Dart 3.3+)
- اختياري: وجود `ffmpeg` و `ffprobe` في مسار النظام لتحسين سرعة فك الترميز.

#### خطوات التشغيل السريع
```bash
# 1. استنساخ المستودع
git clone https://github.com/Hossam-Majrashi/mizan.git
cd mizan

# 2. تثبيت الحزم وتوليد ملفات الترجمة
flutter pub get
flutter gen-l10n

# 3. تشغيل التطبيق على المنصة الحالية
flutter run
```

---

### التنزيل والحزم الجاهزة (GitHub Releases)

يوفر التطبيق 48 حزمة تثبيت متوافقة مع جميع أنظمة التشغيل والمعماريات عبر [GitHub Releases](https://github.com/Hossam-Majrashi/mizan/releases):
- **Linux (28 صيغة عبر x86_64, aarch64, armv7, i686)**: `.AppImage`, `.AppImage.zsync`, `.deb`, `.rpm`, `.pkg.tar.zst`, `.tar.gz`, `.flatpak`.
- **macOS (3 صيغ)**: `.dmg` للأجهزة الشاملة (Universal)، وأجهزة Apple Silicon (M1 وأحدث)، وأجهزة Intel.
- **Windows (9 صيغ عبر x64, arm64, x86)**: `.msi`, `-setup.exe`, `-portable.zip`.
- **Android (5 صيغ)**: حزم APK مخصصة لكل معمارية (arm64-v8a, armeabi-v7a, x86_64)، وحزمة شاملة (universal)، وحزمة المتجر (.aab).
- **iOS (صيغتان)**: `.ipa` و `-unsigned.ipa`.
- **Web (صيغة واحدة)**: حزمة `.zip` جاهزة للاستضافة المباشرة.
- **SHA256SUMS.txt**: للتحقق من سلامة وصحة جميع الملفات.

---

### بوابات التحقق وضمان الجودة

يمكنك تشغيل اختبارات الجودة وبوابات القواعد الصارمة محلياً:
```bash
# تشغيل جميع اختبارات الوحدات والواجهات
flutter test

# تشغيل فحص بوابات القواعد الهندسية
bash tool/check_rules.sh
```

---

### الترخيص والمطور

مرخص بموجب ترخيص MIT المفتوح المصدر. يستخدم التطبيق أدوات FFmpeg لمعالجة الوسائط بموجب شروط تراخيص LGPL/GPL.

المطور: **حسام حسن مجرشي (Hossam Majrashi)**  
معرض الأعمال: [hossam-majrashi.github.io/Works](https://hossam-majrashi.github.io/Works/)

---
---

## English

**Mizan** compares two video files pixel by pixel with mathematical precision to determine with certainty which one holds the true, superior picture quality. All processing runs 100% locally on your machine with zero cloud dependencies, ensuring complete privacy, zero latency, and absolute data safety.

---

### Screenshots

#### Home Screen
<img width="1920" height="1040" alt="1" src="https://github.com/user-attachments/assets/2dd2bc58-300d-479c-9741-3030ee5509d1" />

#### Comparison Screen
<img width="1920" height="1040" alt="2" src="https://github.com/user-attachments/assets/8678bd29-ce5c-49a5-82df-12aa9b8993ec" />

#### Settings Screen
<img width="1920" height="1040" alt="3" src="https://github.com/user-attachments/assets/8de65cac-22a7-4832-a4d1-45369200ca85" />

---

### Key Features

- **Effective Resolution & Upscaling Detection**: Identifies pseudo-resolution files claiming 1080p or 4K that are actually upscaled from 720p or lower via high-frequency gradient density analysis.
- **Pixel-Level Picture Quality**: Measures 3x3 Laplacian edge sharpness, Wang-Bovik compression and blocking artifacts, noise estimation, and SSIM / PSNR visual fidelity.
- **Frame Rate & Duplicate Detection**: Distinguishes declared frame rates from truly unique frames, uncovering duplicated frames (such as 60 fps files duplicating 30 fps content) and variable frame rate (VFR) inconsistencies.
- **Strict Priority Verdict Engine**: Multi-stage hierarchical evaluation: Effective Resolution & Pixel Quality -> Unique Frame Rate -> Bitrate & Codec -> Audio (tie-breaker only).
- **Interactive Visual Inspection**: Synchronized side-by-side or Split Slider comparison with precise pinch/scroll zoom up to 600%.
- **100% Offline & Private**: Zero network access required, zero tracking, zero telemetry, and zero advertisements.

---

### Local Development

#### Prerequisites
- [Flutter SDK](https://flutter.dev) (v3.13+ / Dart 3.3+)
- Optional: `ffmpeg` and `ffprobe` installed on system path for enhanced probe performance.

#### Quick Start
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

### Automated Builds & Downloads (GitHub Releases)

Mizan publishes 48 automated, multi-platform packages on [GitHub Releases](https://github.com/Hossam-Majrashi/mizan/releases):
- **Linux (28 packages across x86_64, aarch64, armv7, i686)**: `.AppImage`, `.AppImage.zsync`, `.deb`, `.rpm`, `.pkg.tar.zst`, `.tar.gz`, `.flatpak`.
- **macOS (3 packages)**: `.dmg` for Universal, Apple Silicon (M1+), and Intel Macs.
- **Windows (9 packages across x64, arm64, x86)**: `.msi`, `-setup.exe`, `-portable.zip`.
- **Android (5 packages)**: Per-ABI `.apk` files (arm64-v8a, armeabi-v7a, x86_64), universal `.apk`, and production `.aab` bundle.
- **iOS (2 packages)**: `.ipa` and `-unsigned.ipa`.
- **Web (1 package)**: Standalone `.zip` ready for self-hosting.
- **SHA256SUMS.txt**: Cryptographic checksum verification for all release files.

---

### Verification & Quality Gates

Run the automated verification suite and engineering rules locally:
```bash
# Run unit and widget tests
flutter test

# Run Mizan engineering rule checks
bash tool/check_rules.sh
```

---

### License & Developer

Distributed under the MIT License. Uses FFmpeg for media stream extraction under LGPL/GPL terms.

Developer: **Hossam Majrashi (حسام حسن مجرشي)**  
Portfolio: [hossam-majrashi.github.io/Works](https://hossam-majrashi.github.io/Works/)
