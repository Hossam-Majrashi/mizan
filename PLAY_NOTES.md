# PLAY_NOTES.md - Google Play Console Submission Package

## 1. Store Descriptions

### English
**Short Description (Max 80 chars):**
Compare two videos pixel by pixel. Detect upscaling and verify real picture quality.

**Full Description:**
Mizan (ميزان) is a precision video quality analysis tool designed to compare two video files pixel by pixel and determine which copy possesses true, superior picture quality.

Key Features:
- Real vs Upscaled Resolution: Accurately distinguishes native high-resolution video from bicubic/bilinear upscaled files.
- Pixel-Level Metrics: Computes Laplacian sharpness, compression/blocking artifacts, noise estimation, and SSIM / PSNR fidelity.
- Frame Completeness: Identifies duplicated frames (e.g. 60 fps videos with repeated frames), dropped frames, and variable frame rates.
- Interactive Inspection: Inspect frames side by side or using a split slider with pixel-level zoom.
- 100% Offline & Private: Everything runs entirely on your device. Videos never leave your phone, with no account, cloud upload, or tracking required.

---

### العربية (Arabic)
**الوصف القصير (بحد أقصى 80 حرفاً):**
قارن بين مقطعي فيديو بكسل ببكسل واكتشف الجودة الحقيقية والترقية الوهمية بدقة.

**الوصف الكامل:**
تطبيق ميزان (Mizan) هو أداة متقدمة لمقارنة مقطعي فيديو بكسل ببكسل لتحديد أي النسختين تمتلك جودة صورة حقيقية وأعلى نقاءً.

أبرز المميزات:
- كشف الترقية الوهمية (Upscaling): التمييز الدقيق بين الدقة الحقيقية والدقة المصطنعة عبر خوارزميات الترددات العالية.
- مقاييس البكسل الدقيقة: حساب حدة التفاصيل (Sharpness)، تشوهات ضغط الفيديو (Artifacts)، مستوى الضجيج (Noise)، ومقاييس SSIM و PSNR.
- فحص الإطارات: كشف الإطارات المكررة والناقصة ومعدل الإطارات الفعلي الفريد.
- فحص بصري تفاعلي: معاينة الإطارات المتزامنة جنباً إلى جنب أو عبر شريط منزلق مع التكبير لتفحص البكسلات.
- خصوصية تامة وبدون إنترنت: يعمل التطبيق بالكامل محلياً على جهازك دون رفع أي فيديو أو طلب أي حسابات أو تتبع.

---

## 2. Permissions & Manifest Justification
- **Declared Permissions**: None.
- **Storage Access**: Utilizes the modern Android Photo/File Picker. No broad storage permissions (`READ_EXTERNAL_STORAGE` or `MANAGE_EXTERNAL_STORAGE`) requested.
- **Network**: No `INTERNET` permission in the main AndroidManifest.

## 3. Data Safety Declaration
- **Data Collection**: No data collected.
- **Data Sharing**: No data shared with third parties.
- **Data Security**: Fully offline processing; files remain strictly in local sandbox/memory.

## 4. Content Rating & Target Audience
- **Target Age**: Everyone (PEGI 3 / ESRB Everyone).
- **Contains Ads**: No.
- **Contains In-App Purchases**: No.

## 5. Required Screenshots
1. Home Screen with Video A and Video B selected.
2. In-progress analysis sheet showing stages.
3. Verdict Screen with confidence pill and natural language rationale.
4. Detailed A vs B comparison table.
5. Interactive Frame Inspector in Side-by-Side and Split Slider modes.
6. Settings screen showing Theme, Language, and Developer info.
