import 'dart:convert';

import 'package:equatable/equatable.dart';

enum UserType {
  customer,
  nonCustomer,
}

class UserResponse extends Equatable {
  final UserType? userType;
  final String? sessionId;
  final String? imageBaseUrl;
  final String? imageDirectory;
  final String? profilePicture;

  const UserResponse({
    this.userType,
    this.sessionId,
    this.imageBaseUrl,
    this.imageDirectory,
    this.profilePicture,
  });

  factory UserResponse.fromMap(Map<String, dynamic> data) => UserResponse(
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
  /// Parses the string and returns the resulting Json object as [UserResponse].
  factory UserResponse.fromJson(String data) {
    return UserResponse.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [UserResponse] to a JSON string.
  String toJson() => json.encode(toMap());

  UserResponse copyWith({
    UserType? userType,
    String? sessionId,
    String? imageBaseUrl,
    String? imageDirectory,
    String? profilePicture,
  }) {
    return UserResponse(
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
