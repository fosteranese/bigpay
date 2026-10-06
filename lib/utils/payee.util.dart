import 'package:flutter/widgets.dart';

import 'package:bigpay/constants/field.const.dart';
import 'package:bigpay/data/models/general_flow/general_flow_fields_datum.dart';
import 'package:bigpay/data/models/payee/payee.dart';

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

/// Writes a saved payee's values into [items]' controllers so an opened form
/// starts fully pre-filled with what was saved (the "edit" half of
/// "edit & send"). The primary payee field falls back to [Payee.value] when
/// the stored form data doesn't carry it.
void prefillFromPayee(
  Payee? payee,
  List<(GeneralFlowFieldsDatum, TextEditingController, FocusNode)> items,
) {
  if (payee == null) return;
  for (final (datum, controller, _) in items) {
    final name = datum.field?.fieldName;
    final value =
        payeeSavedFieldValue(payee, name) ??
        ((payee.value != null && _isPayeeField(datum)) ? payee.value : null);
    if (value != null) controller.text = value;
  }
}
