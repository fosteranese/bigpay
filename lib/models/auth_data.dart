import 'dart:convert';

import 'package:equatable/equatable.dart';

enum UserType {
  customer,
  nonCustomer,
}

class AuthData extends Equatable {
  final UserType? userType;
  final String? sessionId;
  final String? imageBaseUrl;
  final String? imageDirectory;
  final String? profilePicture;

  const AuthData({
    this.userType,
    this.sessionId,
    this.imageBaseUrl,
    this.imageDirectory,
    this.profilePicture,
  });

  factory AuthData.fromMap(Map<String, dynamic> data) => AuthData(
    userType: (data['userType'] as String?) == 'CUSTOMER'
        ? UserType.customer
        : UserType.nonCustomer,
    sessionId: data['sessionId'] as String?,
    imageBaseUrl: data['imageBaseUrl'] as String?,
    imageDirectory: data['imageDirectory'] as String?,
    profilePicture: data['profilePicture'] as String?,
  );

  Map<String, dynamic> toMap() => {
    'userType': userType == UserType.customer ? 'CUSTOMER' : 'NONCUSTOMER',
    'sessionId': sessionId,
    'imageBaseUrl': imageBaseUrl,
    'imageDirectory': imageDirectory,
    'profilePicture': profilePicture,
  };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [AuthData].
  factory AuthData.fromJson(String data) {
    return AuthData.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [AuthData] to a JSON string.
  String toJson() => json.encode(toMap());

  AuthData copyWith({
    UserType? userType,
    String? sessionId,
    String? imageBaseUrl,
    String? imageDirectory,
    String? profilePicture,
  }) {
    return AuthData(
      userType: userType ?? this.userType,
      sessionId: sessionId ?? this.sessionId,
      imageBaseUrl: imageBaseUrl ?? this.imageBaseUrl,
      imageDirectory: imageDirectory ?? this.imageDirectory,
      profilePicture: profilePicture ?? this.profilePicture,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props {
    return [
      userType,
      sessionId,
      imageBaseUrl,
      imageDirectory,
      profilePicture,
    ];
  }
}
