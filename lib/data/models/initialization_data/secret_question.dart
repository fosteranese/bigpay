import 'dart:convert';

import 'package:equatable/equatable.dart';

class SecretQuestion extends Equatable {
  final String? questionId;
  final String? title;
  final int? status;
  final String? statusLabel;
  final String? dateCreated;
  final dynamic createdBy;

  const SecretQuestion({
    this.questionId,
    this.title,
    this.status,
    this.statusLabel,
    this.dateCreated,
    this.createdBy,
  });

  factory SecretQuestion.fromMap(Map<String, dynamic> data) {
    return SecretQuestion(
      questionId: data['questionId'] as String?,
      title: data['title'] as String?,
      status: data['status'] as int?,
      statusLabel: data['statusLabel'] as String?,
      dateCreated: data['dateCreated'] as String?,
      createdBy: data['createdBy'] as dynamic,
    );
  }

  Map<String, dynamic> toMap() => {
    'questionId': questionId,
    'title': title,
    'status': status,
    'statusLabel': statusLabel,
    'dateCreated': dateCreated,
    'createdBy': createdBy,
  };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [SecretQuestion].
  factory SecretQuestion.fromJson(String data) {
    return SecretQuestion.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [SecretQuestion] to a JSON string.
  String toJson() => json.encode(toMap());

  SecretQuestion copyWith({
    String? questionId,
    String? title,
    int? status,
    String? statusLabel,
    String? dateCreated,
    dynamic createdBy,
  }) {
    return SecretQuestion(
      questionId: questionId ?? this.questionId,
      title: title ?? this.title,
      status: status ?? this.status,
      statusLabel: statusLabel ?? this.statusLabel,
      dateCreated: dateCreated ?? this.dateCreated,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props {
    return [
      questionId,
      title,
      status,
      statusLabel,
      dateCreated,
      createdBy,
    ];
  }
}
