import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'payment.dart';
import 'institution.dart';

class PaymentCategories extends Equatable {
  final Payment? category;
  final List<Institution>? institution;

  const PaymentCategories({this.category, this.institution});

  factory PaymentCategories.fromMap(Map<String, dynamic> data) {
    return PaymentCategories(
      category: data['category'] == null
          ? null
          : Payment.fromMap(data['category'] as Map<String, dynamic>),
      institution: data['institution'] != null
          ? (data['institution'] as List<dynamic>?)
              ?.map((e) => Institution.fromMap(e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toMap() => {
        'category': category?.toMap(),
        'institution': institution?.map((e) => e.toMap()).toList() ?? [],
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [PaymentCategories].
  factory PaymentCategories.fromJson(String data) {
    return PaymentCategories.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [PaymentCategories] to a JSON string.
  String toJson() => json.encode(toMap());

  PaymentCategories copyWith({
    Payment? category,
    List<Institution>? institution,
  }) {
    return PaymentCategories(
      category: category ?? this.category,
      institution: institution ?? this.institution,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [
        category,
        institution,
      ];
}