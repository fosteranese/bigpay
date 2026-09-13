import 'dart:convert';

import 'package:equatable/equatable.dart';

class GeneralFlowField extends Equatable {
  final String? fieldId;
  final String? formId;
  final String? fieldName;
  final String? fieldCaption;
  final int? fieldType;
  final int? fieldDataType;
  final int? fieldLength;
  final String? fieldDateFormat;
  final int? fieldMandatory;
  final int? fieldInRemarks;
  final int? rank;
  final int? fieldVisible;
  final String? defaultValue;
  final int? readOnly;
  final int? showOnReceipt;
  final int? isAmount;
  final int? requiredForVerification;
  final String? toolTip;
  final DateTime? dateCreated;
  final String? createdBy;
  final String? modifiedBy;
  final DateTime? dateModified;
  final int? status;
  final int? thirdParty;
  final String? statusLabel;
  final String? lovEndpoint;
  final double? trasactionLimitAmount;

  const GeneralFlowField({
    this.fieldId,
    this.formId,
    this.fieldName,
    this.fieldCaption,
    this.fieldType,
    this.fieldDataType,
    this.fieldLength,
    this.fieldDateFormat,
    this.fieldMandatory,
    this.fieldInRemarks,
    this.rank,
    this.fieldVisible,
    this.defaultValue,
    this.readOnly,
    this.showOnReceipt,
    this.isAmount,
    this.requiredForVerification,
    this.toolTip,
    this.dateCreated,
    this.createdBy,
    this.modifiedBy,
    this.dateModified,
    this.status,
    this.thirdParty,
    this.statusLabel,
    this.lovEndpoint,
    this.trasactionLimitAmount,
  });

