import 'package:bigpay/data/models/general_flow/request_response.dart';
import 'package:bigpay/models/actions/action.dart';

/// Processes a verified service request: `{activityType}/processRequest`.
///
/// The endpoint varies by activity type ([endpointFunc]); the body mirrors
/// umb's shape — the activity/form ids, the form data, the payment mode, and
/// an `auth` object carrying the OTP/PIN gathered after confirmation. The
/// response is the transaction receipt.
final class ProcessRequestAction
    extends Action<ProcessRequestActionPayload, RequestResponse> {
  static const path = '/{activityType}/processRequest';

  const ProcessRequestAction({
    required super.payload,
    required super.endpointFunc,
  }) : super(
         endpoint: path,
         responseDataFunc: _responseDataFunc,
       );

  static RequestResponse _responseDataFunc(dynamic data) {
    return RequestResponse.fromMap(data as Map<String, dynamic>);
  }
}

class ProcessRequestActionPayload implements ActionPayloadSerializable {
  const ProcessRequestActionPayload({
    this.activityId,
    this.formId,
    this.formData = const {},
    this.paymentMode = '',
    this.otp,
    this.pin,
    this.secretAnswer,
    this.payeeId,
  });

  final String? activityId;
  final String? formId;
  final Map<String, dynamic> formData;
  final String paymentMode;
  final String? otp;
  final String? pin;
  final String? secretAnswer;

  /// The saved beneficiary to update instead of create — "edit and send"
  /// reuses `Payee/addPayee` as an upsert keyed on this. Only set for that
  /// flow, so a normal transaction's body stays identical.
  final String? payeeId;

  @override
  Map<String, dynamic> toJson() => {
    'activityId': activityId,
    'formId': formId,
    'formData': formData,
    'paymentMode': paymentMode,
    if (payeeId != null) 'payeeId': payeeId,
    'auth': {
      'otp': otp,
      'pin': pin,
      'secretAnswer': secretAnswer,
    },
  };

  /// Copy with a [payeeId] attached — the "edit and send" flow reuses
  /// `Payee/addPayee` as an upsert keyed on the saved payee.
  ProcessRequestActionPayload withPayeeId(String? payeeId) =>
      ProcessRequestActionPayload(
        activityId: activityId,
        formId: formId,
        formData: formData,
        paymentMode: paymentMode,
        otp: otp,
        pin: pin,
        secretAnswer: secretAnswer,
        payeeId: payeeId,
      );
}
