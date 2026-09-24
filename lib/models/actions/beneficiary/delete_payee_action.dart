import 'package:bigpay/models/actions/action.dart';

/// Removes a saved beneficiary: `Payee/deletePayee`.
final class DeletePayeeAction extends Action<DeletePayeePayload, bool> {
  static const path = '/Payee/deletePayee';

  const DeletePayeeAction({required super.payload})
    : super(endpoint: path, responseDataFunc: _responseDataFunc);

  static bool _responseDataFunc(dynamic data) => true;
}

class DeletePayeePayload implements ActionPayloadSerializable {
  const DeletePayeePayload({this.payeeId});

  final String? payeeId;

  @override
  Map<String, dynamic> toJson() => {'payeeId': payeeId};
}
