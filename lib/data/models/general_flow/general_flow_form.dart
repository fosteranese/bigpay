import 'dart:convert';

import 'package:equatable/equatable.dart';

class GeneralFlowForm extends Equatable {
  final String? formId;
  final String? categoryId;
  final String? accessType;
  final String? formName;
  final String? description;
  final String? caption;
  final String? tooltip;
  final String? icon;
  final String? iconType;
  final int? requireVerification;
  final String? verifyEndpoint;
  final String? processEndpoint;
  final int? rank;
  final int? status;
  final String? statusLabel;
  final DateTime? dateCreated;
  final String? createdBy;
  final DateTime? dateModified;
  final String? modifiedBy;
  final String? internalEndpoint;
  final String? activityType;
  final int? showInHistory;
  final int? showInFavourite;
  final int? showReceipt;
  final int? allowBeneficiary;
  final int? allowSchedule;

  const GeneralFlowForm({
    this.formId,
    this.categoryId,
    this.accessType,
    this.formName,
    this.description,
    this.caption,
    this.tooltip,
    this.icon,
    this.iconType,
    this.requireVerification,
    this.verifyEndpoint,
    this.processEndpoint,
    this.rank,
    this.status,
    this.statusLabel,
    this.dateCreated,
    this.createdBy,
    this.dateModified,
    this.modifiedBy,
    this.internalEndpoint,
    this.activityType,
    this.showInHistory,
    this.showInFavourite,
    this.showReceipt,
    this.allowBeneficiary,
    this.allowSchedule,
  });

  factory GeneralFlowForm.fromMap(Map<String, dynamic> data) => GeneralFlowForm(
        formId: data['formId'] as String?,
        categoryId: data['categoryId'] as String?,
        accessType: data['accessType'] as String?,
        formName: data['formName'] as String?,
        description: data['description'] as String?,
        caption: data['caption'] as String?,
        tooltip: data['tooltip'] as String?,
        icon: data['icon'] as String?,
        iconType: data['iconType'] as String?,
        requireVerification: data['requireVerification'] as int?,
        verifyEndpoint: data['verifyEndpoint'] as String?,
        processEndpoint: data['processEndpoint'] as String?,
        rank: data['rank'] as int?,
        status: data['status'] as int?,
        statusLabel: data['statusLabel'] as String?,
        dateCreated: data['dateCreated'] == null
            ? null
            : DateTime.parse(data['dateCreated'] as String),
        createdBy: data['createdBy'] as String?,
        dateModified: data['dateModified'] == null
            ? null
            : DateTime.parse(data['dateModified'] as String),
        modifiedBy: data['modifiedBy'] as String?,
        internalEndpoint: data['internalEndpoint'] as String?,
        activityType: data['activityType'] as String?,
        showInHistory: data['showInHistory'] as int?,
        showInFavourite: data['showInFavourite'] as int?,
        showReceipt: data['showReceipt'] as int?,
        allowBeneficiary: data['allowBeneficiary'] as int?,
        allowSchedule: data['allowSchedule'] as int?,
      );

  Map<String, dynamic> toMap() => {
        'formId': formId,
        'categoryId': categoryId,
        'accessType': accessType,
        'formName': formName,
        'description': description,
        'caption': caption,
        'tooltip': tooltip,
        'icon': icon,
        'iconType': iconType,
        'requireVerification': requireVerification,
        'verifyEndpoint': verifyEndpoint,
        'processEndpoint': processEndpoint,
        'rank': rank,
        'status': status,
        'statusLabel': statusLabel,
        'dateCreated': dateCreated?.toIso8601String(),
        'createdBy': createdBy,
        'dateModified': dateModified?.toIso8601String(),
        'modifiedBy': modifiedBy,
        'internalEndpoint': internalEndpoint,
        'activityType': activityType,
        'showInHistory': showInHistory,
        'showInFavourite': showInFavourite,
        'showReceipt': showReceipt,
        'allowBeneficiary': allowBeneficiary,
        'allowSchedule': allowSchedule,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Form].
  factory GeneralFlowForm.fromJson(String data) {
    return GeneralFlowForm.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Form] to a JSON string.
  String toJson() => json.encode(toMap());

  GeneralFlowForm copyWith({
    String? formId,
    String? categoryId,
    String? accessType,
    String? formName,
    String? description,
    String? caption,
    String? tooltip,
    String? icon,
    String? iconType,
    int? requireVerification,
    String? verifyEndpoint,
    String? processEndpoint,
    int? rank,
    int? status,
    String? statusLabel,
    DateTime? dateCreated,
    String? createdBy,
    DateTime? dateModified,
    String? modifiedBy,
    String? internalEndpoint,
    String? activityType,
    int? showInHistory,
    int? showInFavourite,
    int? showReceipt,
    int? allowBeneficiary,
    int? allowSchedule,
  }) {
    return GeneralFlowForm(
      formId: formId ?? this.formId,
      categoryId: categoryId ?? this.categoryId,
      accessType: accessType ?? this.accessType,
      formName: formName ?? this.formName,
      description: description ?? this.description,
      caption: caption ?? this.caption,
      tooltip: tooltip ?? this.tooltip,
      icon: icon ?? this.icon,
      iconType: iconType ?? this.iconType,
      requireVerification: requireVerification ?? this.requireVerification,
      verifyEndpoint: verifyEndpoint ?? this.verifyEndpoint,
      processEndpoint: processEndpoint ?? this.processEndpoint,
      rank: rank ?? this.rank,
      status: status ?? this.status,
      statusLabel: statusLabel ?? this.statusLabel,
      dateCreated: dateCreated ?? this.dateCreated,
      createdBy: createdBy ?? this.createdBy,
      dateModified: dateModified ?? this.dateModified,
      modifiedBy: modifiedBy ?? this.modifiedBy,
      internalEndpoint: internalEndpoint ?? this.internalEndpoint,
      activityType: activityType ?? this.activityType,
      showInHistory: showInHistory ?? this.showInHistory,
      showInFavourite: showInFavourite ?? this.showInFavourite,
      showReceipt: showReceipt ?? this.showReceipt,
      allowBeneficiary: allowBeneficiary ?? this.allowBeneficiary,
      allowSchedule: allowSchedule ?? this.allowSchedule,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props {
    return [
      formId,
      categoryId,
      accessType,
      formName,
      description,
      caption,
      tooltip,
      icon,
      iconType,
      requireVerification,
      verifyEndpoint,
      processEndpoint,
      rank,
      status,
      statusLabel,
      dateCreated,
      createdBy,
      dateModified,
      modifiedBy,
      internalEndpoint,
      activityType,
      showInHistory,
      showInFavourite,
      showReceipt,
      allowBeneficiary,
      allowSchedule,
    ];
  }
}