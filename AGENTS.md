# AGENTS.md - Mizan Engineering Guidelines

## Standing Edit Rule
"Any edit or feature addition MUST be applied across all three platform folders (screens/mobile, screens/desktop, screens/web) that exist in this project, each with its own platform-specific design."

## Architecture & Coding Principles
1. **Shared Logic**: Written strictly in `lib/shared/` or `lib/features/`, never duplicated between screens.
2. **Platform Screens**: Each form factor has its dedicated design under `lib/screens/mobile`, `lib/screens/desktop`, and `lib/screens/web`.
3. **Localization**: All static user-visible UI strings originate from ARB files (`l10n/app_en.arb` and `l10n/app_ar.arb`).
4. **Theme**: Colors and surface styles are defined in `lib/core/theme/` (`app_colors.dart`, `app_theme.dart`). No hardcoded colors in widgets.
5. **No MediaQuery.of(context).size**: Use `MediaQuery.sizeOf(context)` or `LayoutBuilder`.
6. **No Mock/Fake Logic**: Heavy work runs in background isolates. Probing and decoding uses native or container fallback pipelines.
7. **Verification Gates**: Always run `bash tool/check_rules.sh` and `flutter test` before completing tasks.

## Documentation Index
- [README.md](README.md): Product overview, features, execution, and release downloads.
- [PROJECT_NOTES.md](PROJECT_NOTES.md): Technical details, assumptions, skills, and platform status matrix.
- [DESIGN_DECISIONS.md](DESIGN_DECISIONS.md): Design rationale and responsive ergonomics.
- [BUILD_NOTES.md](BUILD_NOTES.md): Local build commands, packaging scripts, and CI/CD runners.
- [PLAY_NOTES.md](PLAY_NOTES.md): Google Play store listings, permissions, and Data Safety declarations.
- [PRIVACY_POLICY.md](PRIVACY_POLICY.md): 100% offline privacy pledge in Arabic and English.
