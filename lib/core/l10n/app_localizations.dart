import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Mizan'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Pixel-by-pixel video quality comparison'**
  String get appTagline;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Mizan'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeDesc.
  ///
  /// In en, this message translates to:
  /// **'Compare two videos pixel by pixel, detect upscaling, and discover which video has real, superior picture quality—entirely offline on your device.'**
  String get onboardingWelcomeDesc;

  /// No description provided for @onboardingSelectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get onboardingSelectLanguage;

  /// No description provided for @onboardingSelectTheme.
  ///
  /// In en, this message translates to:
  /// **'Select Theme'**
  String get onboardingSelectTheme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get themeDark;

  /// No description provided for @btnNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get btnNext;

  /// No description provided for @btnGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get btnGetStarted;

  /// No description provided for @btnSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get btnSkip;

  /// No description provided for @slotATitle.
  ///
  /// In en, this message translates to:
  /// **'Video A'**
  String get slotATitle;

  /// No description provided for @slotBTitle.
  ///
  /// In en, this message translates to:
  /// **'Video B'**
  String get slotBTitle;

  /// No description provided for @btnChooseVideo.
  ///
  /// In en, this message translates to:
  /// **'Choose Video'**
  String get btnChooseVideo;

  /// No description provided for @dragAndDropHint.
  ///
  /// In en, this message translates to:
  /// **'or drag & drop video file here'**
  String get dragAndDropHint;

  /// No description provided for @btnSwapVideos.
  ///
  /// In en, this message translates to:
  /// **'Swap Videos'**
  String get btnSwapVideos;

  /// No description provided for @btnClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get btnClear;

  /// No description provided for @btnClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get btnClearAll;

  /// No description provided for @btnCompare.
  ///
  /// In en, this message translates to:
  /// **'Compare Videos'**
  String get btnCompare;

  /// No description provided for @labelSize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get labelSize;

  /// No description provided for @labelDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get labelDuration;

  /// No description provided for @labelResolution.
  ///
  /// In en, this message translates to:
  /// **'Resolution'**
  String get labelResolution;

  /// No description provided for @labelCodec.
  ///
  /// In en, this message translates to:
  /// **'Codec'**
  String get labelCodec;

  /// No description provided for @analyzingTitle.
  ///
  /// In en, this message translates to:
  /// **'Analyzing Videos...'**
  String get analyzingTitle;

  /// No description provided for @stageProbing.
  ///
  /// In en, this message translates to:
  /// **'Probing metadata and streams...'**
  String get stageProbing;

  /// No description provided for @stageExtracting.
  ///
  /// In en, this message translates to:
  /// **'Decoding synchronized frames...'**
  String get stageExtracting;

  /// No description provided for @stageComparing.
  ///
  /// In en, this message translates to:
  /// **'Measuring pixel quality and artifacts...'**
  String get stageComparing;

  /// No description provided for @stageFinalizing.
  ///
  /// In en, this message translates to:
  /// **'Finalizing verdict...'**
  String get stageFinalizing;

  /// No description provided for @btnCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get btnCancel;

  /// No description provided for @analysisCancelled.
  ///
  /// In en, this message translates to:
  /// **'Analysis was cancelled'**
  String get analysisCancelled;

  /// No description provided for @verdictTitle.
  ///
  /// In en, this message translates to:
  /// **'Comparison Verdict'**
  String get verdictTitle;

  /// No description provided for @verdictBestQuality.
  ///
  /// In en, this message translates to:
  /// **'Best Quality: {filename}'**
  String verdictBestQuality(String filename);

  /// No description provided for @verdictSameQuality.
  ///
  /// In en, this message translates to:
  /// **'Same Quality and Frames'**
  String get verdictSameQuality;

  /// No description provided for @verdictMixedQuality.
  ///
  /// In en, this message translates to:
  /// **'Mixed Quality Results'**
  String get verdictMixedQuality;

  /// No description provided for @confidenceHigh.
  ///
  /// In en, this message translates to:
  /// **'High Confidence'**
  String get confidenceHigh;

  /// No description provided for @confidenceMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium Confidence'**
  String get confidenceMedium;

  /// No description provided for @confidenceLow.
  ///
  /// In en, this message translates to:
  /// **'Low Confidence'**
  String get confidenceLow;

  /// No description provided for @warningDifferentVideos.
  ///
  /// In en, this message translates to:
  /// **'Warning: The files appear to be different videos. Quality comparison marked as low confidence.'**
  String get warningDifferentVideos;

  /// No description provided for @sectionComparisonTable.
  ///
  /// In en, this message translates to:
  /// **'Detailed Comparison'**
  String get sectionComparisonTable;

  /// No description provided for @colMetric.
  ///
  /// In en, this message translates to:
  /// **'Metric'**
  String get colMetric;

  /// No description provided for @colWinner.
  ///
  /// In en, this message translates to:
  /// **'Winner'**
  String get colWinner;

  /// No description provided for @metricEffectiveResolution.
  ///
  /// In en, this message translates to:
  /// **'Effective Resolution'**
  String get metricEffectiveResolution;

  /// No description provided for @metricSharpness.
  ///
  /// In en, this message translates to:
  /// **'Sharpness & Fine Detail'**
  String get metricSharpness;

  /// No description provided for @metricArtifacts.
  ///
  /// In en, this message translates to:
  /// **'Compression Artifacts'**
  String get metricArtifacts;

  /// No description provided for @metricNoise.
  ///
  /// In en, this message translates to:
  /// **'Noise Level'**
  String get metricNoise;

  /// No description provided for @metricSsim.
  ///
  /// In en, this message translates to:
  /// **'Structural Similarity (SSIM)'**
  String get metricSsim;

  /// No description provided for @metricPsnr.
  ///
  /// In en, this message translates to:
  /// **'Peak Signal-to-Noise Ratio (PSNR)'**
  String get metricPsnr;

  /// No description provided for @metricFramerate.
  ///
  /// In en, this message translates to:
  /// **'Unique Frame Rate'**
  String get metricFramerate;

  /// No description provided for @metricFrameDuplicates.
  ///
  /// In en, this message translates to:
  /// **'Duplicate Frames'**
  String get metricFrameDuplicates;

  /// No description provided for @metricBitrate.
  ///
  /// In en, this message translates to:
  /// **'Video Bitrate'**
  String get metricBitrate;

  /// No description provided for @metricCodec.
  ///
  /// In en, this message translates to:
  /// **'Video Codec'**
  String get metricCodec;

  /// No description provided for @metricBitDepth.
  ///
  /// In en, this message translates to:
  /// **'Bit Depth & Color'**
  String get metricBitDepth;

  /// No description provided for @metricAudio.
  ///
  /// In en, this message translates to:
  /// **'Audio Stream'**
  String get metricAudio;

  /// No description provided for @metricFileSize.
  ///
  /// In en, this message translates to:
  /// **'File Size'**
  String get metricFileSize;

  /// No description provided for @tagInfoOnly.
  ///
  /// In en, this message translates to:
  /// **'Info only'**
  String get tagInfoOnly;

  /// No description provided for @tagTie.
  ///
  /// In en, this message translates to:
  /// **'Tie'**
  String get tagTie;

  /// No description provided for @sectionFrameInspection.
  ///
  /// In en, this message translates to:
  /// **'Frame Inspection'**
  String get sectionFrameInspection;

  /// No description provided for @viewSideBySide.
  ///
  /// In en, this message translates to:
  /// **'Side by Side'**
  String get viewSideBySide;

  /// No description provided for @viewSlider.
  ///
  /// In en, this message translates to:
  /// **'Split Slider'**
  String get viewSlider;

  /// No description provided for @sampleTimestamp.
  ///
  /// In en, this message translates to:
  /// **'Timestamp: {time}'**
  String sampleTimestamp(String time);

  /// No description provided for @btnPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get btnPrevious;

  /// No description provided for @btnNextSample.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get btnNextSample;

  /// No description provided for @zoomHint.
  ///
  /// In en, this message translates to:
  /// **'Pinch or scroll to zoom pixels'**
  String get zoomHint;

  /// No description provided for @btnCopyReport.
  ///
  /// In en, this message translates to:
  /// **'Copy Report'**
  String get btnCopyReport;

  /// No description provided for @msgReportCopied.
  ///
  /// In en, this message translates to:
  /// **'Report copied to clipboard'**
  String get msgReportCopied;

  /// No description provided for @btnSaveJson.
  ///
  /// In en, this message translates to:
  /// **'Save JSON'**
  String get btnSaveJson;

  /// No description provided for @msgJsonSaved.
  ///
  /// In en, this message translates to:
  /// **'Report saved successfully'**
  String get msgJsonSaved;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @sectionAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Analysis Configuration'**
  String get sectionAnalysis;

  /// No description provided for @labelAnalysisDepth.
  ///
  /// In en, this message translates to:
  /// **'Analysis Depth'**
  String get labelAnalysisDepth;

  /// No description provided for @depthQuick.
  ///
  /// In en, this message translates to:
  /// **'Quick (3 sample points)'**
  String get depthQuick;

  /// No description provided for @depthNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal (7 sample points)'**
  String get depthNormal;

  /// No description provided for @depthThorough.
  ///
  /// In en, this message translates to:
  /// **'Thorough (15 sample points)'**
  String get depthThorough;

  /// No description provided for @labelTolerance.
  ///
  /// In en, this message translates to:
  /// **'Tolerance for Equality'**
  String get labelTolerance;

  /// No description provided for @toleranceStrict.
  ///
  /// In en, this message translates to:
  /// **'Strict (< 1% difference)'**
  String get toleranceStrict;

  /// No description provided for @toleranceNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal (< 3% difference)'**
  String get toleranceNormal;

  /// No description provided for @toleranceLenient.
  ///
  /// In en, this message translates to:
  /// **'Lenient (< 6% difference)'**
  String get toleranceLenient;

  /// No description provided for @sectionGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get sectionGeneral;

  /// No description provided for @labelLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get labelLanguage;

  /// No description provided for @labelTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get labelTheme;

  /// No description provided for @sectionDeveloper.
  ///
  /// In en, this message translates to:
  /// **'About Developer'**
  String get sectionDeveloper;

  /// No description provided for @labelDeveloperEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get labelDeveloperEmail;

  /// No description provided for @labelDeveloperWebsite.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get labelDeveloperWebsite;

  /// No description provided for @msgCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get msgCopiedToClipboard;

  /// No description provided for @msgCouldNotOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Could not open link'**
  String get msgCouldNotOpenLink;

  /// No description provided for @sectionPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get sectionPrivacy;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyTitle;

  /// No description provided for @privacyPolicySummary.
  ///
  /// In en, this message translates to:
  /// **'Mizan works 100% offline. No video files, extracted frames, or metadata ever leave your device. No analytics, tracking, or network permissions used.'**
  String get privacyPolicySummary;

  /// No description provided for @labelVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get labelVersion;

  /// No description provided for @errSameFile.
  ///
  /// In en, this message translates to:
  /// **'You selected the exact same file twice. Please choose two distinct videos.'**
  String get errSameFile;

  /// No description provided for @errNotVideo.
  ///
  /// In en, this message translates to:
  /// **'The selected file is not a supported video file.'**
  String get errNotVideo;

  /// No description provided for @errCorrupt.
  ///
  /// In en, this message translates to:
  /// **'Unable to probe or decode video file.'**
  String get errCorrupt;

  /// No description provided for @errFileMissing.
  ///
  /// In en, this message translates to:
  /// **'The video file could not be found or was moved.'**
  String get errFileMissing;

  /// No description provided for @errPermission.
  ///
  /// In en, this message translates to:
  /// **'Permission to access the file was denied.'**
  String get errPermission;

  /// No description provided for @webDecodingNotice.
  ///
  /// In en, this message translates to:
  /// **'Browser decoding is limited to codecs natively supported by your browser.'**
  String get webDecodingNotice;

  /// No description provided for @langArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get langArabic;

  /// No description provided for @langEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEnglish;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
