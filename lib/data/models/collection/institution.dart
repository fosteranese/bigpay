import 'dart:convert';

import 'package:equatable/equatable.dart';

class Institution extends Equatable {
  final String? insId;
  final String? catId;
  final String? insName;
  final String? description;
  final String? tooltip;
  final String? icon;
  final String? customCss;
  final String? insCode;

  const Institution({
    this.insId,
    this.catId,
    this.insName,
    this.description,
    this.tooltip,
    this.icon,
    this.customCss,
    this.insCode,
  });

  factory Institution.fromMap(Map<String, dynamic> data) =>
      Institution(
        insId: data['insId'] as String?,
        catId: data['catId'] as String?,
        insName: data['insName'] as String?,
        description: data['description'] as String?,
        tooltip: data['tooltip'] as String?,
        icon: data['icon'] as String?,
        customCss: data['customCss'] as String?,
        insCode: data['insCode'] as String?,
      );

  Map<String, dynamic> toMap() => {
    'insId': insId,
    'catId': catId,
    'insName': insName,
    'description': description,
    'tooltip': tooltip,
    'icon': icon,
    'customCss': customCss,
    'insCode': insCode,
  };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Institution].
  factory Institution.fromJson(String data) {
    return Institution.fromMap(
      json.decode(data) as Map<String, dynamic>,
    );
  }

  /// `dart:convert`
  ///
  /// Converts [Institution] to a JSON string.
  String toJson() => json.encode(toMap());

  Institution copyWith({
    String? insId,
    String? catId,
    String? insName,
    String? description,
    String? tooltip,
    String? icon,
    String? customCss,
    String? insCode,
  }) {
    return Institution(
      insId: insId ?? this.insId,
      catId: catId ?? this.catId,
      insName: insName ?? this.insName,
      description: description ?? this.description,
      tooltip: tooltip ?? this.tooltip,
      icon: icon ?? this.icon,
      customCss: customCss ?? this.customCss,
      insCode: insCode ?? this.insCode,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props {
    return [
      insId,
      catId,
      insName,
      description,
      tooltip,
      icon,
      customCss,
      insCode,
    ];
  }
}
