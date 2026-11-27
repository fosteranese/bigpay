import 'package:flutter_test/flutter_test.dart';

import 'package:bigpay/data/models/payee/payee.dart';
import 'package:bigpay/models/actions/services/get_form_payees_action.dart';

void main() {
  final action = GetFormPayeesAction(
    payload: const GetFormPayeesActionPayload(formId: 'form-1'),
  );
  List<Payee> parse(dynamic data) => action.responseDataFunc!(data);

  test('parses payees from the list envelope', () {
    final payees = parse({
      'list': [
        {
          'payeeId': 'p1',
          'title': 'Mum',
          'value': '0244000000',
          'formData': {'accountNumber': '123'},
        },
      ],
    });

    expect(payees, hasLength(1));
    expect(payees.first.title, 'Mum');
    expect(payees.first.value, '0244000000');
    expect(payees.first.formData?['accountNumber'], '123');
    expect(payees.first.displayName, 'Mum');
  });

  test('parses a bare top-level list too', () {
    final payees = parse([
      {'payeeId': 'p1', 'value': 'x'},
      {'payeeId': 'p2', 'value': 'y'},
    ]);

    expect(payees, hasLength(2));
  });

  test('missing/malformed data yields an empty list', () {
    expect(parse(null), isEmpty);
    expect(parse({'other': 1}), isEmpty);
    expect(parse('nonsense'), isEmpty);
  });

  test('the payload carries the formId', () {
    expect(action.payload.toJson(), {'formId': 'form-1'});
  });
}
