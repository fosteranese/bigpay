import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/constants/activity_type.const.dart';
import 'package:bigpay/data/models/auth_data/activity_datum.dart';
import 'package:bigpay/data/models/general_flow/category.dart';
import 'package:bigpay/data/models/general_flow/general_flow_category.dart';
import 'package:bigpay/data/models/general_flow/general_flow_form.dart';
import 'package:bigpay/models/actions/action.dart';

final class GetServiceCategoriesAction
    extends Action<NoPayload, GeneralFlowCategory> {
  static const path = '/{activityType}/categories/{catId}';
  static ExecuteProcessEvent? event;
  static ActivityDatum? activityDatum;

  const GetServiceCategoriesAction({
    super.payload = const NoPayload(),
    super.endpointFunc,
  }) : super(
         endpoint: path,
         responseDataFunc: _responseDataFunc,
       );

  static GeneralFlowCategory _responseDataFunc(dynamic data) {
    final result = data as Map<String, dynamic>;
    if (result['category'] != null && result['institution'] != null) {
      final category = result['category'] as Map<String, dynamic>? ?? {};
      final institutions = result['institution'] as List<dynamic>? ?? [];
      return GeneralFlowCategory(
        category: Category(
          catId: category['catId'],
          catName: category['catName'],
          description: category['description'],
          tooltip: category['tooltip'],
          icon: category['icon'],
          customCss: category['customCss'],
          status: category['status'],
          statusLabel: category['statusLabel'],
          rank: category['rank'],
        ),
        forms: institutions.map((element) {
          final item = element as Map<String, dynamic>;
          return GeneralFlowForm(
            activityType: ActivityTypesConst.fblCollect,
            formId: item['insId'],
            categoryId: item['catId'],
            formName: item['insName'],
            description: item['description'],
            tooltip: item['tooltip'],
            icon: item['icon'],
            status: item['status'],
            statusLabel: item['statusLabel'],
            rank: item['rank'],
          );
        }).toList(),
      );
    }

    return GeneralFlowCategory.fromMap(result);
  }
}
