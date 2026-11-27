import 'package:bigpay/data/models/complaint/complaint_category.dart';
import 'package:bigpay/data/models/complaint/complaint_parsing.dart';
import 'package:bigpay/models/actions/action.dart';

/// Categories for the new-complaint form: `MyAccount/complaintCategories`.
final class GetComplaintCategoriesAction
    extends Action<NoPayload, List<ComplaintCategory>> {
  static const path = '/MyAccount/complaintCategories';

  const GetComplaintCategoriesAction({super.payload = const NoPayload()})
    : super(endpoint: path, responseDataFunc: _responseDataFunc);

  static List<ComplaintCategory> _responseDataFunc(dynamic data) =>
      complaintMapList(data, [
        'categories',
        'complaintCategories',
        'categoryList',
        'result',
        'items',
        'list',
        'data',
      ]).map(ComplaintCategory.fromMap).toList();
}
