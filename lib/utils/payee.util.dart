import 'package:flutter/widgets.dart';

import 'package:bigpay/constants/field.const.dart';
import 'package:bigpay/data/models/general_flow/general_flow_fields_datum.dart';
import 'package:bigpay/data/models/payee/payee.dart';
import 'package:bigpay/utils/app_state.util.dart';

/// The saved value for [fieldName] in the payee's stored form data, matched
/// case-insensitively: the form definition carries lower-camel field names
/// while some saved-payee payloads keep the original casing. `null` when the
/// payee has nothing saved for that field.
String? payeeSavedFieldValue(Payee? payee, String? fieldName) {
  if (payee == null || fieldName == null || payee.formData == null) {
    return null;
  }
  final saved = payee.formData!;
  final direct = saved[fieldName];
  if (direct != null) return direct.toString();
  final lower = fieldName.toLowerCase();
  for (final entry in saved.entries) {
    if (entry.key.toLowerCase() == lower) return entry.value?.toString();
  }
  return null;
}

/// Whether [datum] is the payee's own recipient/credit field — the one whose
/// value the backend also exposes separately as [Payee.value].
bool _isPayeeField(GeneralFlowFieldsDatum datum) {
  final dataType = datum.field?.fieldDataType;
  return dataType == FieldDataTypesConst.payeeNumber ||
      dataType == FieldDataTypesConst.payee;
}

/// Whether [value] is a masked display value (e.g. `20******05`), which the
/// backend only returns for list previews — never something to submit into a
/// field.
bool _isMasked(String value) => value.contains('*');

/// Writes a saved payee's values into [items]' controllers so an opened form
/// starts fully pre-filled with what was saved (the "edit" half of
/// "edit & send"). The primary payee field falls back to [Payee.value] when
/// the stored form data doesn't carry it — but never for a masked preview
/// value, which would otherwise be submitted as-is.
void prefillFromPayee(
  Payee? payee,
  List<(GeneralFlowFieldsDatum, TextEditingController, FocusNode)> items,
) {
  if (payee == null) return;
  for (final (datum, controller, _) in items) {
    final value = payeePrefillValue(payee, datum);
    if (value != null) controller.text = value;
  }
}

/// The value to pre-fill for [datum] from a saved payee — its formData value
/// (matched case-insensitively), falling back to [Payee.value] for the primary
/// recipient field (masked preview values are never used).
String? payeePrefillValue(Payee? payee, GeneralFlowFieldsDatum datum) {
  final name = datum.field?.fieldName;
  final value =
      payeeSavedFieldValue(payee, name) ??
      ((payee?.value != null &&
              !_isMasked(payee!.value!) &&
              _isPayeeField(datum))
          ? payee.value
          : null);
  return value;
}

/// The starting value for a form field's controller.
///
/// The form's own default wins. Otherwise, for the payment-source
/// (`SourceAccount`) field, the user's default wallet is returned — so the
/// source of funds / account to debit is already chosen when a transaction
/// starts — provided that wallet is one of the sources this form allows.
String initialFieldValue(GeneralFlowFieldsDatum datum) {
  final value = datum.field?.defaultValue ?? '';
  if (value.isNotEmpty) return value;

  final isSource =
      datum.field?.fieldDataType == FieldDataTypesConst.sourceAccount ||
      datum.field?.fieldName == 'SourceAccount';
  if (isSource) {
    final defaultSource = AppState.defaultSourceNotifier.value;
    if (defaultSource != null &&
        (datum.lov ?? const []).any((l) => l.lovValue == defaultSource)) {
      return defaultSource;
    }
  }

  return value;
}
