import 'dart:convert';
import 'package:equatable/equatable.dart';

import 'package:bigpay/data/models/response/response.md.dart';

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
  final String Function()? endpointFunc;
  final T1 Function(dynamic response)? responseDataFunc;
  final DataResponse<T1> Function(dynamic response)? noRemoteFunc;
  final bool isAuthenticated;

  const Action({
    required this.endpoint,
    required this.payload,
    this.endpointFunc,
    this.responseDataFunc,
    this.noRemoteFunc,
    this.isAuthenticated = true,
  });

  Map<String, dynamic> toJson() => payload.toJson();
  String encode() => payload.toJsonString();

  /// A copy of this action with individual fields replaced.
  ///
  /// Chiefly for swapping in a different [payload] — e.g. re-running an action
  /// with an earlier, saved input. [Action] is abstract, so the copy is a
  /// concrete carrier of the same three fields the request path reads
  /// (endpoint, payload, responseDataFunc); it is not the original subclass.
  Action<T, T1> copyWith({
    String? endpoint,
    T? payload,
    T1 Function(dynamic data)? responseDataFunc,
    String Function()? endpointFunc,
    DataResponse<T1> Function(dynamic response)? noRemoteFunc,
    bool? isAuthenticated,
  }) => _ActionCopy<T, T1>(
    endpoint: endpoint ?? this.endpoint,
    payload: payload ?? this.payload,
    endpointFunc: endpointFunc ?? this.endpointFunc,
    responseDataFunc: responseDataFunc ?? this.responseDataFunc,
    noRemoteFunc: noRemoteFunc ?? this.noRemoteFunc,
    isAuthenticated: isAuthenticated ?? this.isAuthenticated,
  );

  @override
  List<Object?> get props => [
    endpoint,
    payload,
    endpointFunc,
    responseDataFunc,
    noRemoteFunc,
    isAuthenticated,
  ];
}

/// Concrete [Action] produced by [Action.copyWith]. Private — callers only ever
/// see it as an [Action].
final class _ActionCopy<T extends ActionPayloadSerializable, T1>
    extends Action<T, T1> {
  const _ActionCopy({
    required super.endpoint,
    required super.payload,
    super.endpointFunc,
    super.responseDataFunc,
    super.noRemoteFunc,
    super.isAuthenticated,
  });
}

/// Payload for actions that send no body.
final class NoPayload implements ActionPayloadSerializable {
  const NoPayload();

  @override
  Map<String, dynamic> toJson() => const {};
}
