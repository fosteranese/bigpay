import 'dart:convert';

import 'package:equatable/equatable.dart';

class PreviewDatum extends Equatable {
  final String? key;
  final String? value;
  final int? dataType;
  final bool? payeeTitle;
  final bool? payeeValue;

  const PreviewDatum({
    this.key,
    this.value,
    this.dataType,
    this.payeeTitle,
    this.payeeValue,
  });

  factory PreviewDatum.fromMap(Map<String, dynamic> data) => PreviewDatum(
        key: data['key'] as String?,
        value: data['value'] as String?,
        dataType: data['dataType'] as int?,
        payeeTitle: data['payeeTitle'] as bool?,
        payeeValue: data['payeeValue'] as bool?,
      );

  Map<String, dynamic> toMap() => {
        'key': key,
        'value': value,
        'dataType': dataType,
        'payeeTitle': payeeTitle,
        'payeeValue': payeeValue,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [PreviewDatum].
  factory PreviewDatum.fromJson(String data) {
    return PreviewDatum.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [PreviewDatum] to a JSON string.
  String toJson() => json.encode(toMap());

  PreviewDatum copyWith({
    String? key,
    String? value,
    int? dataType,
    bool? payeeTitle,
    bool? payeeValue,
  }) {
    return PreviewDatum(
      key: key ?? this.key,
      value: value ?? this.value,
      dataType: dataType ?? this.dataType,
      payeeTitle: payeeTitle ?? this.payeeTitle,
      payeeValue: payeeValue ?? this.payeeValue,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props {
    return [
      key,
      value,
      dataType,
      payeeTitle,
      payeeValue,
    ];
  }
}