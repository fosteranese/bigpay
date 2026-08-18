import 'package:flutter/material.dart';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/data/models/payee/payee.dart';
import 'package:bigpay/models/actions/beneficiary/delete_payee_action.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/forms.dart';
import 'package:bigpay/ui/components/process_builder.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/utils/message.util.dart';

/// A saved beneficiary's details, with the option to remove it.
class BeneficiaryDetailsPage extends StatefulWidget {
  const BeneficiaryDetailsPage({super.key, this.payee});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/beneficiaries/details',
    name: 'beneficiary-details',
  );

  final Payee? payee;

  @override
  State<BeneficiaryDetailsPage> createState() => _BeneficiaryDetailsPageState();
}

class _BeneficiaryDetailsPageState extends State<BeneficiaryDetailsPage> {
  ExecuteProcessEvent? _deleteEvent;

  String get _name => widget.payee?.displayName ?? 'Beneficiary';

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
          AppRouter.router.pop();
        } else if (snapshot.hasError) {
          _deleteEvent = null;
          MessageUtil.displayErrorDialog(
            context,
            message: snapshot.error!.message,
          );
        }
      },
      child: MainLayout(
        bottomSize: 72,
        title: 'Beneficiary Details',
        bottomNav: FormButton(
          backgroundColor: AppColors.danger,
          onPressed: _delete,
          text: 'Remove Beneficiary',
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            CircleAvatar(
              radius: 34,
              backgroundColor: context.avatarBg,
              child: Text(_initials(_name), style: context.header2),
            ),
            const SizedBox(height: 12),
            Text(_name, style: context.header3, textAlign: .center),
            if (widget.payee?.formName?.isNotEmpty ?? false)
              Text(
                widget.payee!.formName!,
                style: context.smallDetails,
                textAlign: .center,
              ),
            const SizedBox(height: 24),
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
                    _detailRow('Recipient', widget.payee?.value ?? '-'),
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
          const SizedBox(width: 12),
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
