import 'package:bigpay/data/models/verify_user_data/verify_user_data.dart';
import 'package:bigpay/models/actions/action.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'verify_secure_phrase_login_action.freezed.dart';
part 'verify_secure_phrase_login_action.g.dart';

final class VerifySecurePhraseLoginAction
    extends Action<VerifySecurePhraseLoginActionPayload, VerifyUserData> {
  /// The endpoint, reachable without an instance (see [StartupAction.path]).
  static const path = '/SignIn/verifySecurityAnswer';

  const VerifySecurePhraseLoginAction({
    required super.payload,
  }) : super(
         endpoint: path,
         responseDataFunc: _responseDataFunc,
         isAuthenticated: false,
       );

  static VerifyUserData _responseDataFunc(dynamic response) {
    return VerifyUserData.fromMap(response as Map<String, dynamic>);
  }
}

@freezed
abstract class VerifySecurePhraseLoginActionPayload
    with _$VerifySecurePhraseLoginActionPayload
    implements ActionPayloadSerializable {
  const factory VerifySecurePhraseLoginActionPayload({
    required String requestId,
    required String securityAnswer,
  }) = _VerifySecurePhraseLoginActionPayload;

  factory VerifySecurePhraseLoginActionPayload.fromJson(
    Map<String, dynamic> json,
  ) => _$VerifySecurePhraseLoginActionPayloadFromJson(json);
}
