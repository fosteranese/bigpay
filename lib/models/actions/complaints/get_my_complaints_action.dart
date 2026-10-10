import 'package:bigpay/data/models/complaint/complaint.dart';
import 'package:bigpay/data/models/complaint/complaint_parsing.dart';
import 'package:bigpay/models/actions/action.dart';

/// The user's complaints list: `MyAccount/myComplaints`.
final class GetMyComplaintsAction extends Action<NoPayload, List<Complaint>> {
  static const path = '/MyAccount/myComplaints';

  const GetMyComplaintsAction({super.payload = const NoPayload()})
    : super(endpoint: path, responseDataFunc: _responseDataFunc);

  static List<Complaint> _responseDataFunc(dynamic data) =>
      complaintMapList(data, [
        'complaints',
        'myComplaints',
        'result',
        'items',
        'list',
        'data',
      ]).map(Complaint.fromMap).toList();
}
