import 'dart:convert';

import 'package:equatable/equatable.dart';

class Transaction extends Equatable {
  final String? postDate;
  final String? valueDate;
  final String? transactionType;
  final String? amount;
  final String? balance;
  final String? debitCreditFlag;
  final String? narration;
  final String? reference;

  const Transaction({
    this.postDate,
    this.valueDate,
    this.transactionType,
    this.amount,
    this.balance,
    this.debitCreditFlag,
    this.narration,
    this.reference,
  });

  factory Transaction.fromMap(Map<String, dynamic> data) => Transaction(
        postDate: data['postDate'] as String?,
        valueDate: data['valueDate'] as String?,
        transactionType: data['transactionType'] as String?,
        amount: data['amount'] as String?,
        balance: data['balance'] as String?,
        debitCreditFlag: data['debitCreditFlag'] as String?,
        narration: data['narration'] as String?,
        reference: data['reference'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'postDate': postDate,
        'valueDate': valueDate,
        'transactionType': transactionType,
        'amount': amount,
        'balance': balance,
        'debitCreditFlag': debitCreditFlag,
        'narration': narration,
        'reference': reference,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Transaction].
  factory Transaction.fromJson(String data) {
    return Transaction.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Transaction] to a JSON string.
  String toJson() => json.encode(toMap());

  Transaction copyWith({
    String? postDate,
    String? valueDate,
    String? transactionType,
    String? amount,
    String? balance,
    String? debitCreditFlag,
    String? narration,
    String? reference,
  }) {
    return Transaction(
      postDate: postDate ?? this.postDate,
      valueDate: valueDate ?? this.valueDate,
      transactionType: transactionType ?? this.transactionType,
      amount: amount ?? this.amount,
      balance: balance ?? this.balance,
      debitCreditFlag: debitCreditFlag ?? this.debitCreditFlag,
      narration: narration ?? this.narration,
      reference: reference ?? this.reference,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props {
    return [
      postDate,
      valueDate,
      transactionType,
      amount,
      balance,
      debitCreditFlag,
      narration,
      reference,
    ];
  }
}