import 'dart:convert';

import 'package:equatable/equatable.dart';

class Field extends Equatable {
  final String? fieldId;
  final String? insId;
  final String? formId;
  final String? fieldName;
  final String? caption;
  final int? fieldType;
  final int? fieldDataType;
  final int? fieldLength;
  final String? fieldDateFormat;
  final int? fieldMandatory;
  final int? fieldInRemarks;
  final int? rank;
  final int? fieldVisible;
  final String? defaultValue;
  final String? actualValue;
  final int? readOnly;
  final int? showOnReceipt;
  final int? isAmount;
  final String? dataSource;
  final int? showOnline;
  final String? tooltip;
  final int? requireVerification;
  final String? lovEndpoint;

  const Field({
    this.fieldId,
    this.insId,
    this.formId,
    this.fieldName,
    this.caption,
    this.fieldType,
    this.fieldDataType,
    this.fieldLength,
    this.fieldDateFormat,
    this.fieldMandatory,
    this.fieldInRemarks,
    this.rank,
    this.fieldVisible,
    this.defaultValue,
    this.actualValue,
    this.readOnly,
    this.showOnReceipt,
    this.isAmount,
    this.dataSource,
    this.showOnline,
    this.tooltip,
    this.requireVerification,
    this.lovEndpoint,
  });

  factory Field.fromMap(Map<String, dynamic> data) => Field(
        fieldId: data['fieldId'] as String?,
        insId: data['insId'] as String?,
        formId: data['formId'] as String?,
        fieldName: data['fieldName'] as String?,
        caption: data['caption'] as String?,
        fieldType: data['fieldType'] as int?,
        fieldDataType: data['fieldDataType'] as int?,
        fieldLength: data['fieldLength'] as int?,
        fieldDateFormat: data['fieldDateFormat'] as String?,
        fieldMandatory: data['fieldMandatory'] as int?,
        fieldInRemarks: data['fieldInRemarks'] as int?,
        rank: data['rank'] as int?,
        fieldVisible: data['fieldVisible'] as int?,
        defaultValue: data['defaultValue'] as String?,
        actualValue: data['actualValue'] as String?,
        readOnly: data['readOnly'] as int?,
        showOnReceipt: data['showOnReceipt'] as int?,
        isAmount: data['isAmount'] as int?,
        dataSource: data['dataSource'] as String?,
        showOnline: data['showOnline'] as int?,
        tooltip: data['tooltip'] as String?,
        requireVerification: data['requireVerification'] as int?,
        lovEndpoint: data['lovEndpoint'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'fieldId': fieldId,
        'insId': insId,
        'formId': formId,
        'fieldName': fieldName,
        'caption': caption,
        'fieldType': fieldType,
        'fieldDataType': fieldDataType,
        'fieldLength': fieldLength,
        'fieldDateFormat': fieldDateFormat,
        'fieldMandatory': fieldMandatory,
        'fieldInRemarks': fieldInRemarks,
        'rank': rank,
        'fieldVisible': fieldVisible,
        'defaultValue': defaultValue,
        'actualValue': actualValue,
        'readOnly': readOnly,
        'showOnReceipt': showOnReceipt,
        'isAmount': isAmount,
        'dataSource': dataSource,
        'showOnline': showOnline,
        'tooltip': tooltip,
        'requireVerification': requireVerification,
        'lovEndpoint': lovEndpoint,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Field].
  factory Field.fromJson(String data) {
    return Field.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Field] to a JSON string.
  String toJson() => json.encode(toMap());

  Field copyWith({
    String? fieldId,
    String? insId,
    String? formId,
    String? fieldName,
    String? caption,
    int? fieldType,
    int? fieldDataType,
    int? fieldLength,
    String? fieldDateFormat,
    int? fieldMandatory,
    int? fieldInRemarks,
    int? rank,
    int? fieldVisible,
    String? defaultValue,
    String? actualValue,
    int? readOnly,
    int? showOnReceipt,
    int? isAmount,
    String? dataSource,
    int? showOnline,
    String? tooltip,
    int? requireVerification,
    String? lovEndpoint,
  }) {
    return Field(
      fieldId: fieldId ?? this.fieldId,
      insId: insId ?? this.insId,
      formId: formId ?? this.formId,
      fieldName: fieldName ?? this.fieldName,
      caption: caption ?? this.caption,
      fieldType: fieldType ?? this.fieldType,
      fieldDataType: fieldDataType ?? this.fieldDataType,
      fieldLength: fieldLength ?? this.fieldLength,
      fieldDateFormat: fieldDateFormat ?? this.fieldDateFormat,
      fieldMandatory: fieldMandatory ?? this.fieldMandatory,
      fieldInRemarks: fieldInRemarks ?? this.fieldInRemarks,
      rank: rank ?? this.rank,
      fieldVisible: fieldVisible ?? this.fieldVisible,
      defaultValue: defaultValue ?? this.defaultValue,
      actualValue: actualValue ?? this.actualValue,
      readOnly: readOnly ?? this.readOnly,
      showOnReceipt: showOnReceipt ?? this.showOnReceipt,
      isAmount: isAmount ?? this.isAmount,
      dataSource: dataSource ?? this.dataSource,
      showOnline: showOnline ?? this.showOnline,
      tooltip: tooltip ?? this.tooltip,
      requireVerification: requireVerification ?? this.requireVerification,
      lovEndpoint: lovEndpoint ?? this.lovEndpoint,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props {
    return [
      fieldId,
      insId,
      formId,
      fieldName,
      caption,
      fieldType,
      fieldDataType,
      fieldLength,
      fieldDateFormat,
      fieldMandatory,
      fieldInRemarks,
      rank,
      fieldVisible,
      defaultValue,
      actualValue,
      readOnly,
      showOnReceipt,
      isAmount,
      dataSource,
      showOnline,
      tooltip,
      requireVerification,
      lovEndpoint,
    ];
  }
}