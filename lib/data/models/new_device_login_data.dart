import 'dart:convert';

import 'package:equatable/equatable.dart';

class NewDeviceLoginData extends Equatable {
  final String? requestId;
  final String? resetSecurityAnswer;

  const NewDeviceLoginData({this.requestId, this.resetSecurityAnswer});

  factory NewDeviceLoginData.fromMap(Map<String, dynamic> data) {
    return NewDeviceLoginData(
      requestId: data['requestId'] as String?,
      resetSecurityAnswer: data['resetSecurityAnswer'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'requestId': requestId,
    'resetSecurityAnswer': resetSecurityAnswer,
  };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [NewDeviceLoginData].
  factory NewDeviceLoginData.fromJson(String data) {
    return NewDeviceLoginData.fromMap(
      json.decode(data) as Map<String, dynamic>,
    );
  }

  /// `dart:convert`
  ///
  /// Converts [NewDeviceLoginData] to a JSON string.
  String toJson() => json.encode(toMap());

  NewDeviceLoginData copyWith({
    String? requestId,
    String? resetSecurityAnswer,
  }) {
    return NewDeviceLoginData(
      requestId: requestId ?? this.requestId,
      resetSecurityAnswer: resetSecurityAnswer ?? this.resetSecurityAnswer,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [requestId, resetSecurityAnswer];
}
