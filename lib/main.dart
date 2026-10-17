import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import 'core/theme/app_theme.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/settings/services/settings_service.dart';

import 'package:mizan/core/l10n/app_localizations.dart';

import 'screens/desktop/desktop_home_screen.dart';
import 'screens/mobile/mobile_home_screen.dart';
import 'screens/web/web_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Desktop window manager setup
  if (!kIsWeb && (Platform.isLinux || Platform.isMacOS || Platform.isWindows)) {
    try {
      await windowManager.ensureInitialized();
      const windowOptions = WindowOptions(
        size: Size(1024, 720),
        minimumSize: Size(800, 600),
        center: true,
        title: 'Mizan - Video Quality Comparison',
      );
      await windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });
    } catch (_) {}
  }

  final prefs = await SharedPreferences.getInstance();
  final settingsService = SettingsService(prefs);

  runApp(MizanApp(settingsService: settingsService));
}

class MizanApp extends StatelessWidget {
  final SettingsService settingsService;

  const MizanApp({super.key, required this.settingsService});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settingsService,
      builder: (context, _) {
        return MaterialApp(
          title: 'Mizan',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settingsService.themeMode,
          locale: settingsService.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: settingsService.onboardingCompleted
              ? _buildHomeScreen()
              : OnboardingScreen(
                  settingsService: settingsService,
                  onFinish: () {
                    // Rebuilds automatically due to ListenableBuilder
                  },
                ),
        );
      },
    );
  }

  Widget _buildHomeScreen() {
    if (kIsWeb) {
      return WebHomeScreen(settingsService: settingsService);
    }
    if (Platform.isAndroid || Platform.isIOS) {
      return MobileHomeScreen(settingsService: settingsService);
    }
    return DesktopHomeScreen(settingsService: settingsService);
  }
}
