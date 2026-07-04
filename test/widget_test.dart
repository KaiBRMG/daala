import 'package:daala/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Daala boots to the Splash screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: DaalaApp()));

    expect(find.text('Daala'), findsOneWidget);

    // Let the splash timer fire and navigate (unauthenticated →
    // onboarding), so no timers are pending when the test ends.
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.text('Get things done'), findsOneWidget);
  });
}
