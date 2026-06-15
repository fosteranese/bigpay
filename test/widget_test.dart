import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bigpay/app.dart';

void main() {
  testWidgets('App shows splash screen on launch', (WidgetTester tester) async {
    await tester.pumpWidget(const BigPayApp());
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
