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
  });

  final String? activityId;
  final String? formId;
  final Map<String, dynamic> formData;
  final String paymentMode;
  final String? otp;
  final String? pin;
  final String? secretAnswer;

  @override
  Map<String, dynamic> toJson() => {
    'activityId': activityId,
    'formId': formId,
    'formData': formData,
    'paymentMode': paymentMode,
    'auth': {
      'otp': otp,
      'pin': pin,
      'secretAnswer': secretAnswer,
    },
  };
}
