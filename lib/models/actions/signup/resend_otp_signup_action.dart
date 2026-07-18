import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:bigpay/data/models/verify_user_data/verify_user_data.dart';
import 'package:bigpay/models/actions/action.dart';

part 'resend_otp_signup_action.freezed.dart';
part 'resend_otp_signup_action.g.dart';

final class ResendOtpSignUpAction
    extends Action<ResendOtpSignUpActionPayload, VerifyUserData> {
  static const path = '/UserAccess/resendOtp';

  const ResendOtpSignUpAction({
    required super.payload,
  }) : super(
         endpoint: path,
         responseDataFunc: _responseDataFunc,
       );

  static VerifyUserData _responseDataFunc(dynamic response) {
    return VerifyUserData.fromMap(response as Map<String, dynamic>);
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
