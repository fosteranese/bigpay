import 'package:bigpay/data/models/new_device_login_data.dart';
import 'package:bigpay/models/actions/action.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_action.freezed.dart';
part 'login_action.g.dart';

final class NewLoginAction
    extends Action<NewLoginActionPayload, NewDeviceLoginData> {
  /// The endpoint, reachable without an instance (see [StartupAction.path]).
  static const path = '/SignIn/newDevice';

  const NewLoginAction({
    required super.payload,
  }) : super(
         endpoint: path,
         responseDataFunc: _responseDataFunc,
         isAuthenticated: false,
       );

  static NewDeviceLoginData _responseDataFunc(dynamic response) {
    return NewDeviceLoginData.fromMap(response.data as Map<String, dynamic>);
  }
}

@freezed
abstract class NewLoginActionPayload
    with _$NewLoginActionPayload
    implements ActionPayloadSerializable {
  const factory NewLoginActionPayload({
    required String phoneNumber,
    required String password,
  }) = _NewLoginActionPayload;

  factory NewLoginActionPayload.fromJson(Map<String, dynamic> json) =>
      _$NewLoginActionPayloadFromJson(json);
}
