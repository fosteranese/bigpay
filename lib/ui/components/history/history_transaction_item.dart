import 'package:flutter/material.dart';

import 'package:bigpay/constants/status.const.dart';
import 'package:bigpay/data/models/general_flow/request_response.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';

/// One transaction row in the history list. Renders a [RequestResponse] — the
/// service name and date, with the amount and status coloured by outcome.
///
/// Non-financial records (an enquiry, with no amount) show a status badge in
/// place of the amount, mirroring umb's history item.
class HistoryTransactionItem extends StatelessWidget {
  const HistoryTransactionItem({
    super.key,
    required this.record,
    this.onTap,
  });

  final RequestResponse record;
  final VoidCallback? onTap;

  bool get _hasAmount => record.amount?.isNotEmpty ?? false;

  Color _statusColor(BuildContext context) {
    switch (record.statusLabel?.toUpperCase()) {
      case StatusConstants.success:
        return AppColors.success;
      case StatusConstants.pending:
      case StatusConstants.processing:
        return AppColors.pending;
      case StatusConstants.failed:
      case StatusConstants.error:
        return AppColors.danger;
      default:
        return context.textSecondary;
    }
  }

  IconData get _directionIcon {
    switch (record.status) {
      case 1:
        return Icons.north_east_outlined;
      case 0:
        return Icons.south_west_outlined;
      default:
        return Icons.hourglass_bottom_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = record.formName ?? record.activityName ?? 'Transaction';
    final amount = _hasAmount ? ', ${record.amount}' : '';
    final status = record.statusLabel ?? '';

    return Semantics(
      label: '$title$amount, $status',
      button: onTap != null,
      excludeSemantics: true,
      child: _tile(context),
    );
  }

  Widget _tile(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const .symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        height: 44,
        width: 44,
        decoration: BoxDecoration(
          color: context.avatarBg,
          borderRadius: .circular(12),
        ),
        child: Icon(
          _hasAmount ? _directionIcon : Icons.receipt_long_outlined,
          color: _hasAmount ? _statusColor(context) : context.textSecondary,
          size: 18,
        ),
      ),
      title: Text(
        record.formName ?? record.activityName ?? '',
        maxLines: 2,
        overflow: .ellipsis,
        style: context.formLabels,
      ),
      subtitle: Text(
        record.receiptDateTime ?? record.receiptDate ?? '',
        style: context.caption,
      ),
      trailing: Column(
        mainAxisSize: .min,
        mainAxisAlignment: .center,
        crossAxisAlignment: .end,
        children: [
          if (_hasAmount)
            Text(
              record.amount ?? '',
              style: context.captionSemibold,
            ),
          const SizedBox(height: 4),
          Text(
            record.statusLabel ?? '',
            style: context.caption.copyWith(color: _statusColor(context)),
          ),
        ],
      ),
    );
  }
}
