import 'dart:convert';

import 'package:equatable/equatable.dart';

class Activity extends Equatable {
  final String? activityId;
  final String? activityName;
  final String? activityType;
  final String? accessType;
  final String? caption;
  final String? description;
  final String? tooltip;
  final String? icon;
  final String? iconType;
  final String? customCss;
  final int? rank;
  final int? showOnDashboard;
  final int? status;
  final String? statusLabel;
  final DateTime? dateCreated;
  final String? createdBy;
  final DateTime? lastModified;
  final String? modifiedBy;
  final String? endpoint;
  final int? showInHistory;
  final int? allowPayee;

  const Activity({
    this.activityId,
    this.activityName,
    this.activityType,
    this.accessType,
    this.caption,
    this.description,
    this.tooltip,
    this.icon,
    this.iconType,
    this.customCss,
    this.rank,
    this.showOnDashboard,
    this.status,
    this.statusLabel,
    this.dateCreated,
    this.createdBy,
    this.lastModified,
    this.modifiedBy,
    this.endpoint,
    this.showInHistory,
    this.allowPayee,
  });

  factory Activity.fromMap(Map<String, dynamic> data) => Activity(
        activityId: data['activityId'] as String?,
        activityName: data['activityName'] as String?,
        activityType: data['activityType'] as String?,
        accessType: data['accessType'] as String?,
        caption: data['caption'] as String?,
        description: data['description'] as String?,
        tooltip: data['tooltip'] as String?,
        icon: data['icon'] as String?,
        iconType: data['iconType'] as String?,
        customCss: data['customCss'] as String?,
        rank: data['rank'] as int?,
        showOnDashboard: data['showOnDashboard'] as int?,
        status: data['status'] as int?,
        statusLabel: data['statusLabel'] as String?,
        dateCreated: data['dateCreated'] == null ? null : DateTime.parse(data['dateCreated'] as String),
        createdBy: data['createdBy'] as String?,
        lastModified: data['lastModified'] == null ? null : DateTime.parse(data['lastModified'] as String),
        modifiedBy: data['modifiedBy'] as String?,
        endpoint: data['endpoint'] as String?,
        showInHistory: data['showInHistory'] as int?,
        allowPayee: data['allowPayee'] as int?,
      );

  Map<String, dynamic> toMap() => {
        'activityId': activityId,
        'activityName': activityName,
        'activityType': activityType,
        'accessType': accessType,
        'caption': caption,
        'description': description,
        'tooltip': tooltip,
        'icon': icon,
        'iconType': iconType,
        'customCss': customCss,
        'rank': rank,
        'showOnDashboard': showOnDashboard,
        'status': status,
        'statusLabel': statusLabel,
        'dateCreated': dateCreated?.toIso8601String(),
        'createdBy': createdBy,
        'lastModified': lastModified?.toIso8601String(),
        'modifiedBy': modifiedBy,
        'endpoint': endpoint,
        'showInHistory': showInHistory,
        'allowPayee': allowPayee,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Activity].
  factory Activity.fromJson(String data) {
    return Activity.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Activity] to a JSON string.
  String toJson() => json.encode(toMap());

  Activity copyWith({
    String? activityId,
    String? activityName,
    String? activityType,
    String? accessType,
    String? caption,
    String? description,
    String? tooltip,
    String? icon,
    String? iconType,
    String? customCss,
    int? rank,
    int? showOnDashboard,
    int? status,
    String? statusLabel,
    DateTime? dateCreated,
    String? createdBy,
    DateTime? lastModified,
    String? modifiedBy,
    String? endpoint,
    int? showInHistory,
    int? allowPayee,
  }) {
    return Activity(
      activityId: activityId ?? this.activityId,
      activityName: activityName ?? this.activityName,
      activityType: activityType ?? this.activityType,
      accessType: accessType ?? this.accessType,
      caption: caption ?? this.caption,
      description: description ?? this.description,
      tooltip: tooltip ?? this.tooltip,
      icon: icon ?? this.icon,
      iconType: iconType ?? this.iconType,
      customCss: customCss ?? this.customCss,
      rank: rank ?? this.rank,
      showOnDashboard: showOnDashboard ?? this.showOnDashboard,
      status: status ?? this.status,
      statusLabel: statusLabel ?? this.statusLabel,
      dateCreated: dateCreated ?? this.dateCreated,
      createdBy: createdBy ?? this.createdBy,
      lastModified: lastModified ?? this.lastModified,
      modifiedBy: modifiedBy ?? this.modifiedBy,
      endpoint: endpoint ?? this.endpoint,
      showInHistory: showInHistory ?? this.showInHistory,
      allowPayee: allowPayee ?? this.allowPayee,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props {
    return [
      activityId,
      activityName,
      activityType,
      accessType,
      caption,
      description,
      tooltip,
      icon,
      iconType,
      customCss,
      rank,
      showOnDashboard,
      status,
      statusLabel,
      dateCreated,
      createdBy,
      lastModified,
      modifiedBy,
      endpoint,
      showInHistory,
      allowPayee,
    ];
  }
}