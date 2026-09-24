import 'dart:convert';

import 'package:equatable/equatable.dart';

class Payment extends Equatable {
  final String? catId;
  final String? catName;
  final String? description;
  final String? tooltip;
  final String? icon;
  final String? customCss;
  final int? status;
  final int? rank;

  const Payment({
    this.catId,
    this.catName,
    this.description,
    this.tooltip,
    this.icon,
    this.customCss,
    this.status,
    this.rank,
  });

  factory Payment.fromMap(Map<String, dynamic> data) => Payment(
        catId: data['catId'] as String?,
        catName: data['catName'] as String?,
        description: data['description'] as String?,
        tooltip: data['tooltip'] as String?,
        icon: data['icon'] as String?,
        customCss: data['customCss'] as String?,
        status: data['status'] as int?,
        rank: data['rank'] as int?,
      );

  Map<String, dynamic> toMap() => {
        'catId': catId,
        'catName': catName,
        'description': description,
        'tooltip': tooltip,
        'icon': icon,
        'customCss': customCss,
        'status': status,
        'rank': rank,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Payment].
  factory Payment.fromJson(String data) {
    return Payment.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Payment] to a JSON string.
  String toJson() => json.encode(toMap());

  Payment copyWith({
    String? catId,
    String? catName,
    String? description,
    String? tooltip,
    String? icon,
    String? customCss,
    int? status,
    int? rank,
  }) {
    return Payment(
      catId: catId ?? this.catId,
      catName: catName ?? this.catName,
      description: description ?? this.description,
      tooltip: tooltip ?? this.tooltip,
      icon: icon ?? this.icon,
      customCss: customCss ?? this.customCss,
      status: status ?? this.status,
      rank: rank ?? this.rank,
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
      rank,
    ];
  }
}