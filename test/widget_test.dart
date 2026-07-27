import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bummps/app/app.dart';

void main() {
  testWidgets('Onboarding renders Get Started CTA', (WidgetTester tester) async {
    await tester.pumpWidget(const BummpsApp());
    await tester.pump();

    expect(find.text('Get Started'), findsOneWidget);
    expect(find.byWidgetPredicate((widget) => widget is Image && widget.image is AssetImage && (widget.image as AssetImage).assetName.contains('bummps..png')), findsOneWidget);
  });
}
