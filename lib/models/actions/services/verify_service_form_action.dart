import 'package:bigpay/data/models/general_flow/form_verification_response.dart';
import 'package:bigpay/models/actions/action.dart';

/// Verifies a filled service form before it is processed:
/// `{activityType}/verifyForm` with `{formId, formData}`.
///
/// The endpoint varies by activity type, so it is supplied via [endpointFunc]
/// (see how `service.pg.dart` builds the form-data endpoint the same way). The
/// response is the confirmation the summary screen renders.
final class VerifyServiceFormAction
    extends Action<VerifyServiceFormActionPayload, FormVerificationResponse> {
  static const path = '/{activityType}/verifyForm';

  const VerifyServiceFormAction({
    required super.payload,
    required super.endpointFunc,
  }) : super(
         endpoint: path,
         responseDataFunc: _responseDataFunc,
       );

  static FormVerificationResponse _responseDataFunc(dynamic data) {
    return FormVerificationResponse.fromMap(data as Map<String, dynamic>);
  }
}

class VerifyServiceFormActionPayload implements ActionPayloadSerializable {
  const VerifyServiceFormActionPayload({
    this.insId,
    this.formId,
    this.formData = const {},
  });

  final String? insId;
  final String? formId;
  final Map<String, dynamic> formData;

  @override
  Map<String, dynamic> toJson() => {
    'insId': insId,
    'formId': formId,
    'formData': formData,
  };
}
