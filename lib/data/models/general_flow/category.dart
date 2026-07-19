import 'dart:convert';

import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final String? catId;
  final String? catName;
  final String? description;
  final String? tooltip;
  final String? icon;
  final String? customCss;
  final int? status;
  final String? statusLabel;
  final DateTime? dateCreated;
  final String? createdBy;
  final int? rank;
  final DateTime? dateModified;
  final String? modifiedBy;
  final int? showInActivity;
  final String? activityId;

  const Category({
    this.catId,
    this.catName,
    this.description,
    this.tooltip,
    this.icon,
    this.customCss,
    this.status,
    this.statusLabel,
    this.dateCreated,
    this.createdBy,
    this.rank,
    this.dateModified,
    this.modifiedBy,
    this.showInActivity,
    this.activityId,
  });

  factory Category.fromMap(Map<String, dynamic> data) => Category(
        catId: data['catId'] as String?,
        catName: data['catName'] as String?,
        description: data['description'] as String?,
        tooltip: data['tooltip'] as String?,
        icon: data['icon'] as String?,
        customCss: data['customCss'] as String?,
        status: data['status'] as int?,
        statusLabel: data['statusLabel'] as String?,
        dateCreated: data['dateCreated'] == null
            ? null
            : DateTime.parse(data['dateCreated'] as String),
        createdBy: data['createdBy'] as String?,
        rank: data['rank'] as int?,
        dateModified: data['dateModified'] == null
            ? null
            : DateTime.parse(data['dateModified'] as String),
        modifiedBy: data['modifiedBy'] as String?,
        showInActivity: data['showInActivity'] as int?,
        activityId: data['activityId'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'catId': catId,
        'catName': catName,
        'description': description,
        'tooltip': tooltip,
        'icon': icon,
        'customCss': customCss,
        'status': status,
        'statusLabel': statusLabel,
        'dateCreated': dateCreated?.toIso8601String(),
        'createdBy': createdBy,
        'rank': rank,
        'dateModified': dateModified?.toIso8601String(),
        'modifiedBy': modifiedBy,
        'showInActivity': showInActivity,
        'activityId': activityId,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Category].
  factory Category.fromJson(String data) {
    return Category.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Category] to a JSON string.
  String toJson() => json.encode(toMap());

  Category copyWith({
    String? catId,
    String? catName,
    String? description,
    String? tooltip,
    String? icon,
    String? customCss,
    int? status,
    String? statusLabel,
    DateTime? dateCreated,
    String? createdBy,
    int? rank,
    DateTime? dateModified,
    String? modifiedBy,
    int? showInActivity,
    String? activityId,
  }) {
    return Category(
      catId: catId ?? this.catId,
      catName: catName ?? this.catName,
      description: description ?? this.description,
      tooltip: tooltip ?? this.tooltip,
      icon: icon ?? this.icon,
      customCss: customCss ?? this.customCss,
      status: status ?? this.status,
      statusLabel: statusLabel ?? this.statusLabel,
      dateCreated: dateCreated ?? this.dateCreated,
      createdBy: createdBy ?? this.createdBy,
      rank: rank ?? this.rank,
      dateModified: dateModified ?? this.dateModified,
      modifiedBy: modifiedBy ?? this.modifiedBy,
      showInActivity: showInActivity ?? this.showInActivity,
      activityId: activityId ?? this.activityId,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props {
    return [
      catId,
      catName,
      description,
      tooltip,
      icon,
      customCss,
      status,
      statusLabel,
      dateCreated,
      createdBy,
      rank,
      dateModified,
      modifiedBy,
      showInActivity,
      activityId,
    ];
  }
}