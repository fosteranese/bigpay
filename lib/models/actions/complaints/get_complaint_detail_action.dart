import 'package:bigpay/data/models/complaint/complaint_detail.dart';
import 'package:bigpay/data/models/complaint/complaint_message.dart';
import 'package:bigpay/models/actions/action.dart';

/// A complaint's full trail: `MyAccount/complaintDetail`.
final class GetComplaintDetailAction
    extends Action<GetComplaintDetailPayload, ComplaintDetail> {
  static const path = '/MyAccount/complaintDetail';

  const GetComplaintDetailAction({required super.payload})
    : super(endpoint: path, responseDataFunc: _responseDataFunc);

  static ComplaintDetail _responseDataFunc(dynamic data) {
    if (data is Map<String, dynamic>) {
      return ComplaintDetail.fromMap(data);
    }
    if (data is List) {
      return ComplaintDetail(
        messages: data
            .whereType<Map<String, dynamic>>()
            .map(ComplaintMessage.fromMap)
            .toList(),
      );
    }
    return const ComplaintDetail();
  }
}

class GetComplaintDetailPayload implements ActionPayloadSerializable {
  const GetComplaintDetailPayload({required this.complaintId});

  final String? complaintId;

  @override
  Map<String, dynamic> toJson() => {'complaintId': complaintId};
}
