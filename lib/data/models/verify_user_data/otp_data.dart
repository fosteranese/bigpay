import 'dart:convert';

import 'package:equatable/equatable.dart';

class OtpData extends Equatable {
  final String? otpId;
  final String? message;
  final String? title;
  final String? expiryDate;
  final int? length;

  const OtpData({
    this.otpId,
    this.message,
    this.title,
    this.expiryDate,
    this.length,
  });

  factory OtpData.fromMap(Map<String, dynamic> data) => OtpData(
    otpId: data['otpId'] as String?,
    message: data['message'] as String?,
    title: data['title'] as String?,
    expiryDate: data['expiryDate'] as String?,
    length: data['length'] as int?,
  );

  Map<String, dynamic> toMap() => {
    'otpId': otpId,
    'message': message,
    'title': title,
    'expiryDate': expiryDate,
    'length': length,
  };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [OtpData].
  factory OtpData.fromJson(String data) {
    return OtpData.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [OtpData] to a JSON string.
  String toJson() => json.encode(toMap());

  OtpData copyWith({
    String? otpId,
    String? message,
    String? title,
    String? expiryDate,
    int? length,
  }) {
    return OtpData(
      otpId: otpId ?? this.otpId,
      message: message ?? this.message,
      title: title ?? this.title,
      expiryDate: expiryDate ?? this.expiryDate,
      length: length ?? this.length,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [otpId, message, title, expiryDate, length];
}
