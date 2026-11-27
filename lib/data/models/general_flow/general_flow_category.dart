import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'category.dart';
import 'general_flow_form.dart';

class GeneralFlowCategory extends Equatable {
  final Category? category;
  final List<GeneralFlowForm>? forms;

  const GeneralFlowCategory({this.category, this.forms});

  factory GeneralFlowCategory.fromMap(Map<String, dynamic> data) {
    return GeneralFlowCategory(
      category: data['category'] == null
          ? null
          : Category.fromMap(data['category'] as Map<String, dynamic>),
      forms: (data['forms'] as List<dynamic>?)
          ?.map((e) => GeneralFlowForm.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() => {
        'category': category?.toMap(),
        'forms': forms?.map((e) => e.toMap()).toList(),
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [GeneralFlowCategory].
  factory GeneralFlowCategory.fromJson(String data) {
    return GeneralFlowCategory.fromMap(
        json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [GeneralFlowCategory] to a JSON string.
  String toJson() => json.encode(toMap());

  GeneralFlowCategory copyWith({
    Category? category,
    List<GeneralFlowForm>? forms,
  }) {
    return GeneralFlowCategory(
      category: category ?? this.category,
      forms: forms ?? this.forms,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [category, forms];
}