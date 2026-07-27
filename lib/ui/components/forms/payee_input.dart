import 'package:flutter/material.dart';

import 'package:bigpay/data/models/payee/payee.dart';
import 'package:bigpay/models/actions/services/get_form_payees_action.dart';
import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/ui/components/forms/input.dart';
import 'package:bigpay/ui/components/process_builder.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/utils/app_modal.dart';
import 'package:bigpay/utils/message.util.dart';

/// A form field backed by the saved payees for [formId], fetched on tap through
/// the app-wide [ProcessBloc].
///
/// Tapping it dispatches [GetFormPayeesAction]; the result opens a bottom sheet
/// to pick from. Selecting a payee writes its `value` into [controller] and
/// hands the whole [Payee] to [onSelected] (so the parent form can prefill its
/// other fields from `payee.formData`).
class FormPayeeInput extends StatefulWidget {
  const FormPayeeInput({
    super.key,
    required this.controller,
    required this.formId,
    this.label,
    this.placeholder,
    this.focusNode,
    this.readOnly = false,
    this.keyboardType,
    this.onSelected,
  });

  final TextEditingController controller;
  final String formId;
  final String? label;
  final String? placeholder;
  final FocusNode? focusNode;
  final bool readOnly;
  final TextInputType? keyboardType;
  final void Function(Payee payee)? onSelected;

  @override
  State<FormPayeeInput> createState() => _FormPayeeInputState();
}

class _FormPayeeInputState extends State<FormPayeeInput> {
  ExecuteProcessEvent? _event;

  void _openPicker() {
    if (widget.readOnly) return;
    FocusScope.of(context).unfocus();
    _event = context.dispatchProcess(
      GetFormPayeesAction(
        payload: GetFormPayeesActionPayload(formId: widget.formId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProcessListener<List<Payee>>(
      event: () => _event,
      listener: (context, snapshot) {
        if (snapshot.isLoading) {
          MessageUtil.displayLoading(context);
          return;
        } else {
          MessageUtil.close(context);
        }

        if (snapshot.hasData) {
          _event = null;
          _showPicker(context, snapshot.data ?? const []);
          return;
        }

        if (snapshot.hasError) {
          _event = null;
          MessageUtil.displayErrorDialog(
            context,
            message: snapshot.error!.message,
          );
        }
      },
      child: InkWell(
        onTap: _openPicker,
        highlightColor: Colors.transparent,
        child: AbsorbPointer(
          child: FormInput(
            readOnly: true,
            label: widget.label,
            placeholder: widget.placeholder,
            controller: widget.controller,
            focusNode: widget.focusNode,
            keyboardType: widget.keyboardType,
            suffix: const Icon(Icons.chevron_right_outlined),
          ),
        ),
      ),
    );
  }

  void _showPicker(BuildContext context, List<Payee> payees) {
    if (payees.isEmpty) {
      MessageUtil.displayErrorDialog(
        context,
        title: 'No saved recipients',
        message: 'There are no saved recipients for this service yet.',
      );
      return;
    }

    AppModal.showBottomModal(
      context,
      label: 'Select ${widget.label ?? 'recipient'}',
      children: [
        for (final payee in payees)
          ListTile(
            contentPadding: .zero,
            leading: CircleAvatar(
              backgroundColor: AppColors.tintShade3,
              child: Icon(
                Icons.person_outline,
                color: AppColors.secondary,
              ),
            ),
            title: Text(
              payee.displayName,
              style: AppTypography.header4,
            ),
            subtitle: payee.value == null
                ? null
                : Text(payee.value!, style: AppTypography.caption),
            onTap: () {
              Navigator.pop(context);
              _select(payee);
            },
          ),
      ],
    );
  }

  void _select(Payee payee) {
    widget.controller.text = payee.value ?? '';
    widget.onSelected?.call(payee);
  }
}
