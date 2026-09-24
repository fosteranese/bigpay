import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'source.dart';

class Account extends Equatable {
  final String? mode;
  final String? title;
  final String? icon;
  final String? formId;
  final String? activityId;
  final bool? hasMiniStatement;
  final String? activityType;
  final List<Source>? sources;

  const Account({
    this.mode,
    this.title,
    this.icon,
    this.formId,
    this.activityId,
    this.hasMiniStatement,
    this.activityType,
    this.sources,
  });

  factory Account.fromMap(Map<String, dynamic> data) => Account(
    mode: data['mode'] as String?,
    title: data['title'] as String?,
    icon: data['icon'] as String?,
    formId: data['formId'] as String?,
    activityId: data['activityId'] as String?,
    hasMiniStatement: data['hasMiniStatement'] as bool?,
    activityType: data['activityType'] as String?,
    sources: (data['sources'] as List<dynamic>?)
        ?.map(
          (e) => Source.fromMap(e as Map<String, dynamic>),
        )
        .toList(),
  );

  Map<String, dynamic> toMap() => {
    'mode': mode,
    'title': title,
    'icon': icon,
    'formId': formId,
    'activityId': activityId,
    'hasMiniStatement': hasMiniStatement,
    'activityType': activityType,
    'sources': sources?.map((e) => e.toMap()).toList(),
  };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Account].
  factory Account.fromJson(String data) {
    return Account.fromMap(
      json.decode(data) as Map<String, dynamic>,
    );
  }

  /// `dart:convert`
  ///
  /// Converts [Account] to a JSON string.
  String toJson() => json.encode(toMap());

  Account copyWith({
    String? mode,
    String? title,
    String? icon,
    String? formId,
    String? activityId,
    bool? hasMiniStatement,
    String? activityType,
    List<Source>? sources,
  }) {
    return Account(
      mode: mode ?? this.mode,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      formId: formId ?? this.formId,
      activityId: activityId ?? this.activityId,
      hasMiniStatement: hasMiniStatement ?? this.hasMiniStatement,
      activityType: activityType ?? this.activityType,
      sources: sources ?? this.sources,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props {
    return [
      mode,
      title,
      icon,
      formId,
      activityId,
      hasMiniStatement,
      activityType,
      sources,
    ];
  }
}
