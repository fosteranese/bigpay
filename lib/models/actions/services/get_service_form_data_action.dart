import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/constants/activity_type.const.dart';
import 'package:bigpay/constants/field.const.dart';
import 'package:bigpay/data/models/auth_data/activity_datum.dart';
import 'package:bigpay/data/models/collection/institution.dart';
import 'package:bigpay/data/models/collection/lov.dart';
import 'package:bigpay/data/models/general_flow/general_flow_field.dart';
import 'package:bigpay/data/models/general_flow/general_flow_fields_datum.dart';
import 'package:bigpay/data/models/general_flow/general_flow_form.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:bigpay/data/models/general_flow/general_flow_form_data.dart';
import 'package:bigpay/models/actions/action.dart';

part 'get_service_form_data_action.freezed.dart';
part 'get_service_form_data_action.g.dart';

final class GetServiceFormDataAction
    extends Action<GetServiceFormDataActionPayload, GeneralFlowFormData> {
  static const path = '/{activityType}/formDataByFormId';

  /// Set when a most-used/favourite service is tapped so a central listener can
  /// correlate the result and carry the synthesized activity forward to the
  /// form. Mirrors [GetServiceCategoriesAction.event]/`activityDatum`.
  static ExecuteProcessEvent? event;
  static ActivityDatum? activityDatum;

  const GetServiceFormDataAction({
    required super.payload,
    required super.endpointFunc,
  }) : super(
         endpoint: path,
         responseDataFunc: _responseDataFunc,
       );

  static GeneralFlowFormData _responseDataFunc(dynamic data) {
    final responseData = data as Map<String, dynamic>;
    if (responseData['institutionData'] != null &&
        responseData['sourceOfPayment'] != null) {
      final institutionData =
          responseData['institutionData'] as Map<String, dynamic>;
      final institution =
          institutionData['institution'] as Map<String, dynamic>;
      final sourceOfPayment =
          (responseData['sourceOfPayment'] as List<dynamic>?)
              ?.map((item) {
                return (item['sources'] as List<dynamic>?)?.map((sub) {
                      final el = sub as Map<String, dynamic>;
                      return Lov(
                        lovTitle: el['tile'],
                        lovValue: el['value'],
                      );
                    }).toList() ??
                    [];
              })
              .expand((item) => item)
              .toList() ??
          [];

      final forms = institutionData['forms'] as List<dynamic>?;
      if (forms == null || forms.isEmpty) {
        // No form to build — let the UI surface its "unavailable" state
        // instead of throwing StateError out of the parser.
        return const GeneralFlowFormData();
      }
      final formData = forms.first as Map<String, dynamic>;
      final form = formData['form'] as Map<String, dynamic>;

      final fieldData = (formData['fields'] as List<dynamic>).map((
        item,
      ) {
        final field = item['field'] as Map<String, dynamic>;
        final lov = item['lov'] as List<dynamic>;
        return GeneralFlowFieldsDatum(
          field: GeneralFlowField(
            fieldId: field['fieldId'],
            formId: field['formId'],
            fieldName: field['fieldName'],
            fieldCaption: field['caption'],
            fieldType: field['fieldType'],
            fieldDataType: field['fieldDataType'],
            fieldLength: field['fieldLength'],
            fieldDateFormat: field['fieldDateFormat'],
            fieldMandatory: field['fieldMandatory'],
            fieldInRemarks: field['fieldInRemarks'],
            rank: field['rank'],
            fieldVisible: field['fieldVisible'],
            defaultValue: field['defaultValue'],
            readOnly: field['readOnly'],
            showOnReceipt: field['showOnReceipt'],
            isAmount: field['isAmount'],
            toolTip: field['tooltip'],
            requiredForVerification: field['requireVerification'],
            lovEndpoint: field['lovEndpoint'],
          ),
          lov: lov.map((el) {
            return Lov(
              lovTitle: el['lovTitle'],
              lovValue: el['lovValue'],
            );
          }).toList(),
        );
      }).toList();
      if (fieldData.isNotEmpty) {
        fieldData.add(
          GeneralFlowFieldsDatum(
            lov: sourceOfPayment,
            field: GeneralFlowField(
              formId: fieldData.first.field!.formId,

              fieldId: 'SourceAccount',
              fieldName: 'SourceAccount',
              fieldCaption: 'Payment Source',
              defaultValue: '',
              fieldDataType: FieldDataTypesConst.sourceAccount,
              fieldMandatory: 1,
              fieldType: FieldTypesConst.listOfValues,
              fieldVisible: 1,
              readOnly: 0,
              requiredForVerification: 1,
              isAmount: 0,
              showOnReceipt: 1,
              rank: fieldData.first.field!.fieldLength,
              toolTip: 'Select your preferred payment option',
            ),
          ),
        );
      }
      final authMode = (formData['authMode'] as List<dynamic>).map((item) {
        return item as Map<String, dynamic>;
      }).toList();

      return GeneralFlowFormData(
        institution: Institution(
          insId: institution['insId'],
          insName: institution['insName'],
          catId: institution['catId'],
          description: institution['description'],
          tooltip: institution['tooltip'],
          icon: institution['icon'],
          customCss: institution['customCss'],
          insCode: institution['insCode'],
        ),
        form: GeneralFlowForm(
          formId: form['formId'],
          formName: form['formName'],
          activityType: ActivityTypesConst.fblCollect,
          caption: form['caption'],
          tooltip: form['tooltip'],
          requireVerification: form['requireVerification'],
          verifyEndpoint: form['verifyEndpoint'],
          processEndpoint: form['processEndpoint'],
          // categoryId: formData['insId'],
          // description: formData['description'],
          // icon: formData['icon'],
          // status: formData['status'],
          rank: form['rank'],
        ),
        fieldsDatum: fieldData,
        authMode: authMode,
      );
    }

    final result = GeneralFlowFormData.fromMap(
      responseData,
    );
    return result;
  }
}

@freezed
abstract class GetServiceFormDataActionPayload
    with _$GetServiceFormDataActionPayload
    implements ActionPayloadSerializable {
  const factory GetServiceFormDataActionPayload({
    String? insId,
    String? formId,
    String? qrCode,
    String? payeeId,
  }) = _GetServiceFormDataActionPayload;

  factory GetServiceFormDataActionPayload.fromJson(Map<String, dynamic> json) =>
      _$GetServiceFormDataActionPayloadFromJson(json);
}
