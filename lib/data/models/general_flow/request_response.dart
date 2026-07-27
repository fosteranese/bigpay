import 'package:equatable/equatable.dart';

import 'package:bigpay/data/models/general_flow/form_verification_response.dart';

/// Result of `{activityType}/processRequest` — the transaction outcome the
/// receipt screen renders.
class RequestResponse extends Equatable {
  const RequestResponse({
    this.receiptId,
    this.reference,
    this.amount,
    this.status,
    this.statusLabel,
    this.formName,
    this.activityName,
    this.comment,
    this.receiptDate,
    this.receiptDateTime,
    this.previewData = const [],
  });

  final String? receiptId;
  final String? reference;
  final String? amount;
  final int? status;
  final String? statusLabel;
  final String? formName;
  final String? activityName;
  final String? comment;
  final String? receiptDate;
  final String? receiptDateTime;
  final List<PreviewData> previewData;

  factory RequestResponse.fromMap(Map<String, dynamic> data) {
    return RequestResponse(
      receiptId: data['receiptId'] as String?,
      reference: data['reference'] as String?,
      amount: data['amount'] as String?,
      status: data['status'] as int?,
      statusLabel: data['statusLabel'] as String?,
      formName: data['formName'] as String?,
      activityName: data['activityName'] as String?,
      comment: data['comment'] as String?,
      receiptDate: data['receiptDate'] as String?,
      receiptDateTime: data['receiptDateTime'] as String?,
      previewData: data['previewData'] is List
          ? (data['previewData'] as List)
                .whereType<Map<String, dynamic>>()
                .map(PreviewData.fromMap)
                .toList()
          : const [],
    );
  }

  @override
  List<Object?> get props => [
    receiptId,
    reference,
    amount,
    status,
    statusLabel,
    formName,
    activityName,
    comment,
    receiptDate,
    receiptDateTime,
    previewData,
  ];
}
