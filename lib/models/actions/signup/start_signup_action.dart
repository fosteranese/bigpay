import 'package:bigpay/data/models/start_sign_up_data/start_sign_up_data.dart';
import 'package:bigpay/models/actions/action.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'start_signup_action.freezed.dart';
part 'start_signup_action.g.dart';

final class StartSignUpAction
    extends Action<StartSignUpActionPayload, StartSignUpData> {
  /// The endpoint, reachable without an instance (see [StartupAction.path]).
  static const path = '/UserAccess/signUpCustomer';

  const StartSignUpAction({
    required super.payload,
  }) : super(
         endpoint: path,
         responseDataFunc: _responseDataFunc,
       );

  static StartSignUpData _responseDataFunc(dynamic response) {
    return StartSignUpData.fromMap(response as Map<String, dynamic>);
  }
}

@freezed
abstract class StartSignUpActionPayload
    with _$StartSignUpActionPayload
    implements ActionPayloadSerializable {
  const factory StartSignUpActionPayload({
    required String phoneNumber,
  }) = _StartSignUpActionPayload;

  factory StartSignUpActionPayload.fromJson(Map<String, dynamic> json) =>
      _$StartSignUpActionPayloadFromJson(json);
}
