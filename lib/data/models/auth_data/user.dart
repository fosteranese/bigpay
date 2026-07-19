import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'preview_datum.dart';

class User extends Equatable {
  final String? picture;
  final String? name;
  final String? shortName;
  final String? verified;
  final String? lastLogin;
  final int? walletNumber;
  final String? qrCode;
  final List<PreviewDatum>? previewData;

  const User({
    this.picture,
    this.name,
    this.shortName,
    this.verified,
    this.lastLogin,
    this.walletNumber,
    this.qrCode,
    this.previewData,
  });

  factory User.fromMap(Map<String, dynamic> data) => User(
        picture: data['picture'] as String?,
        name: data['name'] as String?,
        shortName: data['shortName'] as String?,
        verified: data['verified'] as String?,
        lastLogin: data['lastLogin'] as String?,
        walletNumber: data['walletNumber'] as int?,
        qrCode: data['qrCode'] as String?,
        previewData: (data['previewData'] as List<dynamic>?)
            ?.map((e) => PreviewDatum.fromMap(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toMap() => {
        'picture': picture,
        'name': name,
        'shortName': shortName,
        'verified': verified,
        'lastLogin': lastLogin,
        'walletNumber': walletNumber,
        'qrCode': qrCode,
        'previewData': previewData?.map((e) => e.toMap()).toList(),
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [User].
  factory User.fromJson(String data) {
    return User.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [User] to a JSON string.
  String toJson() => json.encode(toMap());

  User copyWith({
    String? picture,
    String? name,
    String? shortName,
    String? verified,
    String? lastLogin,
    int? walletNumber,
    String? qrCode,
    List<PreviewDatum>? previewData,
  }) {
    return User(
      picture: picture ?? this.picture,
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      verified: verified ?? this.verified,
      lastLogin: lastLogin ?? this.lastLogin,
      walletNumber: walletNumber ?? this.walletNumber,
      qrCode: qrCode ?? this.qrCode,
      previewData: previewData ?? this.previewData,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props {
    return [
      picture,
      name,
      verified,
      lastLogin,
      walletNumber,
      qrCode,
      previewData,
    ];
  }
}