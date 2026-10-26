import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:bigpay/models/actions/action.dart';

part 'complete_forgot_pwd_action.freezed.dart';
part 'complete_forgot_pwd_action.g.dart';

final class CompleteForgotPwdAction
    extends Action<CompleteForgotPwdActionPayload, Null> {
  static const path = '/Forgot/setNewPassword';

  const CompleteForgotPwdAction({
    required super.payload,
  }) : super(
         endpoint: path,
         responseDataFunc: _responseDataFunc,
         isAuthenticated: false,
       );

  static Null _responseDataFunc(_) {
    return null;
  }
}

@freezed
abstract class CompleteForgotPwdActionPayload
    with _$CompleteForgotPwdActionPayload
    implements ActionPayloadSerializable {
  const factory CompleteForgotPwdActionPayload({
    required String requestId,
    required String password,
  }) = _CompleteForgotPwdActionPayload;

  factory CompleteForgotPwdActionPayload.fromJson(Map<String, dynamic> json) =>
      _$CompleteForgotPwdActionPayloadFromJson(json);
}
