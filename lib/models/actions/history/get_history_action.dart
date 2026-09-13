import 'package:bigpay/data/models/general_flow/history_response.dart';
import 'package:bigpay/models/actions/action.dart';

/// Loads the user's transaction history: `MyAccount/history`.
///
/// With no [GetHistoryActionPayload.activityId] the body is empty and the
/// server returns everything; passing an activity id filters to that activity.
/// Authenticated. Pair with `returnSavedResponse`/`saveActionResponse` on
/// dispatch for cache-then-refresh.
final class GetHistoryAction
    extends Action<GetHistoryActionPayload, HistoryResponse> {
  static const path = '/MyAccount/history';

  const GetHistoryAction({
    super.payload = const GetHistoryActionPayload(),
  }) : super(
         endpoint: path,
         responseDataFunc: _responseDataFunc,
       );

  static HistoryResponse _responseDataFunc(dynamic data) {
    return HistoryResponse.fromMap(data as Map<String, dynamic>);
  }
}

class GetHistoryActionPayload implements ActionPayloadSerializable {
  const GetHistoryActionPayload({this.activityId});

  /// When set, the history is filtered to this activity.
  final String? activityId;

  @override
  Map<String, dynamic> toJson() => {
    if (activityId != null) 'activityId': activityId,
  };
}
