import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bigpay/constants/field.const.dart';
import 'package:bigpay/data/models/general_flow/general_flow_field.dart';
import 'package:bigpay/data/models/general_flow/general_flow_fields_datum.dart';
import 'package:bigpay/data/models/payee/payee.dart';
import 'package:bigpay/utils/payee.util.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const payee = Payee(
    payeeId: 'p1',
    value: '0244123456789',
    formData: {
      'AccountNumber': '0244123456789',
      'Network': 'MTN',
      'amount': '10.00',
    },
  );

  group('payeeSavedFieldValue', () {
    test('matches the field name as-is and case-insensitively', () {
      expect(payeeSavedFieldValue(payee, 'AccountNumber'), '0244123456789');
      // The form definition carries lower-camel names; saved payloads may keep
      // the original casing — either way it resolves.
      expect(payeeSavedFieldValue(payee, 'accountNumber'), '0244123456789');
      expect(payeeSavedFieldValue(payee, 'Network'), 'MTN');
      expect(payeeSavedFieldValue(payee, 'network'), 'MTN');
    });

    test('returns null for missing fields or a null payee', () {
      expect(payeeSavedFieldValue(payee, 'Narrative'), isNull);
      expect(payeeSavedFieldValue(null, 'Network'), isNull);
      expect(
        payeeSavedFieldValue(const Payee(payeeId: 'x'), 'Network'),
        isNull,
      );
    });
  });

  group('prefillFromPayee', () {
    (GeneralFlowFieldsDatum, TextEditingController, FocusNode) item(
      String name,
      int dataType,
    ) {
      return (
        GeneralFlowFieldsDatum(
          field: GeneralFlowField(
            fieldName: name,
            fieldDataType: dataType,
          ),
        ),
        TextEditingController(),
        FocusNode(),
      );
    }

    test('writes saved values into the matching controllers', () {
      final items = [
        item('AccountNumber', FieldDataTypesConst.payeeNumber),
        item('Network', FieldDataTypesConst.string),
        item('Narrative', FieldDataTypesConst.string),
      ];

      prefillFromPayee(payee, items);

      expect(items[0].$2.text, '0244123456789');
      expect(items[1].$2.text, 'MTN');
      expect(items[2].$2.text, isEmpty);
    });

    test(
      'falls back to payee.value for the payee field when formData omits it',
      () {
        const bare = Payee(
          payeeId: 'p2',
          value: '0551234567',
          formData: {'Network': 'VOD'},
        );
        final items = [
          item('AccountNumber', FieldDataTypesConst.payeeNumber),
          item('Network', FieldDataTypesConst.string),
        ];

        prefillFromPayee(bare, items);

        expect(items[0].$2.text, '0551234567');
        expect(items[1].$2.text, 'VOD');
      },
    );

    test('never fills a masked (preview-only) payee.value', () {
      // The backend returns masked values like `20******05` for list
      // previews; they must not end up in a field that gets submitted.
      const masked = Payee(
        payeeId: 'p3',
        value: '20******05',
        formData: {'Network': 'MTN'},
      );
      final items = [
        item('AccountNumber', FieldDataTypesConst.payeeNumber),
      ];

      prefillFromPayee(masked, items);

      expect(items[0].$2.text, isEmpty);
    });

    test('null payee leaves the controllers untouched', () {
      final items = [item('AccountNumber', FieldDataTypesConst.payeeNumber)];
      prefillFromPayee(null, items);
      expect(items[0].$2.text, isEmpty);
    });
  });
}
