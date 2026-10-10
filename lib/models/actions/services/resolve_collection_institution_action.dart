import 'package:bigpay/models/actions/action.dart';

/// Resolves the institution behind an FBLCollect activity/form pair —
/// `FBLCollect/formDataByFormId`. Used only to recover the `insId` a
/// dashboard "most used service" shortcut doesn't carry (it only has
/// `activityId`/`formId`), so [GetServiceFormDataAction]'s
/// `FBLCollect/formsDataByInsId` call can be made with a real institution id
/// instead of the form id standing in for one.
final class ResolveCollectionInstitutionAction
    extends Action<ResolveCollectionInstitutionActionPayload, String> {
  static const path = '/FBLCollect/formDataByFormId';

  const ResolveCollectionInstitutionAction({required super.payload})
    : super(endpoint: path);

  /// [RemoteUtil.makeCall] (this action is dispatched directly, not through
  /// [ProcessBloc]) returns the raw envelope rather than running
  /// [Action.responseDataFunc], so callers parse the response themselves —
  /// this just documents its shape: `data.form.institution.insId`.
  static String? insIdFrom(dynamic data) {
    final form = (data as Map<String, dynamic>?)?['form'];
    final institution = (form as Map<String, dynamic>?)?['institution'];
    return (institution as Map<String, dynamic>?)?['insId'] as String?;
  }
}

final class ResolveCollectionInstitutionActionPayload
    implements ActionPayloadSerializable {
  const ResolveCollectionInstitutionActionPayload({
    required this.activityId,
    required this.formId,
  });

  final String? activityId;
  final String? formId;

  @override
  Map<String, dynamic> toJson() => {
    'activityId': activityId,
    'formId': formId,
  };
}
