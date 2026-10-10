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
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? email;
  final String? birthDate;
  final String? gender;
  final String? nationality;

  const User({
    this.picture,
    this.name,
    this.shortName,
    this.verified,
    this.lastLogin,
    this.walletNumber,
    this.qrCode,
    this.previewData,
    this.firstName,
    this.middleName,
    this.lastName,
    this.email,
    this.birthDate,
    this.gender,
    this.nationality,
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
    firstName: data['firstName'] as String?,
    middleName: data['middleName'] as String?,
    lastName: data['lastName'] as String?,
    email: data['email'] as String?,
    birthDate: data['birthDate'] as String?,
    gender: data['gender'] as String?,
    nationality: data['nationality'] as String?,
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
    'firstName': firstName,
    'middleName': middleName,
    'lastName': lastName,
    'email': email,
    'birthDate': birthDate,
    'gender': gender,
    'nationality': nationality,
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
    String? firstName,
    String? middleName,
    String? lastName,
    String? email,
    String? birthDate,
    String? gender,
    String? nationality,
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
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      nationality: nationality ?? this.nationality,
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
      firstName,
      middleName,
      lastName,
      email,
      birthDate,
      gender,
      nationality,
    ];
  }
}
