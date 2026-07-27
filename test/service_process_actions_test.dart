import 'package:flutter_test/flutter_test.dart';

import 'package:bigpay/data/models/general_flow/form_verification_response.dart';
import 'package:bigpay/data/models/general_flow/request_response.dart';
import 'package:bigpay/models/actions/services/process_request_action.dart';
import 'package:bigpay/models/actions/services/verify_service_form_action.dart';

void main() {
  group('VerifyServiceFormAction', () {
    final action = VerifyServiceFormAction(
      payload: const VerifyServiceFormActionPayload(
        formId: 'f1',
        formData: {'amount': '10'},
      ),
      endpointFunc: () => '/FBLOnline/verifyForm',
    );

    test('payload carries formId and formData', () {
      expect(action.payload.toJson(), {
        'formId': 'f1',
        'formData': {'amount': '10'},
      });
    });

    test('parses the verification with preview rows', () {
      final FormVerificationResponse v = action.responseDataFunc!({
        'formId': 'f1',
        'requireSecondFactor': true,
        'previewData': [
          {'key': 'Amount', 'value': 'GHS 10.00'},
          {'key': 'Charges', 'value': 'GHS 0.50'},
        ],
      });

      expect(v.requireSecondFactor, isTrue);
      expect(v.previewData, hasLength(2));
      expect(v.previewData.first.key, 'Amount');
      expect(v.previewData.first.value, 'GHS 10.00');
    });
  });

  group('ProcessRequestAction', () {
    test('payload nests the OTP under auth', () {
      const payload = ProcessRequestActionPayload(
        activityId: 'a1',
        formId: 'f1',
        formData: {'amount': '10'},
        paymentMode: 'acc-1',
        otp: '123456',
      );

      expect(payload.toJson(), {
        'activityId': 'a1',
        'formId': 'f1',
        'formData': {'amount': '10'},
        'paymentMode': 'acc-1',
        'auth': {'otp': '123456', 'pin': null, 'secretAnswer': null},
      });
    });

    test('parses the receipt, including label/name preview rows', () {
      final action = ProcessRequestAction(
        payload: const ProcessRequestActionPayload(),
        endpointFunc: () => '/FBLOnline/processRequest',
      );

      final RequestResponse receipt = action.responseDataFunc!({
        'reference': 'TXN-123',
        'amount': 'GHS 10.00',
        'statusLabel': 'Successful',
        'previewData': [
          {'label': 'Recipient', 'name': '0244000000'},
        ],
      });

      expect(receipt.reference, 'TXN-123');
      expect(receipt.amount, 'GHS 10.00');
      expect(receipt.statusLabel, 'Successful');
      expect(receipt.previewData.single.key, 'Recipient');
      expect(receipt.previewData.single.value, '0244000000');
    });
  });
}
