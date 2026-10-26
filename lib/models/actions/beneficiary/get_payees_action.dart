import 'package:bigpay/data/models/payee/payee.dart';
import 'package:bigpay/models/actions/action.dart';

/// All of the user's saved beneficiaries: `Payee/getAllPayees`.
final class GetPayeesAction extends Action<NoPayload, List<Payee>> {
  static const path = '/Payee/getAllPayees';

  const GetPayeesAction({super.payload = const NoPayload()})
    : super(endpoint: path, responseDataFunc: _responseDataFunc);

  static List<Payee> _responseDataFunc(dynamic data) {
    // The backend nests the beneficiaries under `payees`/`list`; accept a bare
    // list too.
    dynamic raw = data;
    if (data is Map) {
      raw = data['payees'] ?? data['list'] ?? data['data'];
    }
    if (raw is! List) return const [];
    return raw.whereType<Map<String, dynamic>>().map(Payee.fromMap).toList();
  }
}
