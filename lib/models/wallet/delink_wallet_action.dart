import 'package:bigpay/models/actions/action.dart';

/// Removes a linked wallet: `MyAccount/delinkWallet`.
final class DelinkWalletAction extends Action<DelinkWalletPayload, bool> {
  static const path = '/MyAccount/delinkWallet';

  const DelinkWalletAction({required super.payload})
    : super(endpoint: path, responseDataFunc: _responseDataFunc);

  static bool _responseDataFunc(dynamic data) => true;
}

class DelinkWalletPayload implements ActionPayloadSerializable {
  const DelinkWalletPayload({this.sourceValue});

  /// The wallet's `sources[0].value`.
  final String? sourceValue;

  @override
  Map<String, dynamic> toJson() => {'sourceValue': sourceValue};
}
