import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:bigpay/models/actions/action.dart';

part 'auto_ghana_card_verification_action.freezed.dart';
part 'auto_ghana_card_verification_action.g.dart';

final class AutoGhanaCardVerificationAction
    extends Action<AutoGhanaCardVerificationActionPayload, Null> {
  static const path = '/MyAccount/enhanceValidation';

  const AutoGhanaCardVerificationAction({
    required super.payload,
  }) : super(
         endpoint: path,
         responseDataFunc: _responseDataFunc,
       );

  static Null _responseDataFunc(_) {
    return null;
  }
}

@freezed
abstract class AutoGhanaCardVerificationActionPayload
    with _$AutoGhanaCardVerificationActionPayload
    implements ActionPayloadSerializable {
  const factory AutoGhanaCardVerificationActionPayload({
    required String cardNumber,
    required String picture,
    required String email,
    required String streetAddress,
    required String digitalAddress,
  }) = _AutoGhanaCardVerificationActionPayload;

  factory AutoGhanaCardVerificationActionPayload.fromJson(
    Map<String, dynamic> json,
  ) => _$AutoGhanaCardVerificationActionPayloadFromJson(json);
}
