import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

import 'package:mizan/core/l10n/app_localizations.dart';

import '../../settings/services/settings_service.dart';

class OnboardingScreen extends StatefulWidget {
  final SettingsService settingsService;
  final VoidCallback onFinish;

  const OnboardingScreen({
    super.key,
    required this.settingsService,
    required this.onFinish,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    await widget.settingsService.completeOnboarding();
    widget.onFinish();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Skip button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(3, (index) {
                      final isActive = index == _currentStep;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.accentTeal
                              : theme.colorScheme.outline.withValues(
                                  alpha: 0.4,
                                ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  if (_currentStep < 2)
                    TextButton(onPressed: _finish, child: Text(loc.btnSkip))
                  else
                    const SizedBox(height: 48),
                ],
              ),
            ),
            // PageView Content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentStep = index;
                  });
                },
                children: [
                  _buildAboutStep(loc, theme),
                  _buildLanguageStep(loc, theme),
                  _buildThemeStep(loc, theme),
                ],
              ),
            ),
            // Bottom Action Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  child: Text(
                    _currentStep == 2 ? loc.btnGetStarted : loc.btnNext,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutStep(AppLocalizations loc, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: AppColors.accentTeal, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentTeal.withValues(alpha: 0.18),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset('assets/icon/app_icon.png', fit: BoxFit.cover),
          ),
          const SizedBox(height: 36),
          Text(
            loc.onboardingWelcomeTitle,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            loc.onboardingWelcomeDesc,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageStep(AppLocalizations loc, ThemeData theme) {
    final currentLang = widget.settingsService.locale.languageCode;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.language, size: 64, color: AppColors.accentTeal),
          const SizedBox(height: 24),
          Text(
            loc.onboardingSelectLanguage,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          _buildChoiceTile(
            theme: theme,
            title: 'العربية',
            subtitle: 'Arabic',
            isSelected: currentLang == 'ar',
            onTap: () {
              widget.settingsService.setLocale(const Locale('ar'));
            },
          ),
          const SizedBox(height: 16),
          _buildChoiceTile(
            theme: theme,
            title: 'English',
            subtitle: 'الإنجليزية',
            isSelected: currentLang == 'en',
            onTap: () {
              widget.settingsService.setLocale(const Locale('en'));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildThemeStep(AppLocalizations loc, ThemeData theme) {
    final currentTheme = widget.settingsService.themeMode;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.palette_outlined, size: 64, color: AppColors.accentTeal),
          const SizedBox(height: 24),
          Text(
            loc.onboardingSelectTheme,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 28),
          _buildChoiceTile(
            theme: theme,
            title: loc.themeSystem,
            subtitle: 'Auto',
            isSelected: currentTheme == ThemeMode.system,
            icon: Icons.brightness_auto,
            onTap: () {
              widget.settingsService.setThemeMode(ThemeMode.system);
            },
          ),
          const SizedBox(height: 14),
          _buildChoiceTile(
            theme: theme,
            title: loc.themeDark,
            subtitle: 'Dark',
            isSelected: currentTheme == ThemeMode.dark,
            icon: Icons.dark_mode,
            onTap: () {
              widget.settingsService.setThemeMode(ThemeMode.dark);
            },
          ),
          const SizedBox(height: 14),
          _buildChoiceTile(
            theme: theme,
            title: loc.themeLight,
            subtitle: 'Light',
            isSelected: currentTheme == ThemeMode.light,
            icon: Icons.light_mode,
            onTap: () {
              widget.settingsService.setThemeMode(ThemeMode.light);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceTile({
    required ThemeData theme,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.accentTeal
                : theme.colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: isSelected
                    ? AppColors.accentTeal
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 16),
            ],
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppColors.accentTeal : null,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.accentTeal),
          ],
        ),
      ),
    );
  }
}
