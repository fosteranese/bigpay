import 'package:bigpay/data/models/account/mini_statement.dart';
import 'package:bigpay/models/actions/action.dart';

final class GetWalletTransactionsAction
    extends Action<MiniStatementPayload, MiniStatement> {
  static const path = '/MyAccount/miniStatement';

  const GetWalletTransactionsAction({
    required super.payload,
  }) : super(
          endpoint: path,
          responseDataFunc: _responseDataFunc,
        );

  static MiniStatement _responseDataFunc(dynamic data) {
    return MiniStatement.fromMap(data as Map<String, dynamic>);
  }
}

final class MiniStatementPayload implements ActionPayloadSerializable {
  final String sourceValue;
  final String? startDate;
  final String? endDate;

  const MiniStatementPayload({
    required this.sourceValue,
    this.startDate,
    this.endDate,
  });

  @override
  Map<String, dynamic> toJson() => {
        'sourceValue': sourceValue,
        'startDate': startDate,
        'endDate': endDate,
      };
}
