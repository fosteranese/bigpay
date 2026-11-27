import 'package:bigpay/constants/field.const.dart';
import 'package:bigpay/data/models/general_flow/general_flow_fields_datum.dart';

class TransactionValidation {
  TransactionValidation._();

  /// True when the account to debit (the synthesized `SourceAccount` field)
  /// equals the account to credit — the field tagged
  /// [FieldDataTypesConst.destinationAccount] (e.g. a wallet top-up's "Wallet
  /// Number"). You can't move money from an account into itself, so a submit
  /// carrying both the same is rejected before it leaves the device.
  static bool debitEqualsCredit(
    List<GeneralFlowFieldsDatum> fields,
    Map<String, dynamic> payload,
  ) {
    final source = (payload['SourceAccount'] ?? payload['sourceAccount'] ?? '')
        .toString()
        .trim();
    if (source.isEmpty) return false;

    for (final datum in fields) {
      if (datum.field?.fieldDataType !=
          FieldDataTypesConst.destinationAccount) {
        continue;
      }
      final credit = (payload[datum.field?.fieldName] ?? '').toString().trim();
      if (credit.isNotEmpty && credit == source) return true;
    }
    return false;
  }
}
