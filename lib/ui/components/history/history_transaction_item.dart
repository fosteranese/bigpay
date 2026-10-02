import 'dart:math';

import 'package:flutter/material.dart';

import 'package:bigpay/constants/status.const.dart';
import 'package:bigpay/data/models/general_flow/request_response.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';

/// One transaction row in the history list. Renders a [RequestResponse] — a
/// round avatar (service initials) with a status-coloured direction badge, the
/// service name and date, and the amount with its status on the right.
///
/// Non-financial records (an enquiry, with no amount) show a receipt glyph and
/// a status badge in place of the amount, mirroring umb's history item.
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

  /// Up to two letters from the service name, for the avatar.
  String get _initials {
    final name = (record.formName ?? record.activityName ?? '').trim();
    final words = name
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return '';
    if (words.length == 1) {
      return words.first.substring(0, min(2, words.first.length)).toUpperCase();
    }
    return (words[0][0] + words[1][0]).toUpperCase();
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
    return Material(
      type: MaterialType.transparency,
      child: ListTile(
        onTap: onTap,
        contentPadding: const .symmetric(horizontal: 20, vertical: 4),
        leading: _avatar(context),
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
                style: context.formLabels,
              ),
            const SizedBox(height: 6),
            Text(
              record.statusLabel ?? '',
              style: context.smallDetailsMedium.copyWith(
                color: _statusColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatar(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 46,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: 23,
            backgroundColor: context.avatarBg,
            child: _hasAmount
                ? Text(
                    _initials,
                    style: context.captionBold.copyWith(
                      color: context.textSecondary,
                    ),
                  )
                : Icon(
                    Icons.receipt_long_outlined,
                    color: context.textSecondary,
                    size: 20,
                  ),
          ),
          // Status-coloured direction badge, bottom-right.
          if (_hasAmount)
            Positioned(
              right: -1,
              bottom: -1,
              child: Container(
                padding: const .all(2),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.north_east,
                  size: 13,
                  color: _statusColor(context),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
