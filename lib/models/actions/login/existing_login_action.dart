import 'package:bigpay/data/models/auth_data/auth_data.dart';
import 'package:bigpay/models/actions/action.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'existing_login_action.freezed.dart';
part 'existing_login_action.g.dart';

final class ExistingLoginAction
    extends Action<ExistingLoginActionPayload, AuthData> {
  /// The endpoint, reachable without an instance (see [StartupAction.path]).
  static const path = '/SignIn/existingDevice';

  const ExistingLoginAction({
    required super.payload,
  }) : super(
         endpoint: path,
         responseDataFunc: _responseDataFunc,
         //  isAuthenticated: false,
       );

  static AuthData _responseDataFunc(dynamic response) {
    return AuthData.fromMap(response.data as Map<String, dynamic>);
  }
}

@freezed
abstract class ExistingLoginActionPayload
    with _$ExistingLoginActionPayload
    implements ActionPayloadSerializable {
  const factory ExistingLoginActionPayload({
    required String phoneNumber,
    required String password,
  }) = _ExistingLoginActionPayload;

  factory ExistingLoginActionPayload.fromJson(Map<String, dynamic> json) =>
      _$ExistingLoginActionPayloadFromJson(json);
}
