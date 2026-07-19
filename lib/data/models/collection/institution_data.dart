import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'forms_datum.dart';
import 'institution.dart';

class InstitutionData extends Equatable {
  final Institution? institution;
  final List<FormsDatum>? formsData;

  const InstitutionData({
    this.institution,
    this.formsData,
  });

  factory InstitutionData.fromMap(Map<String, dynamic> data) {
    return InstitutionData(
      institution: data['institution'] == null
          ? null
          : Institution.fromMap(data['institution'] as Map<String, dynamic>),
      formsData: data['forms'] != null
          ? (data['forms'] as List<dynamic>?)
              ?.map((e) => FormsDatum.fromMap(e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toMap() => {
        'institution': institution?.toMap(),
        'forms': formsData?.map((e) => e.toMap()).toList() ?? [],
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [InstitutionData].
  factory InstitutionData.fromJson(String data) {
    return InstitutionData.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [InstitutionData] to a JSON string.
  String toJson() => json.encode(toMap());

  InstitutionData copyWith({
    Institution? institution,
    List<FormsDatum>? formsData,
  }) {
    return InstitutionData(
      institution: institution ?? this.institution,
      formsData: formsData ?? this.formsData,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [
        institution,
        formsData,
      ];
}