import 'package:bigpay/data/models/auth_data/auth_data.dart';
import 'package:bigpay/models/actions/action.dart';

/// Re-fetches the signed-in user's dashboard data — activities, most-used
/// services and wallet balances — from `MyAccount/refreshDasboard`, the same
/// endpoint umb's pull-to-refresh hits. The response is the full [AuthData], so
/// callers replace `AppState.currentUser` with it. Authenticated.
final class RefreshDashboardAction extends Action<NoPayload, AuthData> {
  static const path = '/MyAccount/refreshDasboard';

  const RefreshDashboardAction({
    super.payload = const NoPayload(),
  }) : super(
         endpoint: path,
         responseDataFunc: _responseDataFunc,
       );

  static AuthData _responseDataFunc(dynamic data) {
    return AuthData.fromMap(data as Map<String, dynamic>);
  }
}
