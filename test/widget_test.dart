import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mental_load/main.dart';

void main() {
  testWidgets('Mental Load app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MentalLoadApp());

    // Verify that the app starts with the splash screen
    expect(find.text('Mental Load'), findsOneWidget);
    expect(find.text('Understand Your Mental Load'), findsOneWidget);
  });
}