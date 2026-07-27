import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:bigpay/data/models/general_flow/general_flow_form_data.dart';
import 'package:bigpay/models/actions/action.dart';

part 'get_service_form_data_action.freezed.dart';
part 'get_service_form_data_action.g.dart';

final class GetServiceFormDataAction
    extends Action<GetServiceFormDataActionPayload, GeneralFlowFormData> {
  static const path = '/{activityType}/formDataByFormId';

  const GetServiceFormDataAction({
    required super.payload,
    required super.endpointFunc,
  }) : super(
         endpoint: path,
         responseDataFunc: _responseDataFunc,
       );

  static GeneralFlowFormData _responseDataFunc(dynamic data) {
    final result = GeneralFlowFormData.fromMap(
      data as Map<String, dynamic>,
    );
    return result;
  }
}

@freezed
abstract class GetServiceFormDataActionPayload
    with _$GetServiceFormDataActionPayload
    implements ActionPayloadSerializable {
  const factory GetServiceFormDataActionPayload({
    String? formId,
    String? qrCode,
    String? payeeId,
  }) = _GetServiceFormDataActionPayload;

  factory GetServiceFormDataActionPayload.fromJson(Map<String, dynamic> json) =>
      _$GetServiceFormDataActionPayloadFromJson(json);
}
