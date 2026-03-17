// This is just a simple Flutter widget test I kept from the template.
//
// When I want to interact with widgets in a test, I use WidgetTester from
// flutter_test. For example, I can tap/scroll, find widgets in the tree,
// read text, and check that widget values are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kigali_city_directory/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // I build the app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // I check that the counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // I tap the '+' icon and trigger another frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // I check that the counter increased.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
