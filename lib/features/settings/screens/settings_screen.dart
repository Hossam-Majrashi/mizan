import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/developer_info.dart';
import '../../../core/theme/app_colors.dart';

import 'package:mizan/core/l10n/app_localizations.dart';

import '../services/settings_service.dart';

class SettingsScreen extends StatelessWidget {
  final SettingsService settingsService;

  const SettingsScreen({super.key, required this.settingsService});

  Future<void> _launchUrl(
    BuildContext context,
    String urlString,
    AppLocalizations loc,
  ) async {
    final uri = Uri.parse(urlString);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(loc.msgCouldNotOpenLink)));
        }
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(loc.msgCouldNotOpenLink)));
      }
    }
  }

  void _copyToClipboard(
    BuildContext context,
    String text,
    AppLocalizations loc,
  ) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(loc.msgCopiedToClipboard),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(loc.settingsTitle)),
      body: ListenableBuilder(
        listenable: settingsService,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              // Section 1: Analysis Configuration
              _buildSectionHeader(loc.sectionAnalysis, theme),
              const SizedBox(height: 8),
              _buildCard(
                theme,
                children: [
                  ListTile(
                    title: Text(loc.labelAnalysisDepth),
                    subtitle: Text(
                      _getDepthLabel(loc, settingsService.analysisDepth),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () => _showDepthDialog(context, loc),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: Text(loc.labelTolerance),
                    subtitle: Text(
                      _getToleranceLabel(loc, settingsService.tolerance),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () => _showToleranceDialog(context, loc),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Section 2: General (Language & Theme)
              _buildSectionHeader(loc.sectionGeneral, theme),
              const SizedBox(height: 8),
              _buildCard(
                theme,
                children: [
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: Text(loc.labelLanguage),
                    subtitle: Text(
                      settingsService.locale.languageCode == 'ar'
                          ? 'العربية'
                          : 'English',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () => _showLanguageDialog(context, loc),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.palette_outlined),
                    title: Text(loc.labelTheme),
                    subtitle: Text(
                      _getThemeLabel(loc, settingsService.themeMode),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () => _showThemeDialog(context, loc),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Section 3: Privacy & Security
              _buildSectionHeader(loc.sectionPrivacy, theme),
              const SizedBox(height: 8),
              _buildCard(
                theme,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.shield_outlined,
                              color: AppColors.accentTeal,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              loc.privacyPolicyTitle,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          loc.privacyPolicySummary,
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.75,
                            ),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Section 4: Developer Section (at the end of Settings screen)
              _buildSectionHeader(loc.sectionDeveloper, theme),
              const SizedBox(height: 8),
              _buildCard(
                theme,
                children: [
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: const Text(DeveloperInfo.name),
                    subtitle: Text(
                      '${loc.labelVersion} ${AppConstants.version}',
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.email_outlined),
                    title: Text(loc.labelDeveloperEmail),
                    subtitle: const Text(DeveloperInfo.email),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.copy, size: 18),
                          onPressed: () => _copyToClipboard(
                            context,
                            DeveloperInfo.email,
                            loc,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.open_in_new, size: 18),
                          onPressed: () => _launchUrl(
                            context,
                            'mailto:${DeveloperInfo.email}',
                            loc,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.link),
                    title: Text(loc.labelDeveloperWebsite),
                    subtitle: const Text(DeveloperInfo.website),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.copy, size: 18),
                          onPressed: () => _copyToClipboard(
                            context,
                            DeveloperInfo.website,
                            loc,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.open_in_new, size: 18),
                          onPressed: () =>
                              _launchUrl(context, DeveloperInfo.website, loc),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildCard(ThemeData theme, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(children: children),
    );
  }

  String _getDepthLabel(AppLocalizations loc, String depth) {
    switch (depth) {
      case 'quick':
        return loc.depthQuick;
      case 'thorough':
        return loc.depthThorough;
      default:
        return loc.depthNormal;
    }
  }

  String _getToleranceLabel(AppLocalizations loc, String tol) {
    switch (tol) {
      case 'strict':
        return loc.toleranceStrict;
      case 'lenient':
        return loc.toleranceLenient;
      default:
        return loc.toleranceNormal;
    }
  }

  String _getThemeLabel(AppLocalizations loc, ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return loc.themeLight;
      case ThemeMode.dark:
        return loc.themeDark;
      default:
        return loc.themeSystem;
    }
  }

  void _showDepthDialog(BuildContext context, AppLocalizations loc) {
    showDialog(
      context: context,
      builder: (ctx) {
        return SimpleDialog(
          title: Text(loc.labelAnalysisDepth),
          children: [
            SimpleDialogOption(
              onPressed: () {
                settingsService.setAnalysisDepth('quick');
                Navigator.pop(ctx);
              },
              child: Text(loc.depthQuick),
            ),
            SimpleDialogOption(
              onPressed: () {
                settingsService.setAnalysisDepth('normal');
                Navigator.pop(ctx);
              },
              child: Text(loc.depthNormal),
            ),
            SimpleDialogOption(
              onPressed: () {
                settingsService.setAnalysisDepth('thorough');
                Navigator.pop(ctx);
              },
              child: Text(loc.depthThorough),
            ),
          ],
        );
      },
    );
  }

  void _showToleranceDialog(BuildContext context, AppLocalizations loc) {
    showDialog(
      context: context,
      builder: (ctx) {
        return SimpleDialog(
          title: Text(loc.labelTolerance),
          children: [
            SimpleDialogOption(
              onPressed: () {
                settingsService.setTolerance('strict');
                Navigator.pop(ctx);
              },
              child: Text(loc.toleranceStrict),
            ),
            SimpleDialogOption(
              onPressed: () {
                settingsService.setTolerance('normal');
                Navigator.pop(ctx);
              },
              child: Text(loc.toleranceNormal),
            ),
            SimpleDialogOption(
              onPressed: () {
                settingsService.setTolerance('lenient');
                Navigator.pop(ctx);
              },
              child: Text(loc.toleranceLenient),
            ),
          ],
        );
      },
    );
  }

  void _showLanguageDialog(BuildContext context, AppLocalizations loc) {
    showDialog(
      context: context,
      builder: (ctx) {
        return SimpleDialog(
          title: Text(loc.labelLanguage),
          children: [
            SimpleDialogOption(
              onPressed: () {
                settingsService.setLocale(const Locale('ar'));
                Navigator.pop(ctx);
              },
              child: Text(loc.langArabic),
            ),
            SimpleDialogOption(
              onPressed: () {
                settingsService.setLocale(const Locale('en'));
                Navigator.pop(ctx);
              },
              child: Text(loc.langEnglish),
            ),
          ],
        );
      },
    );
  }

  void _showThemeDialog(BuildContext context, AppLocalizations loc) {
    showDialog(
      context: context,
      builder: (ctx) {
        return SimpleDialog(
          title: Text(loc.labelTheme),
          children: [
            SimpleDialogOption(
              onPressed: () {
                settingsService.setThemeMode(ThemeMode.system);
                Navigator.pop(ctx);
              },
              child: Text(loc.themeSystem),
            ),
            SimpleDialogOption(
              onPressed: () {
                settingsService.setThemeMode(ThemeMode.dark);
                Navigator.pop(ctx);
              },
              child: Text(loc.themeDark),
            ),
            SimpleDialogOption(
              onPressed: () {
                settingsService.setThemeMode(ThemeMode.light);
                Navigator.pop(ctx);
              },
              child: Text(loc.themeLight),
            ),
          ],
        );
      },
    );
  }
}
