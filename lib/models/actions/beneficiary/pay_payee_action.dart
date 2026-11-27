import 'package:bigpay/models/actions/action.dart';

/// Pays a saved beneficiary directly: `Payee/payPayee`.
///
/// "Send now" is the final submission — no form is opened; the backend pays
/// using the saved beneficiary and the authorizing PIN. Success is the whole
/// signal, so read `snapshot.isSuccessful` / `snapshot.message`.
final class PayPayeeAction extends Action<PayPayeeActionPayload, bool> {
  static const path = '/Payee/payPayee';

  const PayPayeeAction({required super.payload})
    : super(endpoint: path, responseDataFunc: _responseDataFunc);

  static bool _responseDataFunc(dynamic data) => true;
}

class PayPayeeActionPayload implements ActionPayloadSerializable {
  const PayPayeeActionPayload({this.payeeId, this.pin});

  final String? payeeId;
  final String? pin;

  @override
  Map<String, dynamic> toJson() => {
    'payeeId': payeeId,
    'auth': {'pin': pin},
  };
}
