import 'package:flutter_test/flutter_test.dart';
import 'package:mizan/features/settings/services/settings_service.dart';
import 'package:mizan/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('MizanApp renders onboarding or home screen without crashing', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final settingsService = SettingsService(prefs);

    await tester.pumpWidget(MizanApp(settingsService: settingsService));
    await tester.pumpAndSettle();

    // Verify widget tree is mounted and interactive
    expect(find.byType(MizanApp), findsOneWidget);
  });
}
