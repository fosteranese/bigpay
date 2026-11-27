import 'package:bigpay/models/actions/action.dart';

/// Links a debit/credit card to the user's wallet.
///
/// NOTE: the endpoint and payload field names are **assumed** — the backend
/// contract was never finalised (there is no card endpoint in the reference
/// client). Replace [path] and [AddCardActionPayload.toJson] once the real
/// contract is known.
final class AddCardAction extends Action<AddCardActionPayload, bool> {
  static const path = '/Card/addCard';

  const AddCardAction({required super.payload})
    : super(endpoint: path, responseDataFunc: _responseDataFunc);

  /// Success is the whole signal (no card payload comes back), so the parsed
  /// result is a constant `true` — read `snapshot.isSuccessful` / `message`.
  static bool _responseDataFunc(dynamic data) => true;
}

class AddCardActionPayload implements ActionPayloadSerializable {
  const AddCardActionPayload({
    required this.cardNumber,
    required this.cardHolderName,
    required this.cvv,
    required this.expiryMonth,
    required this.expiryYear,
  });

  /// PAN, digits only (no spaces).
  final String cardNumber;
  final String cardHolderName;
  final String cvv;

  /// Two-digit month (`MM`) and year (`YY`) as typed on the `MM/YY` field.
  final String expiryMonth;
  final String expiryYear;

  @override
  Map<String, dynamic> toJson() => {
    'cardNumber': cardNumber,
    'cardHolderName': cardHolderName,
    'cvv': cvv,
    'expiryMonth': expiryMonth,
    'expiryYear': expiryYear,
  };
}
