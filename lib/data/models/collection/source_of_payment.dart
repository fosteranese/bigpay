import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'source.dart';

class SourceOfPayment extends Equatable {
  final String? mode;
  final String? title;
  final bool? hasMiniStatement;
  final List<Source>? sources;

  const SourceOfPayment({
    this.mode,
    this.title,
    this.hasMiniStatement,
    this.sources,
  });

  factory SourceOfPayment.fromMap(Map<String, dynamic> data) {
    return SourceOfPayment(
      mode: data['mode'] as String?,
      title: data['title'] as String?,
      hasMiniStatement: data['hasMiniStatement'] as bool?,
      sources: (data['sources'] as List<dynamic>?)
          ?.map((e) => Source.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() => {
        'mode': mode,
        'title': title,
        'hasMiniStatement': hasMiniStatement,
        'sources': sources?.map((e) => e.toMap()).toList(),
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [SourceOfPayment].
  factory SourceOfPayment.fromJson(String data) {
    return SourceOfPayment.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [SourceOfPayment] to a JSON string.
  String toJson() => json.encode(toMap());

  SourceOfPayment copyWith({
    String? mode,
    String? title,
    bool? hasMiniStatement,
    List<Source>? sources,
  }) {
    return SourceOfPayment(
      mode: mode ?? this.mode,
      title: title ?? this.title,
      hasMiniStatement: hasMiniStatement ?? this.hasMiniStatement,
      sources: sources ?? this.sources,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [mode, title, hasMiniStatement, sources];
}