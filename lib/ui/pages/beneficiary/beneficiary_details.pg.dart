import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/data/models/payee/payee.dart';
import 'package:bigpay/models/actions/beneficiary/delete_payee_action.dart';
import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/confirm_sheet.dart';
import 'package:bigpay/ui/components/forms/outline_button.dart';
import 'package:bigpay/ui/components/process_builder.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/utils/message.util.dart';

/// A pushed full page wrapping [BeneficiaryDetailsView] — used on every
/// device except a foldable in book mode (or a wide screen), where
/// [BeneficiariesPage] shows the same view inline in the second pane instead
/// (see [MasterDetailLayout]).
class BeneficiaryDetailsPage extends StatelessWidget {
  const BeneficiaryDetailsPage({super.key, this.payee});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/beneficiaries/details',
    name: 'beneficiary-details',
  );

  final Payee? payee;

  @override
  Widget build(BuildContext context) {
    return BeneficiaryDetailsView(payee: payee);
  }
}

/// A saved beneficiary's details, with the option to remove it — independent
/// of how it's hosted: a pushed page ([BeneficiaryDetailsPage], default back
/// behavior) or an inline pane in [BeneficiariesPage]'s split view ([onBack]
/// provided, clears the pane's selection instead of popping a route that was
/// never pushed).
class BeneficiaryDetailsView extends StatefulWidget {
  const BeneficiaryDetailsView({super.key, this.payee, this.onBack});

  final Payee? payee;
  final VoidCallback? onBack;

  @override
  State<BeneficiaryDetailsView> createState() => _BeneficiaryDetailsViewState();
}

class _BeneficiaryDetailsViewState extends State<BeneficiaryDetailsView> {
  ExecuteProcessEvent? _deleteEvent;

  String _name(BuildContext context) =>
      widget.payee?.displayName ??
      AppLocalizations.of(context)!.beneficiariesFallbackName;

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '?';
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  /// The saved field values, minus the amount (a beneficiary is a recipient,
  /// not a transaction).
  List<MapEntry<String, dynamic>> get _rows {
    final data = widget.payee?.formData ?? const {};
    return data.entries
        .where((e) => (e.value?.toString().isNotEmpty ?? false))
        .where((e) => e.key.toLowerCase() != 'amount')
        .toList();
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDestructiveConfirm(
      context,
      icon: Icons.person_remove_outlined,
      title: l10n.beneficiariesRemoveTitle,
      message: l10n.beneficiariesRemoveConfirm(_name(context)),
      confirmText: l10n.commonRemove,
    );
    if (!confirmed || !mounted) return;
    _deleteEvent = context.dispatchProcess(
      DeletePayeeAction(
        payload: DeletePayeePayload(payeeId: widget.payee?.payeeId),
      ),
    );
  }

  String _label(String key) {
    // "SourceAccount" -> "Source Account"
    final spaced = key.replaceAllMapped(
      RegExp(r'(?<=[a-z])(?=[A-Z])'),
      (m) => ' ',
    );
    return spaced.isEmpty
        ? key
        : '${spaced[0].toUpperCase()}${spaced.substring(1)}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final rows = _rows;
    final name = _name(context);

    return ProcessListener<bool>(
      event: () => _deleteEvent,
      listener: (context, snapshot) {
        if (snapshot.isLoading) {
          MessageUtil.displayLoading(context);
          return;
        }
        MessageUtil.close(context);

        if (snapshot.isSuccessful) {
          _deleteEvent = null;
          if (widget.onBack != null) {
            widget.onBack!();
          } else {
            AppRouter.router.pop();
          }
        } else if (snapshot.hasError) {
          _deleteEvent = null;
          MessageUtil.displayErrorDialog(
            context,
            message: snapshot.error!.message,
          );
        }
      },
      child: MainLayout(
        useScaffold: widget.onBack == null,
        onBack: widget.onBack,
        bottomSize: 72,
        title: l10n.beneficiariesDetailsTitle,
        // Secondary, not a filled red slab: removing is the rare action on
        // this page, and it confirms before doing anything.
        bottomNav: FormOutlineButton(
          onPressed: _delete,
          text: l10n.beneficiariesRemoveButton,
          foregroundColor: AppColors.danger,
          iconColor: AppColors.danger,
          icon: Icons.person_remove_outlined,
          buttonIconAlignment: .left,
          iconSize: 20,
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: context.avatarBg,
              child: Text(_initials(name), style: context.header1),
            ),
            const SizedBox(height: Spacing.lg),
            Text(name, style: context.display2, textAlign: .center),
            if (widget.payee?.formName?.isNotEmpty ?? false) ...[
              const SizedBox(height: Spacing.sm),
              Container(
                padding: const .symmetric(
                  horizontal: Spacing.md,
                  vertical: Spacing.xs,
                ),
                decoration: BoxDecoration(
                  color: context.avatarBg,
                  borderRadius: .circular(100),
                ),
                child: Text(
                  widget.payee!.formName!,
                  style: context.smallDetailsMedium,
                ),
              ),
            ],
            const SizedBox(height: Spacing.xxl),
            Container(
              padding: const .symmetric(horizontal: Spacing.lg),
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: .circular(16),
                border: .all(color: context.border),
              ),
              child: Column(
                mainAxisSize: .min,
                children: [
                  for (final (index, entry) in rows.indexed) ...[
                    _detailRow(_label(entry.key), entry.value.toString()),
                    if (index != rows.length - 1)
                      Divider(height: 1, color: context.divider),
                  ],
                  if (rows.isEmpty)
                    _detailRow(
                      l10n.beneficiariesRecipientLabel,
                      widget.payee?.value ?? '-',
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Label over value (reads better than a squeezed two-column row once
  /// values get long, e.g. account numbers), with a copy action since these
  /// are exactly the values people paste elsewhere.
  Widget _detailRow(String label, String value) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const .symmetric(vertical: Spacing.md),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(label, style: context.smallDetails),
                const SizedBox(height: 2),
                Text(value, style: context.p1Medium),
              ],
            ),
          ),
          IconButton(
            tooltip: l10n.commonCopy,
            icon: Icon(
              Icons.copy_rounded,
              size: 18,
              color: context.textSecondary,
            ),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: value));
              if (!mounted) return;
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(l10n.commonCopied)));
            },
          ),
        ],
      ),
    );
  }
}
