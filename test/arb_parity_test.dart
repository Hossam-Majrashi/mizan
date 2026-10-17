import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ARB key parity test between English and Arabic', () {
    final enFile = File('l10n/app_en.arb');
    final arFile = File('l10n/app_ar.arb');

    expect(enFile.existsSync(), isTrue, reason: 'app_en.arb must exist');
    expect(arFile.existsSync(), isTrue, reason: 'app_ar.arb must exist');

    final enJson =
        jsonDecode(enFile.readAsStringSync()) as Map<String, dynamic>;
    final arJson =
        jsonDecode(arFile.readAsStringSync()) as Map<String, dynamic>;

    // Filter out metadata keys starting with @
    final enKeys = enJson.keys.where((k) => !k.startsWith('@')).toSet();
    final arKeys = arJson.keys.where((k) => !k.startsWith('@')).toSet();

    final missingInArabic = enKeys.difference(arKeys);
    final missingInEnglish = arKeys.difference(enKeys);

    expect(
      missingInArabic,
      isEmpty,
      reason: 'Keys present in English but missing in Arabic: $missingInArabic',
    );
    expect(
      missingInEnglish,
      isEmpty,
      reason:
          'Keys present in Arabic but missing in English: $missingInEnglish',
    );
  });
}
