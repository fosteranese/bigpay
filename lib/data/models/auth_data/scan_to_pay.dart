import 'dart:convert';

import 'package:equatable/equatable.dart';

import '../general_flow/general_flow_form.dart';
import 'activity.dart';

class ScanToPay extends Equatable {
  final Activity? activity;
  final List<GeneralFlowForm>? activityItems;
  final String? imageDirectory;

  const ScanToPay({this.activity, this.activityItems, this.imageDirectory});

  factory ScanToPay.fromMap(Map<String, dynamic> data) => ScanToPay(
    activity: data['activity'] == null
        ? null
        : Activity.fromMap(data['activity'] as Map<String, dynamic>),
    activityItems: (data['activityItems'] as List<dynamic>?)
        ?.map((e) => GeneralFlowForm.fromMap(e as Map<String, dynamic>))
        .toList(),
    imageDirectory: data['imageDirectory'] as String?,
  );

  Map<String, dynamic> toMap() => {
    'activity': activity?.toMap(),
    'activityItems': activityItems?.map((e) => e.toMap()).toList(),
    'imageDirectory': imageDirectory,
  };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [ScanToPay].
  factory ScanToPay.fromJson(String data) {
    return ScanToPay.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [ScanToPay] to a JSON string.
  String toJson() => json.encode(toMap());

  ScanToPay copyWith({
    Activity? activity,
    List<GeneralFlowForm>? activityItems,
    String? imageDirectory,
  }) {
    return ScanToPay(
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
