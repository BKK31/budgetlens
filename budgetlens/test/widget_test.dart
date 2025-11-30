// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:budgetlens/main.dart';

void main() {
  testWidgets('App starts and shows setup screen on first launch', (WidgetTester tester) async {
    // Set mock initial values for SharedPreferences to simulate a first launch.
    SharedPreferences.setMockInitialValues({});
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // The first screen should be a loading indicator, then the setup screen.
    // We might need to pump a few times to get past the futures.
    await tester.pumpAndSettle(); // pumpAndSettle will wait for all animations and futures to complete.

    // Verify that the setup screen is shown.
    expect(find.text('Setting up a budget'), findsOneWidget);
  });
}
