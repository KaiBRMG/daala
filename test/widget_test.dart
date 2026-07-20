import 'package:daala/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Daala boots to the Home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: DaalaApp()));
    await tester.pump();

    // Home lands on the "Earn Moola" view with its hero counter and nav.
    expect(find.text('Available Nearby'), findsOneWidget);
    expect(find.text('24 Gigs'), findsOneWidget);
    expect(find.byIcon(Icons.home_rounded), findsOneWidget);
  });
}
