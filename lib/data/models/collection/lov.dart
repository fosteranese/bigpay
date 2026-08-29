import 'dart:convert';

import 'package:equatable/equatable.dart';

class Lov extends Equatable {
  final String? lovTitle;
  final String? lovValue;

  const Lov({this.lovTitle, this.lovValue});

  factory Lov.fromMap(Map<String, dynamic> data) => Lov(
        lovTitle: data['lovTitle'] as String?,
        lovValue: data['lovValue'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'lovTitle': lovTitle,
        'lovValue': lovValue,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Lov].
  factory Lov.fromJson(String data) {
    return Lov.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Lov] to a JSON string.
  String toJson() => json.encode(toMap());

  Lov copyWith({
    String? lovTitle,
    String? lovValue,
  }) {
    return Lov(
      lovTitle: lovTitle ?? this.lovTitle,
      lovValue: lovValue ?? this.lovValue,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [lovTitle, lovValue];
}