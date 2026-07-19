import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:bigpay/data/models/verify_user_data/verify_user_data.dart';
import 'package:bigpay/models/actions/action.dart';

part 'start_forgot_pwd_action.freezed.dart';
part 'start_forgot_pwd_action.g.dart';

final class StartForgotPwdAction
    extends Action<StartForgotPwdActionPayload, VerifyUserData> {
  /// The endpoint, reachable without an instance (see [StartupAction.path]).
  static const path = '/Forgot/initiateForgotPassword';

  const StartForgotPwdAction({
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
abstract class StartForgotPwdActionPayload
    with _$StartForgotPwdActionPayload
    implements ActionPayloadSerializable {
  const factory StartForgotPwdActionPayload({
    required String phoneNumber,
    required String securityAnswer,
  }) = _StartForgotPwdActionPayload;

  factory StartForgotPwdActionPayload.fromJson(Map<String, dynamic> json) =>
      _$StartForgotPwdActionPayloadFromJson(json);
}
