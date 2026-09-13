import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bigpay/ui/components/forms/select_input.dart';

Future<void> _pump(
  WidgetTester tester, {
  required TextEditingController controller,
  required List<FormSelectOption> options,
  void Function(String value)? onChanged,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: FormSelectInput(
          controller: controller,
          options: options,
          onChanged: onChanged,
        ),
      ),
    ),
  );
}

void main() {
  group('FormSelectInput auto-select', () {
    testWidgets('a single option is selected automatically', (tester) async {
      final controller = TextEditingController();
      String? changed;

      await _pump(
        tester,
        controller: controller,
        options: [FormSelectOption(id: 'gh', label: 'Ghana')],
        onChanged: (value) => changed = value,
      );
      await tester.pump();

      expect(controller.text, 'gh');
      expect(find.text('Ghana'), findsOneWidget);
      expect(changed, 'Ghana');
    });

    testWidgets('multiple options are left unselected', (tester) async {
      final controller = TextEditingController();

      await _pump(
        tester,
        controller: controller,
        options: [
          FormSelectOption(id: 'gh', label: 'Ghana'),
          FormSelectOption(id: 'ng', label: 'Nigeria'),
        ],
      );
      await tester.pump();

      expect(controller.text, isEmpty);
    });

    testWidgets('an already-selected value is not overwritten', (
      tester,
    ) async {
      final controller = TextEditingController(text: 'existing');
      var callCount = 0;

      await _pump(
        tester,
        controller: controller,
        options: [FormSelectOption(id: 'gh', label: 'Ghana')],
        onChanged: (_) => callCount++,
      );
      await tester.pump();

      expect(controller.text, 'existing');
      expect(callCount, 0);
    });

    testWidgets('an empty options list is left unselected', (tester) async {
      final controller = TextEditingController();

      await _pump(tester, controller: controller, options: const []);
      await tester.pump();

      expect(controller.text, isEmpty);
    });
  });
}
