import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/data/cache/process_store.dart';
import 'package:bigpay/data/cache/request_input_store.dart';
import 'package:bigpay/data/cache/response_cache.dart';
import 'package:bigpay/data/database/db.dart';
import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/ui/components/forms/payee_input.dart';

Future<void> _pump(
  WidgetTester tester, {
  required TextEditingController controller,
  void Function(String value)? onChanged,
}) async {
  await tester.pumpWidget(
    BlocProvider<ProcessBloc>(
      create: (_) => ProcessBloc(
        store: ProcessStore(
          cache: ResponseCache(Database()),
          inputs: RequestInputStore(),
        ),
      ),
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: FormPayeeInput(
            controller: controller,
            formId: 'form-1',
            onChanged: onChanged,
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('FormPayeeInput', () {
    testWidgets('stays typeable — not a read-only picker-only field', (
      tester,
    ) async {
      await _pump(tester, controller: TextEditingController());

      final field = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(field.enabled, isTrue);
      expect(field.controller!.text, isEmpty);
    });

    testWidgets('typing directly sets the controller and fires onChanged', (
      tester,
    ) async {
      final controller = TextEditingController();
      String? changed;

      await _pump(
        tester,
        controller: controller,
        onChanged: (v) => changed = v,
      );
      await tester.enterText(find.byType(TextFormField), '0244123456');

      expect(controller.text, '0244123456');
      expect(changed, '0244123456');
    });

    testWidgets('shows a retry control while the list has not loaded', (
      tester,
    ) async {
      await _pump(tester, controller: TextEditingController());

      expect(find.byIcon(Icons.refresh_outlined), findsOneWidget);
      expect(find.byIcon(Icons.group_outlined), findsNothing);
    });

    testWidgets('a read-only field has no suffix control at all', (
      tester,
    ) async {
      await tester.pumpWidget(
        BlocProvider<ProcessBloc>(
          create: (_) => ProcessBloc(
            store: ProcessStore(
              cache: ResponseCache(Database()),
              inputs: RequestInputStore(),
            ),
          ),
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: FormPayeeInput(
                controller: TextEditingController(),
                formId: 'form-1',
                readOnly: true,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.refresh_outlined), findsNothing);
      expect(find.byIcon(Icons.group_outlined), findsNothing);
    });
  });
}
