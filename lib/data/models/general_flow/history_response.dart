import 'package:equatable/equatable.dart';

import 'package:bigpay/data/models/auth_data/activity.dart';
import 'package:bigpay/data/models/general_flow/request_response.dart';

/// The `MyAccount/history` payload: the user's past requests plus the list of
/// activities they can be filtered by.
///
/// Each entry in [request] is a [RequestResponse] — the same receipt model
/// produced when a transaction completes — so a history row taps straight
/// through to its receipt.
class HistoryResponse extends Equatable {
  const HistoryResponse({
    this.activity,
    this.request,
    this.fblLogo,
  });

  /// Activities present in the history, used to populate the filter.
  final List<Activity>? activity;

  /// The transactions themselves, newest first as returned by the server.
  final List<RequestResponse>? request;

  final String? fblLogo;

  factory HistoryResponse.fromMap(Map<String, dynamic> data) => HistoryResponse(
    activity: (data['activity'] as List<dynamic>?)
        ?.map((e) => Activity.fromMap(e as Map<String, dynamic>))
        .toList(),
    request: (data['request'] as List<dynamic>?)
        ?.map((e) => RequestResponse.fromMap(e as Map<String, dynamic>))
        .toList(),
    fblLogo: data['fblLogo'] as String?,
  );

  HistoryResponse copyWith({
    List<Activity>? activity,
    List<RequestResponse>? request,
    String? fblLogo,
  }) {
    return HistoryResponse(
      activity: activity ?? this.activity,
      request: request ?? this.request,
      fblLogo: fblLogo ?? this.fblLogo,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [activity, request, fblLogo];
}
