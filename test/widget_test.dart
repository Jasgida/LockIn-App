// This is a basic smoke test for LockIn app
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lockin_app/main.dart';  // This imports your real app

void main() {
  testWidgets('LockIn app launches successfully', (WidgetTester tester) async {
    // Build your actual app
    await tester.pumpWidget(const LockInApp());

    // Just check that the app launches without crashing
    // (This is enough for a basic smoke test)
    expect(find.byType(MaterialApp), findsOneWidget);

    // Optional: Check for a widget you know exists in your app
    // For example, if you have a title "LockIn" somewhere:
    // expect(find.textContaining('LockIn'), findsWidgets);

    // Or check for Login screen elements if you're not logged in
    expect(find.byType(CircularProgressIndicator), findsOneWidget); // during Firebase init
    // or later:
    // expect(find.text('Welcome'), findsOneWidget);
  });
}