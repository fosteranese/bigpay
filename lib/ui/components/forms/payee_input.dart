import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/data/models/payee/payee.dart';
import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/models/actions/services/get_form_payees_action.dart';
import 'package:bigpay/ui/components/forms/input.dart';
import 'package:bigpay/ui/components/process_builder.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/ui/theme/responsive.dart';

/// A form field backed by the saved payees for [formId].
///
/// The list is fetched (cache-then-refresh, so a repeat open of the same
/// field is instant and works offline) as soon as this widget mounts rather
/// than on tap. The field itself stays a normal, typeable [FormInput] — a
/// payee number can always be entered directly; a suffix button opens a
/// searchable picker over the fetched list once it's in, or retries the
/// fetch if it hasn't landed yet. Selecting a payee writes its `value` into
/// [controller] and hands the whole [Payee] to [onSelected] (so the parent
/// form can prefill its other fields from `payee.formData`).
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
    this.next,
    this.onChanged,
    this.validator,
    this.onSelected,
  });

  final TextEditingController controller;
  final String formId;
  final String? label;
  final String? placeholder;
  final FocusNode? focusNode;
  final bool readOnly;
  final TextInputType? keyboardType;
  final void Function(String value)? next;
  final void Function(String value)? onChanged;
  final String? Function(String? value)? validator;
  final void Function(Payee payee)? onSelected;

  @override
  State<FormPayeeInput> createState() => _FormPayeeInputState();
}

class _FormPayeeInputState extends State<FormPayeeInput> {
  ExecuteProcessEvent? _event;

  @override
  void initState() {
    super.initState();
    if (!widget.readOnly) _fetch();
  }

  void _fetch() {
    _event = context.dispatchProcess(
      saveActionResponse: true,
      returnSavedResponse: true,
      GetFormPayeesAction(
        payload: GetFormPayeesActionPayload(formId: widget.formId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.readOnly) {
      return FormInput(
        readOnly: true,
        label: widget.label,
        placeholder: widget.placeholder,
        controller: widget.controller,
        focusNode: widget.focusNode,
        keyboardType: widget.keyboardType,
      );
    }

    return ProcessBuilder<List<Payee>>(
      event: () => _event,
      builder: (context, snapshot) {
        return FormInput(
          label: widget.label,
          placeholder: widget.placeholder,
          controller: widget.controller,
          focusNode: widget.focusNode,
          keyboardType: widget.keyboardType,
          next: widget.next,
          onChanged: widget.onChanged,
          validator: widget.validator,
          suffix: _suffix(context, snapshot),
        );
      },
    );
  }

  Widget _suffix(BuildContext context, ProcessSnapshot<List<Payee>> snapshot) {
    if (snapshot.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(14),
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (!snapshot.hasData) {
      return IconButton(
        tooltip: AppLocalizations.of(context)!.commonRetry,
        onPressed: () => setState(_fetch),
        icon: const Icon(Icons.refresh_outlined),
      );
    }

    return IconButton(
      tooltip: AppLocalizations.of(context)!.commonSelect,
      onPressed: () => _openPicker(context, snapshot.data ?? const []),
      icon: const Icon(Icons.group_outlined),
    );
  }

  void _openPicker(BuildContext context, List<Payee> payees) {
    FocusScope.of(context).unfocus();
    final l10n = AppLocalizations.of(context)!;
    final cap = contentCapWidth(context);
    final searchController = TextEditingController();
    var filtered = payees;

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      constraints: cap == double.infinity
          ? null
          : BoxConstraints(maxWidth: cap),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          void onSearch(String query) {
            final q = query.trim().toLowerCase();
            setSheetState(() {
              filtered = q.isEmpty
                  ? payees
                  : payees
                        .where(
                          (p) =>
                              p.displayName.toLowerCase().contains(q) ||
                              (p.value ?? '').toLowerCase().contains(q),
                        )
                        .toList();
            });
          }

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: sheetContext.cardBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              expand: false,
              builder: (_, scrollController) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${l10n.commonSelect} ${widget.label ?? l10n.payeeRecipientFallback}',
                          style: sheetContext.header1,
                        ),
                        IconButton.filled(
                          tooltip: l10n.commonClose,
                          style: IconButton.styleFrom(
                            alignment: Alignment.center,
                            backgroundColor: sheetContext.divider,
                            fixedSize: const Size(44, 44),
                          ),
                          onPressed: () => sheetContext.pop(),
                          icon: Icon(
                            Icons.close,
                            size: 17,
                            color: sheetContext.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    if (payees.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 5, bottom: 10),
                        child: SizedBox(
                          height: 48,
                          child: TextField(
                            controller: searchController,
                            decoration: InputDecoration(
                              hintText: l10n.commonSearch,
                              hintStyle: sheetContext.caption,
                              prefixIcon: const Icon(Icons.search),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: sheetContext.border,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                borderSide: BorderSide(
                                  color: AppColors.primary,
                                  style: BorderStyle.solid,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: sheetContext.divider,
                            ),
                            onChanged: onSearch,
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: payees.isEmpty
                          ? _emptyState(
                              sheetContext,
                              icon: Icons.person_outline,
                              title: l10n.payeeNoSavedRecipientsTitle,
                              message: l10n.payeeNoSavedRecipientsMessage,
                            )
                          : filtered.isEmpty
                          ? _emptyState(
                              sheetContext,
                              icon: Icons.search_off_outlined,
                              title: l10n.commonNoResultsFound,
                            )
                          : ListView.builder(
                              controller: scrollController,
                              itemCount: filtered.length,
                              itemBuilder: (_, i) => _payeeTile(
                                sheetContext,
                                filtered[i],
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _emptyState(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? message,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: context.textTertiary),
          const SizedBox(height: 12),
          Text(
            title,
            style: context.smallDetailsMedium,
            textAlign: TextAlign.center,
          ),
          if (message != null) ...[
            const SizedBox(height: 4),
            Text(
              message,
              style: context.smallDetails,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _payeeTile(BuildContext context, Payee payee) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: context.avatarBg,
          child: Icon(
            Icons.person_outline,
            color: context.textSecondary,
          ),
        ),
        title: Text(
          payee.displayName,
          style: context.header4,
        ),
        subtitle: payee.value == null
            ? null
            : Text(payee.value!, style: context.caption),
        onTap: () {
          context.pop();
          _select(payee);
        },
      ),
    );
  }

  void _select(Payee payee) {
    widget.controller.text = payee.value ?? '';
    widget.onSelected?.call(payee);
    widget.next?.call(payee.value ?? '');
  }
}
