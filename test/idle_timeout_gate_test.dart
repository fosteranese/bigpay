import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bigpay/ui/widgets/idle_timeout_gate.dart';
import 'package:bigpay/utils/app_state.util.dart';

void main() {
  testWidgets('renders its child and survives idle time without a user', (
    tester,
  ) async {
    AppState.currentUser = null;
    addTearDown(() => AppState.currentUser = null);

    await tester.pumpWidget(
      const MaterialApp(
        home: IdleTimeoutGate(child: SizedBox.expand()),
      ),
    );

    expect(find.byType(SizedBox), findsOneWidget);

    // Without a signed-in user the countdown holds; pumping far past three
    // minutes must not crash or dispatch anything. (Dispatch would need a
    // ProcessBloc, so any attempted logout throws here.)
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(seconds: 5));
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('pointer interaction resets the idle window without crashing', (
    tester,
  ) async {
    AppState.currentUser = null;
    addTearDown(() => AppState.currentUser = null);

    await tester.pumpWidget(
      const MaterialApp(
        home: IdleTimeoutGate(
          child: Scaffold(body: Center(child: Text('hello'))),
        ),
      ),
    );

    await tester.tap(find.text('hello'));
    await tester.pump(const Duration(minutes: 2));
    await tester.tap(find.text('hello'));
    await tester.pump(const Duration(minutes: 2));
    expect(tester.takeException(), isNull);
  });
}