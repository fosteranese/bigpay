import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/constants/field.const.dart';
import 'package:bigpay/data/cache/process_store.dart';
import 'package:bigpay/data/cache/request_input_store.dart';
import 'package:bigpay/data/cache/response_cache.dart';
import 'package:bigpay/data/database/db.dart';
import 'package:bigpay/data/models/collection/lov.dart';
import 'package:bigpay/data/models/general_flow/general_flow_field.dart';
import 'package:bigpay/data/models/general_flow/general_flow_fields_datum.dart';
import 'package:bigpay/ui/components/forms/date_input.dart';
import 'package:bigpay/ui/components/forms/form_field_input.dart';
import 'package:bigpay/ui/components/forms/input.dart';
import 'package:bigpay/ui/components/forms/password_input.dart';
import 'package:bigpay/ui/components/forms/payee_input.dart';
import 'package:bigpay/ui/components/forms/select_input.dart';
import 'package:bigpay/ui/components/forms/textarea_input.dart';

Future<void> _pump(WidgetTester tester, GeneralFlowFieldsDatum datum) async {
  // A ProcessBloc is provided because a payee field subscribes to it; it is
  // never driven here, so its store is never touched.
  await tester.pumpWidget(
    BlocProvider<ProcessBloc>(
      create: (_) => ProcessBloc(
        store: ProcessStore(
          cache: ResponseCache(Database()),
          inputs: RequestInputStore(),
        ),
      ),
      child: MaterialApp(
        home: Scaffold(
          body: FormFieldInput(
            datum: datum,
            controller: TextEditingController(),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

GeneralFlowFieldsDatum _field({
  required int fieldType,
  int fieldDataType = FieldDataTypesConst.string,
  int fieldVisible = 1,
  String? formId,
  List<Lov>? lov,
}) {
  return GeneralFlowFieldsDatum(
    lov: lov,
    field: GeneralFlowField(
      fieldType: fieldType,
      fieldDataType: fieldDataType,
      fieldVisible: fieldVisible,
      fieldCaption: 'Field',
      formId: formId,
    ),
  );
}

void main() {
  testWidgets('list-of-values renders a select with the LOV options', (tester) async {
    await _pump(
      tester,
      _field(
        fieldType: FieldTypesConst.listOfValues,
        lov: const [Lov(lovTitle: 'One', lovValue: '1')],
      ),
    );
    expect(find.byType(FormSelectInput), findsOneWidget);
  });

  testWidgets('date field type renders a date input', (tester) async {
    await _pump(tester, _field(fieldType: FieldTypesConst.date));
    expect(find.byType(FormDateInput), findsOneWidget);
  });

  testWidgets('text area renders a textarea input', (tester) async {
    await _pump(tester, _field(fieldType: FieldTypesConst.textArea));
    expect(find.byType(FormTextAreaInput), findsOneWidget);
  });

  testWidgets('password data type renders a password input', (tester) async {
    await _pump(
      tester,
      _field(
        fieldType: FieldTypesConst.textBox,
        fieldDataType: FieldDataTypesConst.password,
      ),
    );
    expect(find.byType(FormPasswordInput), findsOneWidget);
  });

  testWidgets('date-after-current data type renders a bounded date input', (tester) async {
    await _pump(
      tester,
      _field(
        fieldType: FieldTypesConst.textBox,
        fieldDataType: FieldDataTypesConst.dateAfterCurrent,
      ),
    );
    final input = tester.widget<FormDateInput>(find.byType(FormDateInput));
    expect(input.firstDate, isNotNull);
  });

  testWidgets('decimal data type renders a numeric text input', (tester) async {
    await _pump(
      tester,
      _field(
        fieldType: FieldTypesConst.textBox,
        fieldDataType: FieldDataTypesConst.decimal,
      ),
    );
    final input = tester.widget<FormInput>(find.byType(FormInput));
    expect(input.keyboardType, const TextInputType.numberWithOptions(decimal: true));
  });

  testWidgets('payee data type with a formId renders the payee picker', (tester) async {
    await _pump(
      tester,
      _field(
        fieldType: FieldTypesConst.textBox,
        fieldDataType: FieldDataTypesConst.payee,
        formId: 'form-1',
      ),
    );
    expect(find.byType(FormPayeeInput), findsOneWidget);
  });

  testWidgets('payee data type without a formId degrades to text', (tester) async {
    await _pump(
      tester,
      _field(
        fieldType: FieldTypesConst.textBox,
        fieldDataType: FieldDataTypesConst.payee,
      ),
    );
    expect(find.byType(FormPayeeInput), findsNothing);
    expect(find.byType(FormInput), findsOneWidget);
  });

  testWidgets('a hidden field renders nothing', (tester) async {
    await _pump(
      tester,
      _field(fieldType: FieldTypesConst.textBox, fieldVisible: 0),
    );
    expect(find.byType(FormInput), findsNothing);
    expect(find.byType(FormSelectInput), findsNothing);
    expect(find.byType(FormDateInput), findsNothing);
  });
}
