import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bigpay/utils/message.util.dart';

/// Pumps a screen whose only button invokes [onTap] with a valid context, taps
/// it, and settles the dialog's entrance animation.
Future<void> _open(
  WidgetTester tester,
  void Function(BuildContext context) onTap, {
  bool settle = true,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => onTap(context),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    // The loading dialog's spinner animates forever, so pumpAndSettle would
    // time out. Advance a fixed span past the entrance animation instead.
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  }
}

void main() {
  testWidgets('displayLoading shows a spinner and the message', (tester) async {
    await _open(
      tester,
      (context) => MessageUtil.displayLoading(context, message: 'Please wait'),
      settle: false,
    );

    expect(find.byType(RotationLoader), findsOneWidget);
    expect(find.text('Please wait'), findsOneWidget);
  });

  testWidgets('displayErrorDialog shows title, message, and Ok', (tester) async {
    await _open(
      tester,
      (context) => MessageUtil.displayErrorDialog(
        context,
        title: 'Oops',
        message: 'Something failed',
      ),
    );

    expect(find.text('Oops'), findsOneWidget);
    expect(find.text('Something failed'), findsOneWidget);
    expect(find.text('Ok'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });

  testWidgets('displaySuccessDialog shows title, message, and OK', (tester) async {
    await _open(
      tester,
      (context) => MessageUtil.displaySuccessDialog(
        context,
        title: 'Done',
        message: 'It worked',
        onOk: () {},
      ),
    );

    expect(find.text('Done'), findsOneWidget);
    expect(find.text('It worked'), findsOneWidget);
    expect(find.text('OK'), findsOneWidget);
    expect(find.byIcon(Icons.task_alt_outlined), findsOneWidget);
  });

  testWidgets('displayActionDialog shows Cancel and Confirm', (tester) async {
    var confirmed = false;
    await _open(
      tester,
      (context) => MessageUtil.displayActionDialog(
        context,
        title: 'Sure?',
        onConfirm: () => confirmed = true,
      ),
    );

    expect(find.text('Sure?'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Confirm'), findsOneWidget);

    // Confirm invokes the callback and closes the dialog.
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(confirmed, isTrue);
    expect(find.text('Sure?'), findsNothing);
  });
}
