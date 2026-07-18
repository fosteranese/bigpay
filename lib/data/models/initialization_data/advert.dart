import 'dart:convert';

import 'package:equatable/equatable.dart';

class Advert extends Equatable {
  final String? walkId;
  final String? title;
  final String? description;
  final String? picture;
  final String? pictureWeb;
  final int? walktype;
  final String? walkTarget;
  final String? walkUrl;
  final DateTime? dateCreated;
  final int? status;
  final String? statusLabel;
  final String? createdBy;
  final DateTime? lastModified;

  const Advert({
    this.walkId,
    this.title,
    this.description,
    this.picture,
    this.pictureWeb,
    this.walktype,
    this.walkTarget,
    this.walkUrl,
    this.dateCreated,
    this.status,
    this.statusLabel,
    this.createdBy,
    this.lastModified,
  });

  factory Advert.fromMap(Map<String, dynamic> data) => Advert(
    walkId: data['walkId'] as String?,
    title: data['title'] as String?,
    description: data['description'] as String?,
    picture: data['picture'] as String?,
    pictureWeb: data['pictureWeb'] as String?,
    walktype: data['walktype'] as int?,
    walkTarget: data['walkTarget'] as String?,
    walkUrl: data['walkUrl'] as String?,
    dateCreated: data['dateCreated'] == null
        ? null
        : DateTime.parse(data['dateCreated'] as String),
    status: data['status'] as int?,
    statusLabel: data['statusLabel'] as String?,
    createdBy: data['createdBy'] as String?,
    lastModified: data['lastModified'] == null
        ? null
        : DateTime.parse(data['lastModified'] as String),
  );

  Map<String, dynamic> toMap() => {
    'walkId': walkId,
    'title': title,
    'description': description,
    'picture': picture,
    'pictureWeb': pictureWeb,
    'walktype': walktype,
    'walkTarget': walkTarget,
    'walkUrl': walkUrl,
    'dateCreated': dateCreated?.toIso8601String(),
    'status': status,
    'statusLabel': statusLabel,
    'createdBy': createdBy,
    'lastModified': lastModified?.toIso8601String(),
  };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Advert].
  factory Advert.fromJson(String data) {
    return Advert.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Advert] to a JSON string.
  String toJson() => json.encode(toMap());

  Advert copyWith({
    String? walkId,
    String? title,
    String? description,
    String? picture,
    String? pictureWeb,
    int? walktype,
    String? walkTarget,
    String? walkUrl,
    DateTime? dateCreated,
    int? status,
    String? statusLabel,
    String? createdBy,
    DateTime? lastModified,
  }) {
    return Advert(
      walkId: walkId ?? this.walkId,
      title: title ?? this.title,
      description: description ?? this.description,
      picture: picture ?? this.picture,
      pictureWeb: pictureWeb ?? this.pictureWeb,
      walktype: walktype ?? this.walktype,
      walkTarget: walkTarget ?? this.walkTarget,
      walkUrl: walkUrl ?? this.walkUrl,
      dateCreated: dateCreated ?? this.dateCreated,
      status: status ?? this.status,
      statusLabel: statusLabel ?? this.statusLabel,
      createdBy: createdBy ?? this.createdBy,
      lastModified: lastModified ?? this.lastModified,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props {
    return [
      walkId,
      title,
      description,
      picture,
      pictureWeb,
      walktype,
      walkTarget,
      walkUrl,
      dateCreated,
      status,
      statusLabel,
      createdBy,
      lastModified,
    ];
  }
}
