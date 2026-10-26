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
    this.activityType,
    this.comment,
    this.dateCreated,
    this.icon,
    this.receiptDate,
    this.receiptDateTime,
    this.previewData = const [],
    this.showReceipt,
    this.saveBeneficiary,
    this.allowSchedule,
    this.scheduleForm,
    this.bulkReqId,
    this.beneficiaryEndpoint,
  });

  final String? receiptId;
  final String? reference;
  final String? amount;
  final int? status;
  final String? statusLabel;
  final String? formName;
  final String? activityName;
  final String? activityType;
  final String? comment;
  final String? dateCreated;
  final String? icon;
  final String? receiptDate;
  final String? receiptDateTime;
  final List<PreviewData> previewData;

  /// 0 when the outcome isn't a transaction worth a receipt (e.g. a settings
  /// change) — a plain success screen is shown instead of the receipt.
  final int? showReceipt;

  /// Whether this receipt's counterparty can be saved as a beneficiary — the
  /// backend already knows (from the form used) whether one makes sense here,
  /// so this gates the button rather than showing it unconditionally.
  final int? saveBeneficiary;

  final int? allowSchedule;

  /// Shape not yet seen from the backend (always null so far) — kept raw.
  final Object? scheduleForm;
  final String? bulkReqId;

  /// Where to POST `{'receiptId': receiptId}` to actually save it — the
  /// backend resolves the beneficiary's own details server-side, so no
  /// name/account/phone fields are needed on this model for it.
  final String? beneficiaryEndpoint;

  factory RequestResponse.fromMap(Map<String, dynamic> data) {
    return RequestResponse(
      receiptId: data['receiptId'] as String?,
      reference: data['reference'] as String?,
      amount: data['amount'] as String?,
      status: data['status'] as int?,
      statusLabel: data['statusLabel'] as String?,
      formName: data['formName'] as String?,
      activityName: data['activityName'] as String?,
      activityType: data['activityType'] as String?,
      comment: data['comment'] as String?,
      dateCreated: data['dateCreated'] as String?,
      icon: data['icon'] as String?,
      receiptDate: data['receiptDate'] as String?,
      receiptDateTime: data['receiptDateTime'] as String?,
      previewData: data['previewData'] is List
          ? (data['previewData'] as List)
                .whereType<Map<String, dynamic>>()
                .map(PreviewData.fromMap)
                .toList()
          : const [],
      showReceipt: data['showReceipt'] as int?,
      // "saveBenficiary" — matching the backend's own field name (a typo
      // that's part of the API contract, not ours to fix on the wire).
      saveBeneficiary: data['saveBenficiary'] as int?,
      allowSchedule: data['allowSchedule'] as int?,
      scheduleForm: data['scheduleForm'],
      bulkReqId: data['bulkReqId']?.toString(),
      beneficiaryEndpoint: data['benficiaryEndpoint'] as String?,
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
    activityType,
    comment,
    dateCreated,
    icon,
    receiptDate,
    receiptDateTime,
    previewData,
    showReceipt,
    saveBeneficiary,
    allowSchedule,
    scheduleForm,
    bulkReqId,
    beneficiaryEndpoint,
  ];
}
