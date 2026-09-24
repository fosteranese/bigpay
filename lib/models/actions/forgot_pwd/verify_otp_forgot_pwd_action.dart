import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:bigpay/models/actions/action.dart';

part 'verify_otp_forgot_pwd_action.freezed.dart';
part 'verify_otp_forgot_pwd_action.g.dart';

final class VerifyOtpForgotPwdAction
    extends Action<VerifyOtpForgotPwdActionPayload, String> {
  static const path = '/Forgot/validateOtp';

  const VerifyOtpForgotPwdAction({
    required super.payload,
  }) : super(
         endpoint: path,
         responseDataFunc: _responseDataFunc,
         isAuthenticated: false,
       );

  static String _responseDataFunc(dynamic data) {
    final result = data as Map<String, dynamic>;
    return result['requestId'] as String;
  }
}

@freezed
abstract class VerifyOtpForgotPwdActionPayload
    with _$VerifyOtpForgotPwdActionPayload
    implements ActionPayloadSerializable {
  const factory VerifyOtpForgotPwdActionPayload({
    required String otpId,
    required String otpValue,
  }) = _VerifyOtpForgotPwdActionPayload;

  factory VerifyOtpForgotPwdActionPayload.fromJson(Map<String, dynamic> json) =>
      _$VerifyOtpForgotPwdActionPayloadFromJson(json);
}
