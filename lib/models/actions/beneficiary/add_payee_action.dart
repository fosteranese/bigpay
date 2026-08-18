import 'package:bigpay/models/actions/action.dart';
import 'package:bigpay/models/actions/services/process_request_action.dart';

/// Saves a filled service form as a beneficiary: `Payee/addPayee`.
///
/// The body mirrors `processRequest` — activity/form ids, the form data, the
/// payment mode and the auth block — so it reuses [ProcessRequestActionPayload].
/// Success is the whole signal.
final class AddPayeeAction extends Action<ProcessRequestActionPayload, bool> {
  static const path = '/Payee/addPayee';

  const AddPayeeAction({required super.payload})
    : super(endpoint: path, responseDataFunc: _responseDataFunc);

  static bool _responseDataFunc(dynamic data) => true;
}
