import 'package:bigpay/models/auth_data.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:bigpay/models/actions/action.dart';

part 'complete_signup_action.freezed.dart';
part 'complete_signup_action.g.dart';

final class CompleteSignUpAction
    extends Action<CompleteSignUpActionPayload, AuthData> {
  static const path = '/UserAccess/CompleteCustomerSignUp';

  const CompleteSignUpAction({
    required super.payload,
  }) : super(
         endpoint: path,
         responseDataFunc: _responseDataFunc,
       );

  static AuthData _responseDataFunc(dynamic response) {
    return AuthData.fromMap(response as Map<String, dynamic>);
  }
}

@freezed
abstract class CompleteSignUpActionPayload
    with _$CompleteSignUpActionPayload
    implements ActionPayloadSerializable {
  const factory CompleteSignUpActionPayload({
    required String registrationId,
    required String secretQuestion,
    required String secretAnswer,
    required String pin,
    required String password,
  }) = _CompleteSignUpActionPayload;

  factory CompleteSignUpActionPayload.fromJson(
    Map<String, dynamic> json,
  ) => _$CompleteSignUpActionPayloadFromJson(json);
}
