import 'dart:convert';

import 'package:equatable/equatable.dart';

class Lov extends Equatable {
  final String? lovTitle;
  final String? lovValue;

  /// Optional icon/logo for the option (e.g. a bank or network logo). A full
  /// URL is used as-is; a relative path is prefixed with the image base URL.
  final String? icon;

  const Lov({this.lovTitle, this.lovValue, this.icon});

  factory Lov.fromMap(Map<String, dynamic> data) => Lov(
    lovTitle: data['lovTitle'] as String?,
    lovValue: data['lovValue'] as String?,
    icon: (data['lovIcon'] ?? data['icon'] ?? data['image']) as String?,
  );

  Map<String, dynamic> toMap() => {
    'lovTitle': lovTitle,
    'lovValue': lovValue,
    'icon': icon,
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
    String? icon,
  }) {
    return Lov(
      lovTitle: lovTitle ?? this.lovTitle,
      lovValue: lovValue ?? this.lovValue,
      icon: icon ?? this.icon,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [lovTitle, lovValue, icon];
}
