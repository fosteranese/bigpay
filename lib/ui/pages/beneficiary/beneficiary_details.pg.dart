import 'package:flutter/material.dart';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/data/models/payee/payee.dart';
import 'package:bigpay/models/actions/beneficiary/delete_payee_action.dart';
import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/forms.dart';
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
  State<BeneficiaryDetailsView> createState() =>
      _BeneficiaryDetailsViewState();
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

  void _delete() {
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
    final rows = _rows;

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
        title: AppLocalizations.of(context)!.beneficiariesDetailsTitle,
        bottomNav: FormButton(
          backgroundColor: AppColors.danger,
          onPressed: _delete,
          text: AppLocalizations.of(context)!.beneficiariesRemoveButton,
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            CircleAvatar(
              radius: 34,
              backgroundColor: context.avatarBg,
              child: Text(_initials(_name(context)), style: context.header2),
            ),
            const SizedBox(height: Spacing.md),
            Text(_name(context), style: context.header3, textAlign: .center),
            if (widget.payee?.formName?.isNotEmpty ?? false)
              Text(
                widget.payee!.formName!,
                style: context.smallDetails,
                textAlign: .center,
              ),
            const SizedBox(height: Spacing.xxl),
            Container(
              padding: .all(20),
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: .circular(12),
              ),
              child: Column(
                mainAxisSize: .min,
                children: [
                  for (final (index, entry) in rows.indexed) ...[
                    _detailRow(_label(entry.key), entry.value.toString()),
                    if (index != rows.length - 1)
                      Divider(color: context.divider),
                  ],
                  if (rows.isEmpty)
                    _detailRow(
                      AppLocalizations.of(context)!.beneficiariesRecipientLabel,
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

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const .symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: .start,
        children: [
          Expanded(
            child: Text(label, style: context.smallDetails),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Text(
              value,
              textAlign: .end,
              style: context.smallDetailsBold,
            ),
          ),
        ],
      ),
    );
  }
}
