// This is a basic Flutter widget test.
//
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cine_translate/main.dart';

void main() {
  testWidgets('App starts with home screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CineTranslateApp());

    // Verify that the home screen title is shown.
    expect(find.text('CINE-TRANSLATE'), findsOneWidget);
  });
}