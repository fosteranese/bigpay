import 'dart:convert';

import 'package:equatable/equatable.dart';

class CustomerDatum extends Equatable {
  final String? currency;
  final String? branchCode;
  final String? customerNumber;
  final String? accountNumber;
  final String? title;
  final String? status;
  final String? accountClass;
  final dynamic email;
  final dynamic phoneNumber;
  final double? availableBalance;
  final double? currenntBalance;
  final String? formatedAccountNumber;
  final String? statusLabel;
  final String? formatedAvailableBalance;
  final String? description;
  final String? accountId;

  const CustomerDatum({
    this.currency,
    this.branchCode,
    this.customerNumber,
    this.accountNumber,
    this.title,
    this.status,
    this.accountClass,
    this.email,
    this.phoneNumber,
    this.availableBalance,
    this.currenntBalance,
    this.formatedAccountNumber,
    this.statusLabel,
    this.formatedAvailableBalance,
    this.description,
    this.accountId,
  });

  factory CustomerDatum.fromMap(Map<String, dynamic> data) => CustomerDatum(
        currency: data['currency'] as String?,
        branchCode: data['branchCode'] as String?,
        customerNumber: data['customerNumber'] as String?,
        accountNumber: data['accountNumber'] as String?,
        title: data['title'] as String?,
        status: data['status'] as String?,
        accountClass: data['accountClass'] as String?,
        email: data['email'] as dynamic,
        phoneNumber: data['phoneNumber'] as dynamic,
        availableBalance: data['availableBalance'] as double?,
        currenntBalance: data['currenntBalance'] as double?,
        formatedAccountNumber: data['formatedAccountNumber'] as String?,
        statusLabel: data['statusLabel'] as String?,
        formatedAvailableBalance: data['formatedAvailableBalance'] as String?,
        description: data['description'] as String?,
        accountId: data['accountId'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'currency': currency,
        'branchCode': branchCode,
        'customerNumber': customerNumber,
        'accountNumber': accountNumber,
        'title': title,
        'status': status,
        'accountClass': accountClass,
        'email': email,
        'phoneNumber': phoneNumber,
        'availableBalance': availableBalance,
        'currenntBalance': currenntBalance,
        'formatedAccountNumber': formatedAccountNumber,
        'statusLabel': statusLabel,
        'formatedAvailableBalance': formatedAvailableBalance,
        'description': description,
        'accountId': accountId,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [CustomerDatum].
  factory CustomerDatum.fromJson(String data) {
    return CustomerDatum.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [CustomerDatum] to a JSON string.
  String toJson() => json.encode(toMap());

  CustomerDatum copyWith({
    String? currency,
    String? branchCode,
    String? customerNumber,
    String? accountNumber,
    String? title,
    String? status,
    String? accountClass,
    dynamic email,
    dynamic phoneNumber,
    double? availableBalance,
    double? currenntBalance,
    String? formatedAccountNumber,
    String? statusLabel,
    String? formatedAvailableBalance,
    String? description,
    String? accountId,
  }) {
    return CustomerDatum(
      currency: currency ?? this.currency,
      branchCode: branchCode ?? this.branchCode,
      customerNumber: customerNumber ?? this.customerNumber,
      accountNumber: accountNumber ?? this.accountNumber,
      title: title ?? this.title,
      status: status ?? this.status,
      accountClass: accountClass ?? this.accountClass,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      availableBalance: availableBalance ?? this.availableBalance,
      currenntBalance: currenntBalance ?? this.currenntBalance,
      formatedAccountNumber:
          formatedAccountNumber ?? this.formatedAccountNumber,
      statusLabel: statusLabel ?? this.statusLabel,
      formatedAvailableBalance:
          formatedAvailableBalance ?? this.formatedAvailableBalance,
      description: description ?? this.description,
      accountId: accountId ?? this.accountId,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props {
    return [
      currency,
      branchCode,
      customerNumber,
      accountNumber,
      title,
      status,
      accountClass,
      email,
      phoneNumber,
      availableBalance,
      currenntBalance,
      formatedAccountNumber,
      statusLabel,
      formatedAvailableBalance,
      description,
      accountId,
    ];
  }
}