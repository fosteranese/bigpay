import 'package:flutter/material.dart';

import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';

/// How a complaint's free-text server status groups for color and filtering.
enum ComplaintStage { open, resolved, other }

ComplaintStage complaintStage(String? status) {
  switch (status?.toLowerCase()) {
    case 'resolved':
    case 'closed':
    case 'success':
      return ComplaintStage.resolved;
    case 'open':
    case 'pending':
    case 'in progress':
    case 'processing':
      return ComplaintStage.open;
    default:
      return ComplaintStage.other;
  }
}

Color complaintStatusColor(BuildContext context, String? status) =>
    switch (complaintStage(status)) {
      ComplaintStage.resolved => AppColors.success,
      ComplaintStage.open => AppColors.pending,
      ComplaintStage.other => context.textSecondary,
    };

/// The tinted status pill used on complaint rows and the detail summary.
class ComplaintStatusChip extends StatelessWidget {
  const ComplaintStatusChip({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = complaintStatusColor(context, status);
    return Container(
      padding: const .symmetric(horizontal: Spacing.sm, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: .circular(6),
      ),
      child: Text(status, style: context.smallBold.copyWith(color: color)),
    );
  }
}
