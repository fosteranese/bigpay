import 'package:bigpay/models/actions/action.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_action.freezed.dart';
part 'login_action.g.dart';

final class LoginAction extends Action<LoginActionPayload, String> {
  const LoginAction({
    required super.payload,
  }) : super(
         endpoint: '/auth/login',
         responseDataFunc: _responseDataFunc,
       );

  static String _responseDataFunc(dynamic response) {
    return 'Login successful';
  }
}

@freezed
abstract class LoginActionPayload
    with _$LoginActionPayload
    implements ActionPayloadSerializable {
  const factory LoginActionPayload({
    required String username,
    required String password,
  }) = _LoginActionPayload;

  factory LoginActionPayload.fromJson(Map<String, dynamic> json) =>
      _$LoginActionPayloadFromJson(json);
}
