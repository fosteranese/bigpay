import 'package:bigpay/data/models/general_flow/general_flow_category.dart';
import 'package:bigpay/models/actions/action.dart';

final class GetServiceCategoriesAction
    extends Action<NoPayload, GeneralFlowCategory> {
  static const path = '/{activityType}/categories/{catId}';

  const GetServiceCategoriesAction({
    super.payload = const NoPayload(),
    super.endpointFunc,
  }) : super(
         endpoint: path,
         responseDataFunc: _responseDataFunc,
       );

  static GeneralFlowCategory _responseDataFunc(dynamic data) {
    return GeneralFlowCategory.fromMap(data as Map<String, dynamic>);
  }
}
