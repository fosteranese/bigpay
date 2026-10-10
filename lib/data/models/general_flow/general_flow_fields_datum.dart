import 'dart:convert';

import 'package:equatable/equatable.dart';

import '../collection/lov.dart';
import 'general_flow_field.dart';

class GeneralFlowFieldsDatum extends Equatable {
  final List<Lov>? lov;
  final GeneralFlowField? field;

  const GeneralFlowFieldsDatum({this.lov, this.field});

  factory GeneralFlowFieldsDatum.fromMap(Map<String, dynamic> data) => GeneralFlowFieldsDatum(
        lov: data['lov'] != null ? (data['lov'] as List<dynamic>?)?.map((e) => Lov.fromMap(e as Map<String, dynamic>)).toList() : [],
        field: data['field'] == null ? null : GeneralFlowField.fromMap(data['field'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toMap() => {
        'lov': lov?.map((e) => e.toMap()).toList() ?? [],
        'field': field?.toMap(),
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [GeneralFlowFieldsDatum].
  factory GeneralFlowFieldsDatum.fromJson(String data) {
    return GeneralFlowFieldsDatum.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [GeneralFlowFieldsDatum] to a JSON string.
  String toJson() => json.encode(toMap());

  GeneralFlowFieldsDatum copyWith({
    List<Lov>? lov,
    GeneralFlowField? field,
  }) {
    return GeneralFlowFieldsDatum(
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