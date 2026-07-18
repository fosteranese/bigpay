import 'dart:convert';

import 'package:equatable/equatable.dart';

class Social extends Equatable {
  final String? twitter;
  final String? instagram;
  final String? tikTok;
  final String? facebook;
  final String? linkedIn;
  final String? youTube;

  const Social({
    this.twitter,
    this.instagram,
    this.tikTok,
    this.facebook,
    this.linkedIn,
    this.youTube,
  });

  factory Social.fromMap(Map<String, dynamic> data) => Social(
    twitter: data['twitter'] as String?,
    instagram: data['instagram'] as String?,
    tikTok: data['tikTok'] as String?,
    facebook: data['facebook'] as String?,
    linkedIn: data['linkedIn'] as String?,
    youTube: data['youTube'] as String?,
  );

  Map<String, dynamic> toMap() => {
    'twitter': twitter,
    'instagram': instagram,
    'tikTok': tikTok,
    'facebook': facebook,
    'linkedIn': linkedIn,
    'youTube': youTube,
  };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Social].
  factory Social.fromJson(String data) {
    return Social.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Social] to a JSON string.
  String toJson() => json.encode(toMap());

  Social copyWith({
    String? twitter,
    String? instagram,
    String? tikTok,
    String? facebook,
    String? linkedIn,
    String? youTube,
  }) {
    return Social(
      twitter: twitter ?? this.twitter,
      instagram: instagram ?? this.instagram,
      tikTok: tikTok ?? this.tikTok,
      facebook: facebook ?? this.facebook,
      linkedIn: linkedIn ?? this.linkedIn,
      youTube: youTube ?? this.youTube,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props {
    return [
      twitter,
      instagram,
      tikTok,
      facebook,
      linkedIn,
      youTube,
    ];
  }
}
