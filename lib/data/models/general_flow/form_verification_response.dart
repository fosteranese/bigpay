import 'package:equatable/equatable.dart';

/// Result of `{activityType}/verifyForm` — what the confirmation (summary)
/// screen shows before the request is processed.
///
/// [previewData] is the ordered list of confirmation rows (amount, charges,
/// total, entered fields). [authMode] / [requireSecondFactor] describe the
/// verification step (OTP/PIN) that follows.
class FormVerificationResponse extends Equatable {
  const FormVerificationResponse({
    this.formId,
    this.formData,
    this.previewData = const [],
    this.requireSecondFactor,
    this.authMode,
    this.currency,
  });

  final String? formId;
  final Map<String, dynamic>? formData;
  final List<PreviewData> previewData;
  final bool? requireSecondFactor;
  final List<Map<String, dynamic>>? authMode;
  final dynamic currency;

  factory FormVerificationResponse.fromMap(Map<String, dynamic> data) {
    return FormVerificationResponse(
      formId: data['formId'] as String?,
      formData: data['formData'] is Map
          ? (data['formData'] as Map).cast<String, dynamic>()
          : null,
      previewData: data['previewData'] is List
          ? (data['previewData'] as List)
                .whereType<Map<String, dynamic>>()
                .map(PreviewData.fromMap)
                .toList()
          : const [],
      requireSecondFactor: data['requireSecondFactor'] as bool?,
      authMode: data['authMode'] is List
          ? (data['authMode'] as List)
                .whereType<Map>()
                .map((e) => e.cast<String, dynamic>())
                .toList()
          : null,
      currency: data['currency'],
    );
  }

  @override
  List<Object?> get props => [
    formId,
    formData,
    previewData,
    requireSecondFactor,
    authMode,
    currency,
  ];
}

/// One row on the confirmation screen.
class PreviewData extends Equatable {
  const PreviewData({
    this.key,
    this.value,
    this.dataType,
    this.payeeTitle,
    this.payeeValue,
  });

  final String? key;
  final String? value;
  final int? dataType;
  final bool? payeeTitle;
  final bool? payeeValue;

  factory PreviewData.fromMap(Map<String, dynamic> data) => PreviewData(
    // Verify rows use key/value; receipt rows use label/name — accept both.
    key: (data['key'] ?? data['label']) as String?,
    value: (data['value'] ?? data['name']) as String?,
    dataType: data['dataType'] as int?,
    payeeTitle: data['payeeTitle'] as bool?,
    payeeValue: data['payeeValue'] as bool?,
  );

  @override
  List<Object?> get props => [key, value, dataType, payeeTitle, payeeValue];
}
