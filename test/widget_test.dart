import 'package:campus_signal/core/storage/shared_preferences_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_signal/app/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('CampusSignalApp initializes and navigates smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPrefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPrefs),
        ],
        child: const CampusSignalApp(),
      ),
    );

    expect(find.byType(CampusSignalApp), findsOneWidget);

    // Pump past the splash delay (1.8s)
    await tester.pump(const Duration(milliseconds: 1900));
    await tester.pump();
  });
}
