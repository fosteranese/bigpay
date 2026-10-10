import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:bigpay/models/actions/action.dart';

part 'forgot_secure_phrase_action.freezed.dart';
part 'forgot_secure_phrase_action.g.dart';

final class ForgotSecurePhraseAction
    extends Action<ForgotSecurePhraseActionPayload, Null> {
  static const path = '/Forgot/initiateForgotSecurityAnswer';

  const ForgotSecurePhraseAction({
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
abstract class ForgotSecurePhraseActionPayload
    with _$ForgotSecurePhraseActionPayload
    implements ActionPayloadSerializable {
  const factory ForgotSecurePhraseActionPayload({
    required String phoneNumber,
    required String email,
  }) = _ForgotSecurePhraseActionPayload;

  factory ForgotSecurePhraseActionPayload.fromJson(Map<String, dynamic> json) =>
      _$ForgotSecurePhraseActionPayloadFromJson(json);
}
