import 'package:equatable/equatable.dart';

import 'package:bigpay/data/models/auth_data/preview_datum.dart';

/// A saved recipient for a form, returned by `Payee/getPayeesByFormId`.
///
/// [value] is what goes into the field on selection; [formData] carries the
/// other saved field values so a form can prefill itself. [previewData] is the
/// backend's own display-ready label/value list (preferred for showing the
/// beneficiary's details).
class Payee extends Equatable {
  const Payee({
    this.payeeId,
    this.formId,
    this.title,
    this.value,
    this.shortTitle,
    this.icon,
    this.formData,
    this.previewData,
    this.formName,
    this.activityId,
    this.activityName,
    this.activityType,
  });

  final String? payeeId;
  final String? formId;
  final String? title;
  final String? value;
  final String? shortTitle;
  final String? icon;
  final Map<String, dynamic>? formData;
  final List<PreviewDatum>? previewData;

  /// Present when the payee comes from `Payee/getAllPayees` — the service it
  /// belongs to, used on the beneficiaries list and to pay it.
  final String? formName;
  final String? activityId;
  final String? activityName;
  final String? activityType;

  factory Payee.fromMap(Map<String, dynamic> data) => Payee(
    payeeId: data['payeeId'] as String?,
    formId: data['formId'] as String?,
    title: data['title'] as String?,
    value: data['value'] as String?,
    shortTitle: data['shortTitle'] as String?,
    icon: data['icon'] as String?,
    formData: data['formData'] is Map
        ? (data['formData'] as Map).cast<String, dynamic>()
        : null,
    previewData: (data['previewData'] as List<dynamic>?)
        ?.map((e) => PreviewDatum.fromMap(e as Map<String, dynamic>))
        .toList(),
    formName: data['formName'] as String?,
    activityId: data['activityId'] as String?,
    activityName: data['activityName'] as String?,
    activityType: data['activityType'] as String?,
  );

  Map<String, dynamic> toMap() => {
    'payeeId': payeeId,
    'formId': formId,
    'title': title,
    'value': value,
    'shortTitle': shortTitle,
    'icon': icon,
    'formData': formData,
    'previewData': previewData?.map((e) => e.toMap()).toList(),
    'formName': formName,
    'activityId': activityId,
    'activityName': activityName,
    'activityType': activityType,
  };

  /// Best label to show in the picker.
  String get displayName => title ?? shortTitle ?? value ?? '';

  @override
  List<Object?> get props => [
    payeeId,
    formId,
    title,
    value,
    shortTitle,
    icon,
    formData,
    previewData,
    formName,
    activityId,
    activityName,
    activityType,
  ];
}
