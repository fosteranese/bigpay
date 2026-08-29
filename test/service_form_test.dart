import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/data/cache/process_store.dart';
import 'package:bigpay/data/cache/request_input_store.dart';
import 'package:bigpay/data/cache/response_cache.dart';
import 'package:bigpay/data/database/db.dart';
import 'package:bigpay/data/models/auth_data/activity_datum.dart';
import 'package:bigpay/data/models/general_flow/general_flow_category.dart';
import 'package:bigpay/data/models/general_flow/general_flow_field.dart';
import 'package:bigpay/data/models/general_flow/general_flow_fields_datum.dart';
import 'package:bigpay/data/models/general_flow/general_flow_form.dart';
import 'package:bigpay/data/models/general_flow/general_flow_form_data.dart';
import 'package:bigpay/ui/components/forms/button.dart';
import 'package:bigpay/ui/pages/process_flow/service_form.pg.dart';

GeneralFlowFormData _formData() => const GeneralFlowFormData(
  form: GeneralFlowForm(formName: 'Test Service'),
  fieldsDatum: [
    // Visible, mandatory text field.
    GeneralFlowFieldsDatum(
      field: GeneralFlowField(
        fieldName: 'fullName',
        fieldCaption: 'Full Name',
        fieldType: 1,
        fieldVisible: 1,
        fieldMandatory: 1,
      ),
    ),
    // Visible, optional field — should not block submit.
    GeneralFlowFieldsDatum(
      field: GeneralFlowField(
        fieldName: 'note',
        fieldCaption: 'Note',
        fieldType: 1,
        fieldVisible: 1,
        fieldMandatory: 0,
      ),
    ),
    // Hidden field — should never render.
    GeneralFlowFieldsDatum(
      field: GeneralFlowField(
        fieldName: 'secret',
        fieldCaption: 'Hidden Field',
        fieldType: 1,
        fieldVisible: 0,
        fieldMandatory: 1,
      ),
    ),
  ],
);

Future<void> _pump(WidgetTester tester) async {
  // The form subscribes to ProcessBloc (to submit for verification); it is
  // never driven here, so the store is never touched.
  await tester.pumpWidget(
    BlocProvider<ProcessBloc>(
      create: (_) => ProcessBloc(
        store: ProcessStore(
          cache: ResponseCache(Database()),
          inputs: RequestInputStore(),
        ),
      ),
      child: MaterialApp(
        home: ServiceFormPage(
          activityDatum: const ActivityDatum(),
          category: const GeneralFlowCategory(),
          formData: _formData(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

bool _submitEnabled(WidgetTester tester) =>
    tester.widget<FormButton>(find.widgetWithText(FormButton, 'Submit')).enabled;

void main() {
  testWidgets('renders visible fields and hides hidden ones', (tester) async {
    await _pump(tester);

    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Note'), findsOneWidget);
    expect(find.text('Hidden Field'), findsNothing);
  });

  testWidgets('Submit is disabled until the mandatory field is filled', (tester) async {
    await _pump(tester);

    expect(_submitEnabled(tester), isFalse);

    // The first field is the mandatory one; filling it satisfies validation
    // (the optional field stays empty).
    await tester.enterText(find.byType(TextField).first, 'Jane Doe');
    await tester.pump();

    expect(_submitEnabled(tester), isTrue);
  });

  testWidgets('Submit disables again when the mandatory field is cleared', (tester) async {
    await _pump(tester);

    await tester.enterText(find.byType(TextField).first, 'Jane');
    await tester.pump();
    expect(_submitEnabled(tester), isTrue);

    await tester.enterText(find.byType(TextField).first, '   ');
    await tester.pump();
    expect(_submitEnabled(tester), isFalse);
  });
}
