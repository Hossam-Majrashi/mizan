import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';

class SettingsService extends ChangeNotifier {
  final SharedPreferences _prefs;

  SettingsService(this._prefs) {
    _loadSettings();
  }

  late Locale _locale;
  late ThemeMode _themeMode;
  late String _analysisDepth;
  late String _tolerance;
  late bool _onboardingCompleted;

  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;
  String get analysisDepth => _analysisDepth;
  String get tolerance => _tolerance;
  bool get onboardingCompleted => _onboardingCompleted;

  void _loadSettings() {
    // 1. Language: Default system if Arabic or English, otherwise Arabic
    final savedLang = _prefs.getString(AppConstants.keyLanguage);
    if (savedLang != null) {
      _locale = Locale(savedLang);
    } else {
      final systemLocale =
          WidgetsBinding.instance.platformDispatcher.locale.languageCode;
      if (systemLocale == 'en') {
        _locale = const Locale('en');
      } else {
        _locale = const Locale('ar'); // Default to Arabic
      }
    }

    // 2. ThemeMode: system by default
    final savedTheme = _prefs.getString(AppConstants.keyThemeMode);
    switch (savedTheme) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      default:
        _themeMode = ThemeMode.system;
    }

    // 3. Analysis depth
    _analysisDepth =
        _prefs.getString(AppConstants.keyAnalysisDepth) ?? 'normal';

    // 4. Tolerance
    _tolerance = _prefs.getString(AppConstants.keyTolerance) ?? 'normal';

    // 5. Onboarding completed
    _onboardingCompleted =
        _prefs.getBool(AppConstants.keyOnboardingCompleted) ?? false;
  }

  Future<void> setLocale(Locale newLocale) async {
    _locale = newLocale;
    await _prefs.setString(AppConstants.keyLanguage, newLocale.languageCode);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode newThemeMode) async {
    _themeMode = newThemeMode;
    String modeStr = 'system';
    if (newThemeMode == ThemeMode.light) modeStr = 'light';
    if (newThemeMode == ThemeMode.dark) modeStr = 'dark';
    await _prefs.setString(AppConstants.keyThemeMode, modeStr);
    notifyListeners();
  }

  Future<void> setAnalysisDepth(String depth) async {
    _analysisDepth = depth;
    await _prefs.setString(AppConstants.keyAnalysisDepth, depth);
    notifyListeners();
  }

  Future<void> setTolerance(String tol) async {
    _tolerance = tol;
    await _prefs.setString(AppConstants.keyTolerance, tol);
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _onboardingCompleted = true;
    await _prefs.setBool(AppConstants.keyOnboardingCompleted, true);
    notifyListeners();
  }
}
