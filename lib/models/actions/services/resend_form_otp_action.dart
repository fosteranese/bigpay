import 'package:bigpay/models/actions/action.dart';

/// Sends (or resends) the transaction OTP for a form via
/// `/UserAccess/resendFormOtp`. Fire-and-forget — the OTP arrives by SMS and
/// the UI just waits for the user to type it. Authenticated.
final class ResendFormOtpAction
    extends Action<ResendFormOtpActionPayload, dynamic> {
  static const path = '/UserAccess/resendFormOtp';

  ResendFormOtpAction({required String formId})
    : super(
        endpoint: path,
        payload: ResendFormOtpActionPayload(formId: formId),
        responseDataFunc: _identity,
      );

  static dynamic _identity(dynamic data) => data;
}

class ResendFormOtpActionPayload implements ActionPayloadSerializable {
  const ResendFormOtpActionPayload({required this.formId});

  final String formId;

  @override
  Map<String, dynamic> toJson() => {'formId': formId};
}
