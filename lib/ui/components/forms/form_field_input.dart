import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:bigpay/constants/field.const.dart';
import 'package:bigpay/data/models/general_flow/general_flow_fields_datum.dart';
import 'package:bigpay/data/models/payee/payee.dart';
import 'package:bigpay/ui/components/forms/date_input.dart';
import 'package:bigpay/ui/components/forms/input.dart';
import 'package:bigpay/ui/components/forms/password_input.dart';
import 'package:bigpay/ui/components/forms/payee_input.dart';
import 'package:bigpay/ui/components/forms/select_input.dart';
import 'package:bigpay/ui/components/forms/textarea_input.dart';
import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/utils/validator.util.dart';

/// Renders one general-flow form field with the input its `fieldType` /
/// `fieldDataType` calls for — the bigpay adaptation of umb's
/// `FormMultipleInputPlus`.
///
/// bigpay has no dedicated payee, phone-book, amount, or source/destination
/// account inputs, so those data types degrade to a plain text field rather
/// than pull umb's payee/schedule subsystem across. A hidden field
/// (`fieldVisible != 1`) renders nothing.
class FormFieldInput extends StatelessWidget {
  const FormFieldInput({
    super.key,
    required this.datum,
    required this.controller,
    this.focusNode,
    this.next,
    this.isLast = false,
    this.onPayeeSelected,
    this.validator,
  });

  final GeneralFlowFieldsDatum datum;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final void Function(String value)? next;
  final bool isLast;
  final void Function(Payee payee)? onPayeeSelected;
  final String? Function(String? value)? validator;

  @override
  Widget build(BuildContext context) {
    final field = datum.field;
    if (field?.fieldVisible != 1) return const SizedBox.shrink();

    final label = field?.fieldCaption ?? '';
    final placeholder = field?.toolTip;
    final readOnly = field?.readOnly == 1;
    final maxLength = field?.fieldLength;

    switch (field?.fieldType) {
      case FieldTypesConst.listOfValues:
      case FieldTypesConst.multiSelect:
        return FormSelectInput(
          label: label,
          placeholder: placeholder,
          controller: controller,
          focusNode: focusNode,
          options: (datum.lov ?? [])
              .map(
                (l) => FormSelectOption(
                  id: l.lovValue ?? '',
                  label: l.lovTitle ?? '',
                ),
              )
              .toList(),
        );

      case FieldTypesConst.textArea:
        return FormTextAreaInput(
          label: label,
          placeholder: placeholder,
          controller: controller,
          focusNode: focusNode,
          readOnly: readOnly,
        );

      case FieldTypesConst.date:
        return FormDateInput(
          label: label,
          placeholder: placeholder,
          controller: controller,
          focusNode: focusNode,
        );

      // textBox / other / anything else: pick the input by data type.
      default:
        return _byDataType(label, placeholder, readOnly, maxLength);
    }
  }

  /// Builds a [validator] closure from the field's metadata. Returns `null`
  /// when no validation applies (non-mandatory or non-applicable data type).
  static String? Function(String?)? buildValidator(
    GeneralFlowFieldsDatum datum,
    AppLocalizations l10n,
  ) {
    final field = datum.field;
    if (field == null) return null;

    final mandatory = field.fieldMandatory == 1;
    final dataType = field.fieldDataType;
    final maxLength = field.fieldLength;

    if (!mandatory && maxLength == null && dataType == null) return null;

    return (String? value) {
      if (mandatory && (value == null || value.trim().isEmpty)) {
        return l10n.validationFieldRequired;
      }
      if (value == null || value.trim().isEmpty) return null;

      if (dataType == FieldDataTypesConst.emailAddress) {
        if (!Validator.email(value.trim())) {
          return l10n.validationEmailInvalid;
        }
      }

      if (maxLength != null && value.trim().length > maxLength) {
        return l10n.validationFieldRequired;
      }

      return null;
    };
  }

  Widget _byDataType(
    String label,
    String? placeholder,
    bool readOnly,
    int? maxLength,
  ) {
    Widget text({TextInputType? keyboardType, List<TextInputFormatter>? formatters}) {
      return FormInput(
        label: label,
        placeholder: placeholder,
        controller: controller,
        focusNode: focusNode,
        readOnly: readOnly,
        maxLength: maxLength,
        keyboardType: keyboardType,
        inputFormatters: formatters,
        textInputAction: isLast ? TextInputAction.done : TextInputAction.next,
        next: next,
        validator: validator,
      );
    }

    Widget password() {
      return FormPasswordInput(
        label: label,
        placeholder: placeholder,
        controller: controller,
        focusNode: focusNode,
        next: next,
        validator: validator,
      );
    }

    // A payee field picks from saved recipients when the field carries a
    // formId; without one there is nothing to fetch, so it degrades to text.
    Widget payee({TextInputType? keyboardType}) {
      final formId = datum.field?.formId;
      if (formId == null || formId.isEmpty) {
        return text(keyboardType: keyboardType);
      }
      return FormPayeeInput(
        label: label,
        placeholder: placeholder,
        controller: controller,
        focusNode: focusNode,
        readOnly: readOnly,
        keyboardType: keyboardType,
        formId: formId,
        onSelected: onPayeeSelected,
      );
    }

    Widget date({DateTime? firstDate, DateTime? lastDate}) {
      return FormDateInput(
        label: label,
        placeholder: placeholder,
        controller: controller,
        focusNode: focusNode,
        firstDate: firstDate,
        lastDate: lastDate,
      );
    }

    final now = DateTime.now();
    const decimal = TextInputType.numberWithOptions(decimal: true);
    final decimalFormatters = [
      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
    ];

    switch (datum.field?.fieldDataType) {
      case FieldDataTypesConst.date:
        return date();
      case FieldDataTypesConst.dateAfterCurrent:
        return date(firstDate: DateTime(now.year, now.month, now.day + 1));
      case FieldDataTypesConst.dateToCurrent:
        return date(lastDate: now);

      case FieldDataTypesConst.decimal:
        return text(keyboardType: decimal, formatters: decimalFormatters);
      case FieldDataTypesConst.number:
        return text(keyboardType: TextInputType.number);
      case FieldDataTypesConst.payeeNumber:
        return payee(keyboardType: TextInputType.number);

      case FieldDataTypesConst.emailAddress:
        return text(keyboardType: TextInputType.emailAddress);

      case FieldDataTypesConst.phoneBook:
        return text(keyboardType: TextInputType.phone);

      case FieldDataTypesConst.link:
        return text(keyboardType: TextInputType.url);

      case FieldDataTypesConst.password:
      case FieldDataTypesConst.newPassword:
      case FieldDataTypesConst.pin:
      case FieldDataTypesConst.newPin:
        return password();

      case FieldDataTypesConst.payee:
        return payee();

      // string, source/destination account, signature and any unmapped type
      // fall back to a plain text field — bigpay has no account picker.
      case FieldDataTypesConst.string:
      case FieldDataTypesConst.sourceAccount:
      case FieldDataTypesConst.destinationAccount:
      case FieldDataTypesConst.signature:
      default:
        return text();
    }
  }
}