  factory GeneralFlowField.fromMap(
    Map<String, dynamic> data,
  ) {
    return GeneralFlowField(
      fieldId: data['fieldId'] as String?,
      formId: data['formId'] as String?,
      fieldName: data['fieldName'] as String?,
      fieldCaption: data['fieldCaption'] as String?,
      fieldType: data['fieldType'] as int?,
      fieldDataType: data['fieldDataType'] as int?,
      fieldLength: data['fieldLength'] as int?,
      fieldDateFormat: data['fieldDateFormat'] as String?,
      fieldMandatory: data['fieldMandatory'] as int?,
      fieldInRemarks: data['fieldInRemarks'] as int?,
      rank: data['rank'] as int?,
      fieldVisible: data['fieldVisible'] as int?,
      defaultValue: data['defaultValue'] as String?,
      readOnly: data['readOnly'] as int?,
      showOnReceipt: data['showOnReceipt'] as int?,
      isAmount: data['isAmount'] as int?,
      requiredForVerification:
          data['requiredForVerification'] as int?,
      toolTip: data['toolTip'] as String?,
      dateCreated: data['dateCreated'] == null
          ? null
          : DateTime.parse(data['dateCreated'] as String),
      createdBy: data['createdBy'] as String?,
      modifiedBy: data['modifiedBy'] as String?,
      dateModified: data['dateModified'] == null
          ? null
          : DateTime.parse(data['dateModified'] as String),
      status: data['status'] as int?,
      thirdParty: data['thirdParty'] as int?,
      statusLabel: data['statusLabel'] as String?,
      lovEndpoint: data['lovEndpoint'] as String?,
      trasactionLimitAmount:
          (data['trasactionLimitAmount'] as num?)
              ?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {
    'fieldId': fieldId,
    'formId': formId,
    'fieldName': fieldName,
    'fieldCaption': fieldCaption,
    'fieldType': fieldType,
    'fieldDataType': fieldDataType,
    'fieldLength': fieldLength,
    'fieldDateFormat': fieldDateFormat,
    'fieldMandatory': fieldMandatory,
    'fieldInRemarks': fieldInRemarks,
    'rank': rank,
    'fieldVisible': fieldVisible,
    'defaultValue': defaultValue,
    'readOnly': readOnly,
    'showOnReceipt': showOnReceipt,
    'isAmount': isAmount,
    'requiredForVerification': requiredForVerification,
    'toolTip': toolTip,
    'dateCreated': dateCreated?.toIso8601String(),
    'createdBy': createdBy,
    'modifiedBy': modifiedBy,
    'dateModified': dateModified?.toIso8601String(),
    'status': status,
    'thirdParty': thirdParty,
    'statusLabel': statusLabel,
    'lovEndpoint': lovEndpoint,
    'trasactionLimitAmount': trasactionLimitAmount,
  };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [GeneralFlowField].
  factory GeneralFlowField.fromJson(String data) {
    return GeneralFlowField.fromMap(
      json.decode(data) as Map<String, dynamic>,
    );
  }

  /// `dart:convert`
  ///
  /// Converts [GeneralFlowField] to a JSON string.
  String toJson() => json.encode(toMap());

  GeneralFlowField copyWith({
    String? fieldId,
    String? formId,
    String? fieldName,
    String? fieldCaption,
    int? fieldType,
    int? fieldDataType,
    int? fieldLength,
    String? fieldDateFormat,
    int? fieldMandatory,
    int? fieldInRemarks,
    int? rank,
    int? fieldVisible,
    String? defaultValue,
    int? readOnly,
    int? showOnReceipt,
    int? isAmount,
    int? requiredForVerification,
    String? toolTip,
    DateTime? dateCreated,
    String? createdBy,
    String? modifiedBy,
    DateTime? dateModified,
    int? status,
    int? thirdParty,
    String? statusLabel,
    String? lovEndpoint,
    double? trasactionLimitAmount,
  }) {
    return GeneralFlowField(
      fieldId: fieldId ?? this.fieldId,
      formId: formId ?? this.formId,
      fieldName: fieldName ?? this.fieldName,
      fieldCaption: fieldCaption ?? this.fieldCaption,
      fieldType: fieldType ?? this.fieldType,
      fieldDataType: fieldDataType ?? this.fieldDataType,
      fieldLength: fieldLength ?? this.fieldLength,
      fieldDateFormat:
          fieldDateFormat ?? this.fieldDateFormat,
      fieldMandatory: fieldMandatory ?? this.fieldMandatory,
      fieldInRemarks: fieldInRemarks ?? this.fieldInRemarks,
      rank: rank ?? this.rank,
      fieldVisible: fieldVisible ?? this.fieldVisible,
      defaultValue: defaultValue ?? this.defaultValue,
      readOnly: readOnly ?? this.readOnly,
      showOnReceipt: showOnReceipt ?? this.showOnReceipt,
      isAmount: isAmount ?? this.isAmount,
      requiredForVerification:
          requiredForVerification ??
          this.requiredForVerification,
      toolTip: toolTip ?? this.toolTip,
      dateCreated: dateCreated ?? this.dateCreated,
      createdBy: createdBy ?? this.createdBy,
      modifiedBy: modifiedBy ?? this.modifiedBy,
      dateModified: dateModified ?? this.dateModified,
      status: status ?? this.status,
      thirdParty: thirdParty ?? this.thirdParty,
      statusLabel: statusLabel ?? this.statusLabel,
      lovEndpoint: lovEndpoint ?? this.lovEndpoint,
      trasactionLimitAmount:
          trasactionLimitAmount ?? trasactionLimitAmount,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props {
    return [
      fieldId,
      formId,
      fieldName,
      fieldCaption,
      fieldType,
      fieldDataType,
      fieldLength,
      fieldDateFormat,
      fieldMandatory,
      fieldInRemarks,
      rank,
      fieldVisible,
      defaultValue,
      readOnly,
      showOnReceipt,
      isAmount,
      requiredForVerification,
      toolTip,
      dateCreated,
      createdBy,
      modifiedBy,
      dateModified,
      status,
      thirdParty,
      statusLabel,
      lovEndpoint,
      trasactionLimitAmount,
    ];
  }
}
