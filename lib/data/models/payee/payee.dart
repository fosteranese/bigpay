import 'package:equatable/equatable.dart';

/// A saved recipient for a form, returned by `Payee/getPayeesByFormId`.
///
/// [value] is what goes into the field on selection; [formData] carries the
/// other saved field values so a form can prefill itself.
class Payee extends Equatable {
  const Payee({
    this.payeeId,
    this.formId,
    this.title,
    this.value,
    this.shortTitle,
    this.icon,
    this.formData,
  });

  final String? payeeId;
  final String? formId;
  final String? title;
  final String? value;
  final String? shortTitle;
  final String? icon;
  final Map<String, dynamic>? formData;

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
  );

  Map<String, dynamic> toMap() => {
    'payeeId': payeeId,
    'formId': formId,
    'title': title,
    'value': value,
    'shortTitle': shortTitle,
    'icon': icon,
    'formData': formData,
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
  ];
}
