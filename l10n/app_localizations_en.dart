// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Mizan';

  @override
  String get appTagline => 'Pixel-by-pixel video quality comparison';

  @override
  String get onboardingWelcomeTitle => 'Welcome to Mizan';

  @override
  String get onboardingWelcomeDesc =>
      'Compare two videos pixel by pixel, detect upscaling, and discover which video has real, superior picture quality—entirely offline on your device.';

  @override
  String get onboardingSelectLanguage => 'Select Language';

  @override
  String get onboardingSelectTheme => 'Select Theme';

  @override
  String get themeSystem => 'Follow System';

  @override
  String get themeLight => 'Light Mode';

  @override
  String get themeDark => 'Dark Mode';

  @override
  String get btnNext => 'Next';

  @override
  String get btnGetStarted => 'Get Started';

  @override
  String get btnSkip => 'Skip';

  @override
  String get slotATitle => 'Video A';

  @override
  String get slotBTitle => 'Video B';

  @override
  String get btnChooseVideo => 'Choose Video';

  @override
  String get dragAndDropHint => 'or drag & drop video file here';

  @override
  String get btnSwapVideos => 'Swap Videos';

  @override
  String get btnClear => 'Clear';

  @override
  String get btnClearAll => 'Clear All';

  @override
  String get btnCompare => 'Compare Videos';

  @override
  String get labelSize => 'Size';

  @override
  String get labelDuration => 'Duration';

  @override
  String get labelResolution => 'Resolution';

  @override
  String get labelCodec => 'Codec';

  @override
  String get analyzingTitle => 'Analyzing Videos...';

  @override
  String get stageProbing => 'Probing metadata and streams...';

  @override
  String get stageExtracting => 'Decoding synchronized frames...';

  @override
  String get stageComparing => 'Measuring pixel quality and artifacts...';

  @override
  String get stageFinalizing => 'Finalizing verdict...';

  @override
  String get btnCancel => 'Cancel';

  @override
  String get analysisCancelled => 'Analysis was cancelled';

  @override
  String get verdictTitle => 'Comparison Verdict';

  @override
  String verdictBestQuality(String filename) {
    return 'Best Quality: $filename';
  }

  @override
  String get verdictSameQuality => 'Same Quality and Frames';

  @override
  String get verdictMixedQuality => 'Mixed Quality Results';

  @override
  String get confidenceHigh => 'High Confidence';

  @override
  String get confidenceMedium => 'Medium Confidence';

  @override
  String get confidenceLow => 'Low Confidence';

  @override
  String get warningDifferentVideos =>
      'Warning: The files appear to be different videos. Quality comparison marked as low confidence.';

  @override
  String get sectionComparisonTable => 'Detailed Comparison';

  @override
  String get colMetric => 'Metric';

  @override
  String get colWinner => 'Winner';

  @override
  String get metricEffectiveResolution => 'Effective Resolution';

  @override
  String get metricSharpness => 'Sharpness & Fine Detail';

  @override
  String get metricArtifacts => 'Compression Artifacts';

  @override
  String get metricNoise => 'Noise Level';

  @override
  String get metricSsim => 'Structural Similarity (SSIM)';

  @override
  String get metricPsnr => 'Peak Signal-to-Noise Ratio (PSNR)';

  @override
  String get metricFramerate => 'Unique Frame Rate';

  @override
  String get metricFrameDuplicates => 'Duplicate Frames';

  @override
  String get metricBitrate => 'Video Bitrate';

  @override
  String get metricCodec => 'Video Codec';

  @override
  String get metricBitDepth => 'Bit Depth & Color';

  @override
  String get metricAudio => 'Audio Stream';

  @override
  String get metricFileSize => 'File Size';

  @override
  String get tagInfoOnly => 'Info only';

  @override
  String get tagTie => 'Tie';

  @override
  String get sectionFrameInspection => 'Frame Inspection';

  @override
  String get viewSideBySide => 'Side by Side';

  @override
  String get viewSlider => 'Split Slider';

  @override
  String sampleTimestamp(String time) {
    return 'Timestamp: $time';
  }

  @override
  String get btnPrevious => 'Previous';

  @override
  String get btnNextSample => 'Next';

  @override
  String get zoomHint => 'Pinch or scroll to zoom pixels';

  @override
  String get btnCopyReport => 'Copy Report';

  @override
  String get msgReportCopied => 'Report copied to clipboard';

  @override
  String get btnSaveJson => 'Save JSON';

  @override
  String get msgJsonSaved => 'Report saved successfully';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get sectionAnalysis => 'Analysis Configuration';

  @override
  String get labelAnalysisDepth => 'Analysis Depth';

  @override
  String get depthQuick => 'Quick (3 sample points)';

  @override
  String get depthNormal => 'Normal (7 sample points)';

  @override
  String get depthThorough => 'Thorough (15 sample points)';

  @override
  String get labelTolerance => 'Tolerance for Equality';

  @override
  String get toleranceStrict => 'Strict (< 1% difference)';

  @override
  String get toleranceNormal => 'Normal (< 3% difference)';

  @override
  String get toleranceLenient => 'Lenient (< 6% difference)';

  @override
  String get sectionGeneral => 'General';

  @override
  String get labelLanguage => 'Language';

  @override
  String get labelTheme => 'Theme';

  @override
  String get sectionDeveloper => 'About Developer';

  @override
  String get labelDeveloperEmail => 'Email';

  @override
  String get labelDeveloperWebsite => 'Website';

  @override
  String get msgCopiedToClipboard => 'Copied to clipboard';

  @override
  String get msgCouldNotOpenLink => 'Could not open link';

  @override
  String get sectionPrivacy => 'Privacy & Security';

  @override
  String get privacyPolicyTitle => 'Privacy Policy';

  @override
  String get privacyPolicySummary =>
      'Mizan works 100% offline. No video files, extracted frames, or metadata ever leave your device. No analytics, tracking, or network permissions used.';

  @override
  String get labelVersion => 'Version';

  @override
  String get errSameFile =>
      'You selected the exact same file twice. Please choose two distinct videos.';

  @override
  String get errNotVideo => 'The selected file is not a supported video file.';

  @override
  String get errCorrupt => 'Unable to probe or decode video file.';

  @override
  String get errFileMissing =>
      'The video file could not be found or was moved.';

  @override
  String get errPermission => 'Permission to access the file was denied.';

  @override
  String get webDecodingNotice =>
      'Browser decoding is limited to codecs natively supported by your browser.';
}
