import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'transaction.dart';

class MiniStatement extends Equatable {
  final String? accountTitle;
  final String? accountNumber;
  final String? accountType;
  final String? currency;
  final String? balance;
  final List<Transaction>? transactions;

  const MiniStatement({
    this.accountTitle,
    this.accountNumber,
    this.accountType,
    this.currency,
    this.balance,
    this.transactions,
  });

  factory MiniStatement.fromMap(Map<String, dynamic> data) => MiniStatement(
        accountTitle: data['accountTitle'] as String?,
        accountNumber: data['accountNumber'] as String?,
        accountType: data['accountType'] as String?,
        currency: data['currency'] as String?,
        balance: data['balance'] as String?,
        transactions: (data['transactions'] as List<dynamic>?)
            ?.map((e) => Transaction.fromMap(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toMap() => {
        'accountTitle': accountTitle,
        'accountNumber': accountNumber,
        'accountType': accountType,
        'currency': currency,
        'balance': balance,
        'transactions': transactions?.map((e) => e.toMap()).toList(),
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [MiniStatement].
  factory MiniStatement.fromJson(String data) {
    return MiniStatement.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [MiniStatement] to a JSON string.
  String toJson() => json.encode(toMap());

  MiniStatement copyWith({
    String? accountTitle,
    String? accountNumber,
    String? accountType,
    String? currency,
    String? balance,
    List<Transaction>? transactions,
  }) {
    return MiniStatement(
      accountTitle: accountTitle ?? this.accountTitle,
      accountNumber: accountNumber ?? this.accountNumber,
      accountType: accountType ?? this.accountType,
      currency: currency ?? this.currency,
      balance: balance ?? this.balance,
      transactions: transactions ?? this.transactions,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props {
    return [
      accountTitle,
      accountNumber,
      accountType,
      currency,
      balance,
      transactions,
    ];
  }
}