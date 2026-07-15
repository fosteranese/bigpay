import 'dart:convert';
import 'package:equatable/equatable.dart';

/// Contract for action payloads.
///
/// Any `@freezed` class satisfies this automatically through its generated
/// `toJson()` — no per-payload boilerplate required.
abstract interface class ActionPayloadSerializable {
  Map<String, dynamic> toJson();
}

/// Derived encoding shared by every payload — kept off the interface so
/// implementers never have to write it.
extension ActionPayloadCodec on ActionPayloadSerializable {
  Map<String, dynamic> toMap() => toJson();
  String toJsonString() => jsonEncode(toJson());
}

abstract class Action<T extends ActionPayloadSerializable, T1>
    extends Equatable {
  final String endpoint;
  final T payload;
  final T1 Function(dynamic data)? responseDataFunc;

  const Action({
    required this.endpoint,
    required this.payload,
    this.responseDataFunc,
  });

  Map<String, dynamic> toJson() => payload.toJson();
  String encode() => payload.toJsonString();

  @override
  List<Object?> get props => [
    endpoint,
    payload,
    responseDataFunc,
  ];
}
