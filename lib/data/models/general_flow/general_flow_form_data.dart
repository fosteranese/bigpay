import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:bigpay/data/models/collection/institution.dart';

import 'general_flow_fields_datum.dart';
import 'general_flow_form.dart';

class GeneralFlowFormData extends Equatable {
  final GeneralFlowForm? form;
  final List<GeneralFlowFieldsDatum>? fieldsDatum;
  final List<Map<String, dynamic>>? authMode;
  final Institution? institution;

  const GeneralFlowFormData({
    this.form,
    this.fieldsDatum,
    this.authMode,
    this.institution,
  });

  factory GeneralFlowFormData.fromMap(
    Map<String, dynamic> data,
  ) {
    return GeneralFlowFormData(
      form: data['form'] == null
          ? null
          : GeneralFlowForm.fromMap(
              data['form'] as Map<String, dynamic>,
            ),
      fieldsDatum: (data['fields'] as List<dynamic>?)
          ?.map(
            (e) => GeneralFlowFieldsDatum.fromMap(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
      authMode: (data['authMode'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
    );
  }

  Map<String, dynamic> toMap() => {
    'form': form?.toMap(),
    'fields': fieldsDatum?.map((e) => e.toMap()).toList(),
    'authMode': authMode,
  };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [GeneralFlowFormData].
  factory GeneralFlowFormData.fromJson(String data) {
    return GeneralFlowFormData.fromMap(
      json.decode(data) as Map<String, dynamic>,
    );
  }

  /// `dart:convert`
  ///
  /// Converts [GeneralFlowFormData] to a JSON string.
  String toJson() => json.encode(toMap());

  GeneralFlowFormData copyWith({
    GeneralFlowForm? form,
    List<GeneralFlowFieldsDatum>? fieldsDatum,
    List<Map<String, dynamic>>? authMode,
  }) {
    return GeneralFlowFormData(
      form: form ?? this.form,
      fieldsDatum: fieldsDatum ?? this.fieldsDatum,
      authMode: authMode ?? this.authMode,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [form, fieldsDatum, authMode];
}
