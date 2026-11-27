import 'package:bigpay/data/models/account/account.dart';
import 'package:bigpay/models/actions/action.dart';

final class GetWalletsAction extends Action<NoPayload, List<Account>> {
  static const path = '/MyAccount/sourceOfPayments';

  const GetWalletsAction({
    super.payload = const NoPayload(),
  }) : super(
         endpoint: path,
         responseDataFunc: _responseDataFunc,
       );

  static List<Account> _responseDataFunc(dynamic data) {
    final rawData = data as Map<String, dynamic>;
    var list = rawData['list'] as List<dynamic>;
    final result = list.map((item) {
      return Account.fromMap(item as Map<String, dynamic>);
    }).toList();
    return result;
  }
}
