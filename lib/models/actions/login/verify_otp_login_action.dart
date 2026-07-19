import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:bigpay/data/models/auth_data/auth_data.dart';
import 'package:bigpay/models/actions/action.dart';

part 'verify_otp_login_action.freezed.dart';
part 'verify_otp_login_action.g.dart';

final class VerifyOtpLoginAction
    extends Action<VerifyOtpLoginActionPayload, AuthData> {
  static const path = '/SignIn/verifyOtp';

  const VerifyOtpLoginAction({
    required super.payload,
  }) : super(
         endpoint: path,
         responseDataFunc: _responseDataFunc,
       );

  static AuthData _responseDataFunc(dynamic data) {
    return AuthData.fromMap(data as Map<String, dynamic>);
  }
}

@freezed
abstract class VerifyOtpLoginActionPayload
    with _$VerifyOtpLoginActionPayload
    implements ActionPayloadSerializable {
  const factory VerifyOtpLoginActionPayload({
    required String otpId,
    required String otpValue,
  }) = _VerifyOtpLoginActionPayload;

  factory VerifyOtpLoginActionPayload.fromJson(Map<String, dynamic> json) =>
      _$VerifyOtpLoginActionPayloadFromJson(json);
}
