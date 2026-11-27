import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'fields_datum.dart';
import 'form.dart';

class FormsDatum extends Equatable {
  final List<FieldsDatum>? fieldsData;
  final Form? form;
  final String? phoneNumber;
  final List<Map<String, dynamic>>? authMode;

  const FormsDatum({
    this.fieldsData,
    this.form,
    this.phoneNumber,
    this.authMode,
  });

  factory FormsDatum.fromMap(Map<String, dynamic> data) => FormsDatum(
        fieldsData: data['fields'] != null ? (data['fields'] as List<dynamic>?)?.map((e) => FieldsDatum.fromMap(e as Map<String, dynamic>)).toList() : [],
        form: data['form'] == null ? null : Form.fromMap(data['form'] as Map<String, dynamic>),
        phoneNumber: data['phoneNumber'] == null ? null : data['phoneNumber'] as String?,
        authMode: data['authMode'] != null ? (data['authMode'] as List<dynamic>?)?.map((e) => e as Map<String, dynamic>).toList() : [],
      );

  Map<String, dynamic> toMap() => {
        'fields': fieldsData?.map((e) => e.toMap()).toList() ?? [],
        'form': form?.toMap(),
        'phoneNumber': phoneNumber,
        'authMode': authMode,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [FormsDatum].
  factory FormsDatum.fromJson(String data) {
    return FormsDatum.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [FormsDatum] to a JSON string.
  String toJson() => json.encode(toMap());

  FormsDatum copyWith({
    List<FieldsDatum>? fieldsData,
    Form? form,
  }) {
    return FormsDatum(
      fieldsData: fieldsData ?? this.fieldsData,
      form: form ?? this.form,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [
        fieldsData,
        form,
      ];
}