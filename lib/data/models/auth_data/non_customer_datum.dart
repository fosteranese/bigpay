import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'activity.dart';

class NonCustomerDatum extends Equatable {
  final Activity? activity;
  final List<dynamic>? activityItems;
  final String? imageDirectory;

  const NonCustomerDatum({
    this.activity,
    this.activityItems,
    this.imageDirectory,
  });

  factory NonCustomerDatum.fromMap(Map<String, dynamic> data) {
    return NonCustomerDatum(
      activity: data['activity'] == null ? null : Activity.fromMap(data['activity'] as Map<String, dynamic>),
      activityItems: data['activityItems'] as List<dynamic>?,
      imageDirectory: data['imageDirectory'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'activity': activity?.toMap(),
        'activityItems': activityItems,
        'imageDirectory': imageDirectory,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [NonCustomerDatum].
  factory NonCustomerDatum.fromJson(String data) {
    return NonCustomerDatum.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [NonCustomerDatum] to a JSON string.
  String toJson() => json.encode(toMap());

  NonCustomerDatum copyWith({
    Activity? activity,
    List<dynamic>? activityItems,
    String? imageDirectory,
  }) {
    return NonCustomerDatum(
      activity: activity ?? this.activity,
      activityItems: activityItems ?? this.activityItems,
      imageDirectory: imageDirectory ?? this.imageDirectory,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [
        activity,
        activityItems,
        imageDirectory,
      ];
}