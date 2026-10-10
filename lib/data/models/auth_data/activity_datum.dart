import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'activity.dart';

class ActivityDatum extends Equatable {
  final Activity? activity;
  final String? activityItems;
  final dynamic imageDirectory;

  const ActivityDatum({
    this.activity,
    this.activityItems,
    this.imageDirectory,
  });

  factory ActivityDatum.fromMap(Map<String, dynamic> data) => ActivityDatum(
        activity: data['activity'] == null
            ? null
            : Activity.fromMap(data['activity'] as Map<String, dynamic>),
        activityItems: data['activityItems'] as String?,
        imageDirectory: data['imageDirectory'] as dynamic,
      );

  Map<String, dynamic> toMap() => {
        'activity': activity?.toMap(),
        'activityItems': activityItems,
        'imageDirectory': imageDirectory,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [ActivityDatum].
  factory ActivityDatum.fromJson(String data) {
    return ActivityDatum.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [ActivityDatum] to a JSON string.
  String toJson() => json.encode(toMap());

  ActivityDatum copyWith({
    Activity? activity,
    String? activityItems,
    dynamic imageDirectory,
  }) {
    return ActivityDatum(
      activity: activity ?? this.activity,
      activityItems: activityItems ?? this.activityItems,
      imageDirectory: imageDirectory ?? this.imageDirectory,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [activity, activityItems, imageDirectory];
}