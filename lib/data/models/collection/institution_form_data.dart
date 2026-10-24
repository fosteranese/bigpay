import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'institution_data.dart';
import 'source_of_payment.dart';

class InstitutionFormData extends Equatable {
  final InstitutionData? institutionData;
  final List<SourceOfPayment>? sourceOfPayment;

  const InstitutionFormData({this.institutionData, this.sourceOfPayment});

  factory InstitutionFormData.fromMap(Map<String, dynamic> data) {
    return InstitutionFormData(
      institutionData: data['institutionData'] == null
          ? null
          : InstitutionData.fromMap(
              data['institutionData'] as Map<String, dynamic>),
      sourceOfPayment: (data['sourceOfPayment'] as List<dynamic>?)
          ?.map((e) => SourceOfPayment.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() => {
        'institutionData': institutionData?.toMap(),
        'sourceOfPayment': sourceOfPayment?.map((e) => e.toMap()).toList(),
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [InstitutionFormData].
  factory InstitutionFormData.fromJson(String data) {
    return InstitutionFormData.fromMap(
        json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [InstitutionFormData] to a JSON string.
  String toJson() => json.encode(toMap());

  InstitutionFormData copyWith({
    InstitutionData? institutionData,
    List<SourceOfPayment>? sourceOfPayment,
  }) {
    return InstitutionFormData(
      institutionData: institutionData ?? this.institutionData,
      sourceOfPayment: sourceOfPayment ?? this.sourceOfPayment,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [institutionData, sourceOfPayment];
}