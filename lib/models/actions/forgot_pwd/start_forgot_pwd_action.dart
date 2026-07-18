import 'package:bigpay/data/models/new_device_login_data.dart';
import 'package:bigpay/models/actions/action.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'start_forgot_pwd_action.freezed.dart';
part 'start_forgot_pwd_action.g.dart';

final class StartForgotPwdAction
    extends Action<StartForgotPwdActionPayload, NewDeviceLoginData> {
  /// The endpoint, reachable without an instance (see [StartupAction.path]).
  static const path = '/SignIn/newDevice';

  const StartForgotPwdAction({
    required super.payload,
  }) : super(
         endpoint: path,
         responseDataFunc: _responseDataFunc,
       );

  static NewDeviceLoginData _responseDataFunc(dynamic response) {
    return NewDeviceLoginData.fromMap(response as Map<String, dynamic>);
  }
}

@freezed
abstract class StartForgotPwdActionPayload
    with _$StartForgotPwdActionPayload
    implements ActionPayloadSerializable {
  const factory StartForgotPwdActionPayload({
    required String phoneNumber,
    required String password,
  }) = _StartForgotPwdActionPayload;

  factory StartForgotPwdActionPayload.fromJson(Map<String, dynamic> json) =>
      _$StartForgotPwdActionPayloadFromJson(json);
}
