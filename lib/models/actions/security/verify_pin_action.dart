import 'package:bigpay/models/actions/action.dart';

/// Verifies the user's security PIN with the backend: `MyAccount/verifyPin`.
///
/// Used to confirm the PIN before enabling a biometric setting. The response
/// carries no payload — success is the whole signal, so read
/// `snapshot.isSuccessful`.
final class VerifyPinAction extends Action<VerifyPinActionPayload, bool> {
  static const path = '/MyAccount/verifyPin';

  const VerifyPinAction({required super.payload})
    : super(
        endpoint: path,
        responseDataFunc: _responseDataFunc,
      );

  static bool _responseDataFunc(dynamic data) => true;
}

class VerifyPinActionPayload implements ActionPayloadSerializable {
  const VerifyPinActionPayload({required this.pin});

  final String pin;

  @override
  Map<String, dynamic> toJson() => {'pin': pin};
}
