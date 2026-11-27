import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:bigpay/models/actions/action.dart';

part 'verify_otp_signup_action.freezed.dart';
part 'verify_otp_signup_action.g.dart';

final class VerifyOtpSignUpAction
    extends Action<VerifyOtpSignUpActionPayload, String> {
  static const path = '/UserAccess/validateSignUpOtp';

  const VerifyOtpSignUpAction({
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
abstract class VerifyOtpSignUpActionPayload
    with _$VerifyOtpSignUpActionPayload
    implements ActionPayloadSerializable {
  const factory VerifyOtpSignUpActionPayload({
    required String otpId,
    required String otpValue,
  }) = _VerifyOtpSignUpActionPayload;

  factory VerifyOtpSignUpActionPayload.fromJson(Map<String, dynamic> json) =>
      _$VerifyOtpSignUpActionPayloadFromJson(json);
}
