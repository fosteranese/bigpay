import 'package:bigpay/data/models/payee/payee.dart';
import 'package:bigpay/models/actions/action.dart';

/// Fetches the saved payees for a form: `Payee/getPayeesByFormId`.
final class GetFormPayeesAction extends Action<GetFormPayeesActionPayload, List<Payee>> {
  static const path = '/Payee/getPayeesByFormId';

  const GetFormPayeesAction({
    required super.payload,
  }) : super(
         endpoint: path,
         responseDataFunc: _responseDataFunc,
       );

  static List<Payee> _responseDataFunc(dynamic data) {
    // The backend returns the payees under `list` (and the decoder wraps a
    // bare top-level list the same way), so accept either shape.
    final raw = data is Map ? data['list'] : data;
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(Payee.fromMap)
        .toList();
  }
}

class GetFormPayeesActionPayload implements ActionPayloadSerializable {
  const GetFormPayeesActionPayload({this.formId});

  final String? formId;

  @override
  Map<String, dynamic> toJson() => {'formId': formId};
}
