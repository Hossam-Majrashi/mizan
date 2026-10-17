// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'ميزان';

  @override
  String get appTagline => 'مقارنة دقيقة لجودة الفيديو بكسل ببكسل';

  @override
  String get onboardingWelcomeTitle => 'مرحباً بك في ميزان';

  @override
  String get onboardingWelcomeDesc =>
      'قارن بين مقطعي فيديو بكسل ببكسل، واكتشف الترقية الوهمية وجودة الصورة الحقيقية المتفوقة—بالكامل على جهازك دون اتصال وبخصوصية تامة.';

  @override
  String get onboardingSelectLanguage => 'اختر لغة التطبيق';

  @override
  String get onboardingSelectTheme => 'اختر مظهر التطبيق';

  @override
  String get themeSystem => 'حسب النظام';

  @override
  String get themeLight => 'المظهر الفاتح';

  @override
  String get themeDark => 'المظهر الداكن';

  @override
  String get btnNext => 'التالي';

  @override
  String get btnGetStarted => 'ابدأ الآن';

  @override
  String get btnSkip => 'تخطي';

  @override
  String get slotATitle => 'الفيديو (أ)';

  @override
  String get slotBTitle => 'الفيديو (ب)';

  @override
  String get btnChooseVideo => 'اختيار فيديو';

  @override
  String get dragAndDropHint => 'أو اسحب وأفلت ملف الفيديو هنا';

  @override
  String get btnSwapVideos => 'تبديل الموضعين';

  @override
  String get btnClear => 'مسح';

  @override
  String get btnClearAll => 'مسح الكل';

  @override
  String get btnCompare => 'بدء فحص المقارنة';

  @override
  String get labelSize => 'الحجم';

  @override
  String get labelDuration => 'المدة';

  @override
  String get labelResolution => 'الدقة';

  @override
  String get labelCodec => 'الترميز';

  @override
  String get analyzingTitle => 'جاري تحليل مقاطع الفيديو...';

  @override
  String get stageProbing => 'فحص البيانات التقنية والمسارات...';

  @override
  String get stageExtracting => 'فك ترميز واستخراج الإطارات المتزامنة...';

  @override
  String get stageComparing => 'قياس جودة البكسلات والتشوهات والمطابقة...';

  @override
  String get stageFinalizing => 'إعداد وتلخيص الحكم النهائي...';

  @override
  String get btnCancel => 'إلغاء';

  @override
  String get analysisCancelled => 'تم إلغاء عملية الفحص';

  @override
  String get verdictTitle => 'الحكم النهائي للمقارنة';

  @override
  String verdictBestQuality(String filename) {
    return 'الجودة الأفضل: $filename';
  }

  @override
  String get verdictSameQuality => 'نفس الجودة والإطارات تماماً';

  @override
  String get verdictMixedQuality => 'نتائج جودة متباينة';

  @override
  String get confidenceHigh => 'ثقة عالية';

  @override
  String get confidenceMedium => 'ثقة متوسطة';

  @override
  String get confidenceLow => 'ثقة منخفضة';

  @override
  String get warningDifferentVideos =>
      'تنبيه: يبدو أن المقطعين ليسا لنفس المحتوى. نتيجة المقارنة منخفضة الثقة.';

  @override
  String get sectionComparisonTable => 'جدول المقارنة التفصيلي';

  @override
  String get colMetric => 'المعيار';

  @override
  String get colWinner => 'الفائز';

  @override
  String get metricEffectiveResolution => 'الدقة الفعلية الحقيقية';

  @override
  String get metricSharpness => 'الحدة والتفاصيل الدقيقة';

  @override
  String get metricArtifacts => 'تشوهات وضغط الصورة';

  @override
  String get metricNoise => 'مستوى الضجيج';

  @override
  String get metricSsim => 'التشابه الهيكلي (SSIM)';

  @override
  String get metricPsnr => 'نسبة الإشارة للضجيج (PSNR)';

  @override
  String get metricFramerate => 'معدل الإطارات الفعلي الفريد';

  @override
  String get metricFrameDuplicates => 'الإطارات المكررة';

  @override
  String get metricBitrate => 'معدل تدفق بيانات الفيديو';

  @override
  String get metricCodec => 'ترميز الفيديو';

  @override
  String get metricBitDepth => 'عمق الألوان';

  @override
  String get metricAudio => 'المسار الصوتي';

  @override
  String get metricFileSize => 'حجم الملف';

  @override
  String get tagInfoOnly => 'للمعلومات فقط';

  @override
  String get tagTie => 'تعادل';

  @override
  String get sectionFrameInspection => 'فحص الإطارات المقارنة';

  @override
  String get viewSideBySide => 'جنباً إلى جنب';

  @override
  String get viewSlider => 'شريط مقارنة منزلق';

  @override
  String sampleTimestamp(String time) {
    return 'التوقيت: $time';
  }

  @override
  String get btnPrevious => 'السابق';

  @override
  String get btnNextSample => 'التالي';

  @override
  String get zoomHint => 'قرّب أو مرر لتكبير وتفحص البكسلات';

  @override
  String get btnCopyReport => 'نسخ التقرير';

  @override
  String get msgReportCopied => 'تم نسخ التقرير إلى الحافظة بنجاح';

  @override
  String get btnSaveJson => 'حفظ ملف JSON';

  @override
  String get msgJsonSaved => 'تم حفظ ملف التقرير بنجاح';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get sectionAnalysis => 'تكوين التحليل';

  @override
  String get labelAnalysisDepth => 'عمق التحليل';

  @override
  String get depthQuick => 'سريع (3 نقاط فحص)';

  @override
  String get depthNormal => 'قياسي (7 نقاط فحص)';

  @override
  String get depthThorough => 'دقيق ومكثف (15 نقطة فحص)';

  @override
  String get labelTolerance => 'هامش التسامح للتطابق';

  @override
  String get toleranceStrict => 'صارم (أقل من 1% فارق)';

  @override
  String get toleranceNormal => 'قياسي (أقل من 3% فارق)';

  @override
  String get toleranceLenient => 'مرن (أقل من 6% فارق)';

  @override
  String get sectionGeneral => 'عام';

  @override
  String get labelLanguage => 'اللغة';

  @override
  String get labelTheme => 'المظهر';

  @override
  String get sectionDeveloper => 'عن المطور';

  @override
  String get labelDeveloperEmail => 'البريد الإلكتروني';

  @override
  String get labelDeveloperWebsite => 'الموقع الشخصي';

  @override
  String get msgCopiedToClipboard => 'تم النسخ إلى الحافظة';

  @override
  String get msgCouldNotOpenLink => 'تعذر فتح الرابط';

  @override
  String get sectionPrivacy => 'الخصوصية والأمان';

  @override
  String get privacyPolicyTitle => 'سياسة الخصوصية';

  @override
  String get privacyPolicySummary =>
      'يعمل تطبيق ميزان بنسبة 100% دون اتصال بالإنترنت. لا تخرج ملفات الفيديو أو الإطارات المفحوصة أو البيانات من جهازك مطلقاً. لا يتضمن أي تحليلات أو تتبع أو أذونات إنترنت.';

  @override
  String get labelVersion => 'الإصدار';

  @override
  String get errSameFile =>
      'لقد قمت باختيار نفس ملف الفيديو مرتين. يرجى اختيار ملفين مختلفين للمقارنة.';

  @override
  String get errNotVideo => 'الملف المختار ليس ملف فيديو مدعوماً.';

  @override
  String get errCorrupt => 'تعذر فحص أو فك ترميز ملف الفيديو.';

  @override
  String get errFileMissing => 'تعذر العثور على ملف الفيديو أو تم نقله.';

  @override
  String get errPermission => 'تم رفض إذن الوصول للملفات.';

  @override
  String get webDecodingNotice =>
      'يعتمد فك ترميز الفيديو في المتصفح على الترميزات المدعومة أصلياً في متصفحك.';
}
