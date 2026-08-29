import 'dart:convert';

import 'package:equatable/equatable.dart';

class Source extends Equatable {
  final String? value;
  final String? tile;
  final String? picture;
  final String? mode;
  final String? status;
  final String? accountNumber;
  final String? balance;

  const Source({
    this.value,
    this.tile,
    this.picture,
    this.mode,
    this.status,
    this.accountNumber,
    this.balance,
  });

  factory Source.fromMap(Map<String, dynamic> data) => Source(
        value: data['value'] as String?,
        tile: data['tile'] as String?,
        picture: data['picture'] as String?,
        mode: data['mode'] as String?,
        status: data['status'] as String?,
        accountNumber: data['accountNumber'] as String?,
        balance: data['balance'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'value': value,
        'tile': tile,
        'picture': picture,
        'mode': mode,
        'status': status,
        'accountNumber': accountNumber,
        'balance': balance,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Source].
  factory Source.fromJson(String data) {
    return Source.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Source] to a JSON string.
  String toJson() => json.encode(toMap());

  Source copyWith({
    String? value,
    String? tile,
    String? picture,
    String? mode,
    String? status,
    String? accountNumber,
    String? balance,
  }) {
    return Source(
      value: value ?? this.value,
      tile: tile ?? this.tile,
      picture: picture ?? this.picture,
      mode: mode ?? this.mode,
      status: status ?? this.status,
      accountNumber: accountNumber ?? this.accountNumber,
      balance: balance ?? this.balance,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props {
    return [
      value,
      tile,
      picture,
      mode,
      status,
      accountNumber,
      balance,
    ];
  }
}