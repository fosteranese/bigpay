import 'dart:convert';

import 'package:equatable/equatable.dart';

class LocatorType extends Equatable {
  final String? typeId;
  final dynamic picture;
  final String? title;
  final dynamic description;
  final int? status;
  final DateTime? dateCreated;
  final int? rank;

  const LocatorType({
    this.typeId,
    this.picture,
    this.title,
    this.description,
    this.status,
    this.dateCreated,
    this.rank,
  });

  factory LocatorType.fromMap(Map<String, dynamic> data) => LocatorType(
    typeId: data['typeId'] as String?,
    picture: data['picture'] as dynamic,
    title: data['title'] as String?,
    description: data['description'] as dynamic,
    status: data['status'] as int?,
    dateCreated: data['dateCreated'] == null
        ? null
        : DateTime.parse(data['dateCreated'] as String),
    rank: data['rank'] as int?,
  );

  Map<String, dynamic> toMap() => {
    'typeId': typeId,
    'picture': picture,
    'title': title,
    'description': description,
    'status': status,
    'dateCreated': dateCreated?.toIso8601String(),
    'rank': rank,
  };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [LocatorType].
  factory LocatorType.fromJson(String data) {
    return LocatorType.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [LocatorType] to a JSON string.
  String toJson() => json.encode(toMap());

  LocatorType copyWith({
    String? typeId,
    dynamic picture,
    String? title,
    dynamic description,
    int? status,
    DateTime? dateCreated,
    int? rank,
  }) {
    return LocatorType(
      typeId: typeId ?? this.typeId,
      picture: picture ?? this.picture,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      dateCreated: dateCreated ?? this.dateCreated,
      rank: rank ?? this.rank,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props {
    return [
      typeId,
      picture,
      title,
      description,
      status,
      dateCreated,
      rank,
    ];
  }
}
