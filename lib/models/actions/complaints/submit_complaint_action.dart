import 'package:bigpay/data/models/complaint/complaint.dart';
import 'package:bigpay/models/actions/action.dart';

/// Opens a new complaint: `MyAccount/submitComplaint`. The response is parsed
/// as the created [Complaint] (for its id/reference) when the backend returns
/// one.
final class SubmitComplaintAction
    extends Action<SubmitComplaintPayload, Complaint> {
  static const path = '/MyAccount/submitComplaint';

  const SubmitComplaintAction({required super.payload})
    : super(endpoint: path, responseDataFunc: _responseDataFunc);

  static Complaint _responseDataFunc(dynamic data) =>
      data is Map<String, dynamic>
      ? Complaint.fromMap(data)
      : const Complaint();
}

class SubmitComplaintPayload implements ActionPayloadSerializable {
  const SubmitComplaintPayload({this.categoryId, this.subject, this.message});

  final String? categoryId;
  final String? subject;
  final String? message;

  @override
  Map<String, dynamic> toJson() => {
    'categoryId': categoryId,
    'subject': subject,
    'message': message,
  };
}
