import 'package:bigpay/models/actions/action.dart';

/// Saves a completed transaction's counterparty as a beneficiary, posting to
/// the receipt's own `beneficiaryEndpoint` (see [RequestResponse]) — the
/// backend already knows which form this came from and resolves the actual
/// beneficiary name/account/phone server-side from [receiptId] alone.
final class SaveBeneficiaryAction extends Action<SaveBeneficiaryActionPayload, bool> {
  const SaveBeneficiaryAction({
    required super.endpoint,
    required super.payload,
  }) : super(responseDataFunc: _responseDataFunc);

  static bool _responseDataFunc(dynamic data) => true;
}

final class SaveBeneficiaryActionPayload implements ActionPayloadSerializable {
  const SaveBeneficiaryActionPayload({required this.receiptId});

  final String? receiptId;

  @override
  Map<String, dynamic> toJson() => {'receiptId': receiptId};
}
