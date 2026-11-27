import 'package:flutter_test/flutter_test.dart';

import 'package:bigpay/models/actions/login/login_action.dart';

void main() {
  group('NewLoginAction', () {
    test('targets the new-device sign-in endpoint', () {
      expect(NewLoginAction.path, '/SignIn/newDevice');
    });

    test('payload serializes to phoneNumber + password only', () {
      const payload = NewLoginActionPayload(
        phoneNumber: '233244000000',
        password: 'Temp123\$',
      );

      expect(payload.toJson(), {
        'phoneNumber': '233244000000',
        'password': 'Temp123\$',
      });
      // Regression guard: the phone+password login must NOT send the
      // existing-device unlock's `isPassword` flag.
      expect(payload.toJson().containsKey('isPassword'), isFalse);
    });
  });
}
