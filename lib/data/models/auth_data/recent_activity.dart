import 'dart:convert';

import 'package:equatable/equatable.dart';

class RecentActivity extends Equatable {
  final String? activityId;
  final String? formId;
  final String? formName;
  final String? activityName;
  final String? activityType;
  final String? icon;
  final String? iconPath;
  final String? endpoint;

  const RecentActivity({
    this.activityId,
    this.formId,
    this.formName,
    this.activityName,
    this.activityType,
    this.icon,
    this.iconPath,
    this.endpoint,
  });

  factory RecentActivity.fromMap(
    Map<String, dynamic> data,
  ) {
    return RecentActivity(
      activityId: data['activityId'] as String?,
      formId: data['formId'] as String?,
      formName: data['formName'] as String?,
      activityName: data['activityName'] as String?,
      activityType: data['activityType'] as String?,
      icon: data['icon'] as String?,
      iconPath: data['iconPath'] as String?,
      endpoint: data['endpoint'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'activityId': activityId,
    'formId': formId,
    'formName': formName,
    'activityName': activityName,
    'activityType': activityType,
    'icon': icon,
    'iconPath': iconPath,
    'endpoint': endpoint,
  };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [RecentActivity].
  factory RecentActivity.fromJson(String data) {
    return RecentActivity.fromMap(
      json.decode(data) as Map<String, dynamic>,
    );
  }

  /// `dart:convert`
  ///
  /// Converts [RecentActivity] to a JSON string.
  String toJson() => json.encode(toMap());

  RecentActivity copyWith({
    String? activityId,
    String? formId,
    String? formName,
    String? activityName,
    String? activityType,
    String? icon,
    String? iconPath,
    String? endpoint,
  }) {
    return RecentActivity(
      activityId: activityId ?? this.activityId,
      formId: formId ?? this.formId,
      formName: formName ?? this.formName,
      activityName: activityName ?? this.activityName,
      activityType: activityType ?? this.activityType,
      icon: icon ?? this.icon,
      iconPath: iconPath ?? this.iconPath,
      endpoint: endpoint ?? this.endpoint,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props {
    return [
      activityId,
      formId,
      formName,
      activityName,
      activityType,
      icon,
      iconPath,
      endpoint,
    ];
  }
}
