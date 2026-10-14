import 'dart:convert';

import 'package:equatable/equatable.dart';

class Form extends Equatable {
  final String? formId;
  final String? insId;
  final String? formName;
  final String? caption;
  final String? tooltip;
  final int? requireVerification;
  final String? verifyEndpoint;
  final String? processEndpoint;
  final String? accountNumber;
  final String? currency;
  final int? rank;
  final int? showOnline;

  const Form({
    this.formId,
    this.insId,
    this.formName,
    this.caption,
    this.tooltip,
    this.requireVerification,
    this.verifyEndpoint,
    this.processEndpoint,
    this.accountNumber,
    this.currency,
    this.rank,
    this.showOnline,
  });

  factory Form.fromMap(Map<String, dynamic> data) => Form(
        formId: data['formId'] as String?,
        insId: data['insId'] as String?,
        formName: data['formName'] as String?,
        caption: data['caption'] as String?,
        tooltip: data['tooltip'] as String?,
        requireVerification: data['requireVerification'] as int?,
        verifyEndpoint: data['verifyEndpoint'] as String?,
        processEndpoint: data['processEndpoint'] as String?,
        accountNumber: data['accountNumber'] as String?,
        currency: data['currency'] as String?,
        rank: data['rank'] as int?,
        showOnline: data['showOnline'] as int?,
      );

  Map<String, dynamic> toMap() => {
        'formId': formId,
        'insId': insId,
        'formName': formName,
        'caption': caption,
        'tooltip': tooltip,
        'requireVerification': requireVerification,
        'verifyEndpoint': verifyEndpoint,
        'processEndpoint': processEndpoint,
        'accountNumber': accountNumber,
        'currency': currency,
        'rank': rank,
        'showOnline': showOnline,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Form].
  factory Form.fromJson(String data) {
    return Form.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Form] to a JSON string.
  String toJson() => json.encode(toMap());

  Form copyWith({
    String? formId,
    String? insId,
    String? formName,
    String? caption,
    String? tooltip,
    int? requireVerification,
    String? verifyEndpoint,
    String? processEndpoint,
    String? accountNumber,
    String? currency,
    int? rank,
    int? showOnline,
  }) {
    return Form(
      formId: formId ?? this.formId,
      insId: insId ?? this.insId,
      formName: formName ?? this.formName,
      caption: caption ?? this.caption,
      tooltip: tooltip ?? this.tooltip,
      requireVerification: requireVerification ?? this.requireVerification,
      verifyEndpoint: verifyEndpoint ?? this.verifyEndpoint,
      processEndpoint: processEndpoint ?? this.processEndpoint,
      accountNumber: accountNumber ?? this.accountNumber,
      currency: currency ?? this.currency,
      rank: rank ?? this.rank,
      showOnline: showOnline ?? this.showOnline,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props {
    return [
      formId,
      insId,
      formName,
      caption,
      tooltip,
      requireVerification,
      verifyEndpoint,
      processEndpoint,
      accountNumber,
      currency,
      rank,
      showOnline,
    ];
  }
}