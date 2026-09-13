import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bigpay/ui/components/forms/otp_input.dart';

Future<void> _pump(
  WidgetTester tester, {
  int count = 6,
  void Function(String value)? onChanged,
  void Function(String value)? onCompleted,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: FormOtpInput(
          count: count,
          enableAutofill: false,
          onChanged: onChanged,
          onCompleted: onCompleted,
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('FormOtpInput', () {
    testWidgets('completing the code calls onCompleted once', (tester) async {
      final changes = <String>[];
      String? completed;

      await _pump(
        tester,
        onChanged: changes.add,
        onCompleted: (value) => completed = value,
      );

      await tester.enterText(find.byType(TextField), '123456');
      await tester.pump();

      expect(changes.last, '123456');
      expect(completed, '123456');
    });

    // The single backing field means deleting the last digit is ordinary
    // text-field editing (the controller's text simply gets shorter) rather
    // than something that depends on a backspace key event ever reaching
    // Flutter — the previous per-digit-field design relied on exactly that
    // key event to clear the *previous* box, which real iOS hardware
    // frequently never reports for an already-empty field.
    testWidgets('deleting the last digit is reported via onChanged', (
      tester,
    ) async {
      final changes = <String>[];

      await _pump(tester, onChanged: changes.add);

      await tester.enterText(find.byType(TextField), '123456');
      await tester.pump();
      await tester.enterText(find.byType(TextField), '12345');
      await tester.pump();

      expect(changes.last, '12345');
    });

    testWidgets('pasting more digits than count truncates to count', (
      tester,
    ) async {
      String? completed;

      await _pump(
        tester,
        count: 4,
        onCompleted: (value) => completed = value,
      );

      await tester.enterText(find.byType(TextField), '123456');
      await tester.pump();

      expect(completed, '1234');
    });
  });
}
