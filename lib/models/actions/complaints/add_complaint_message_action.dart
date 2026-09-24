import 'package:bigpay/models/actions/action.dart';

/// Replies to an existing complaint: `MyAccount/addComplaintMessage`. Success
/// is the whole signal — the caller refetches the detail to refresh the trail.
final class AddComplaintMessageAction
    extends Action<AddComplaintMessagePayload, bool> {
  static const path = '/MyAccount/addComplaintMessage';

  const AddComplaintMessageAction({required super.payload})
    : super(endpoint: path, responseDataFunc: _responseDataFunc);

  static bool _responseDataFunc(dynamic data) => true;
}

class AddComplaintMessagePayload implements ActionPayloadSerializable {
  const AddComplaintMessagePayload({this.complaintId, this.message});

  final String? complaintId;
  final String? message;

  @override
  Map<String, dynamic> toJson() => {
    'complaintId': complaintId,
    'message': message,
  };
}
