import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_app/main.dart';

void main() {
  testWidgets('Home screen loads', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const MoApp());

    // Verify app title
    expect(find.text('Mo'), findsOneWidget);

    // Verify main action button
    expect(find.text('Create Wedding Highlight'), findsOneWidget);
  });
}
