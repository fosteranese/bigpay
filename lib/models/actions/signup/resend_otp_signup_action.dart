import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:bigpay/data/models/start_sign_up_data/start_sign_up_data.dart';
import 'package:bigpay/models/actions/action.dart';

part 'resend_otp_signup_action.freezed.dart';
part 'resend_otp_signup_action.g.dart';

final class ResendOtpSignUpAction
    extends Action<ResendOtpSignUpActionPayload, StartSignUpData> {
  static const path = '/UserAccess/resendOtp';

  const ResendOtpSignUpAction({
    required super.payload,
  }) : super(
         endpoint: path,
         responseDataFunc: _responseDataFunc,
       );

  static StartSignUpData _responseDataFunc(dynamic response) {
    return StartSignUpData.fromMap(response as Map<String, dynamic>);
  }
}

@freezed
abstract class ResendOtpSignUpActionPayload
    with _$ResendOtpSignUpActionPayload
    implements ActionPayloadSerializable {
  const factory ResendOtpSignUpActionPayload({
    required String otpId,
    String? otpValue,
  }) = _ResendOtpSignUpActionPayload;

  factory ResendOtpSignUpActionPayload.fromJson(Map<String, dynamic> json) =>
      _$ResendOtpSignUpActionPayloadFromJson(json);
}
