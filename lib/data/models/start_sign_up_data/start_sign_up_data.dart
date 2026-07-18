import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'otp_data.dart';

class StartSignUpData extends Equatable {
  final OtpData? otpData;
  final String? ghCardUrl;
  final String? registrationId;
  final dynamic resetSecurityAnswer;
  final dynamic externalUrl;
  final dynamic accessType;

  const StartSignUpData({
    this.otpData,
    this.ghCardUrl,
    this.registrationId,
    this.resetSecurityAnswer,
    this.externalUrl,
    this.accessType,
  });

  factory StartSignUpData.fromMap(Map<String, dynamic> data) {
    return StartSignUpData(
      otpData: data['otpData'] == null
          ? null
          : OtpData.fromMap(data['otpData'] as Map<String, dynamic>),
      ghCardUrl: data['ghCardUrl'] as String?,
      registrationId: data['registrationId'] as String?,
      resetSecurityAnswer: data['resetSecurityAnswer'] as dynamic,
      externalUrl: data['externalUrl'] as dynamic,
      accessType: data['accessType'] as dynamic,
    );
  }

  Map<String, dynamic> toMap() => {
    'otpData': otpData?.toMap(),
    'ghCardUrl': ghCardUrl,
    'registrationId': registrationId,
    'resetSecurityAnswer': resetSecurityAnswer,
    'externalUrl': externalUrl,
    'accessType': accessType,
  };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [StartSignUpData].
  factory StartSignUpData.fromJson(String data) {
    return StartSignUpData.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [StartSignUpData] to a JSON string.
  String toJson() => json.encode(toMap());

  StartSignUpData copyWith({
    OtpData? otpData,
    String? ghCardUrl,
    String? registrationId,
    dynamic resetSecurityAnswer,
    dynamic externalUrl,
    dynamic accessType,
  }) {
    return StartSignUpData(
      otpData: otpData ?? this.otpData,
      ghCardUrl: ghCardUrl ?? this.ghCardUrl,
      registrationId: registrationId ?? this.registrationId,
      resetSecurityAnswer: resetSecurityAnswer ?? this.resetSecurityAnswer,
      externalUrl: externalUrl ?? this.externalUrl,
      accessType: accessType ?? this.accessType,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props {
    return [
      otpData,
      ghCardUrl,
      registrationId,
      resetSecurityAnswer,
      externalUrl,
      accessType,
    ];
  }
}
