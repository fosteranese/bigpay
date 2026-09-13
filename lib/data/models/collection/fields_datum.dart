import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'field.dart';
import 'lov.dart';

class FieldsDatum extends Equatable {
  final List<Lov>? lov;
  final Field? field;

  const FieldsDatum({this.lov, this.field});

  factory FieldsDatum.fromMap(Map<String, dynamic> data) => FieldsDatum(
        lov: data['lov'] != null
            ? (data['lov'] as List<dynamic>?)
                ?.map((e) => Lov.fromMap(e as Map<String, dynamic>))
                .toList()
            : [],
        field: data['field'] == null
            ? null
            : Field.fromMap(data['field'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toMap() => {
        'lov': lov?.map((e) => e.toMap()).toList() ?? [],
        'field': field?.toMap(),
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [FieldsDatum].
  factory FieldsDatum.fromJson(String data) {
    return FieldsDatum.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [FieldsDatum] to a JSON string.
  String toJson() => json.encode(toMap());

  FieldsDatum copyWith({
    List<Lov>? lov,
    Field? field,
  }) {
    return FieldsDatum(
      lov: lov ?? this.lov,
      field: field ?? this.field,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [
        lov,
        field,
      ];
}