import 'package:flutter/material.dart';

import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/models/actions/action.dart';
import 'package:bigpay/models/actions/logout_action.dart';
import 'package:bigpay/ui/components/forms/button.dart';
import 'package:bigpay/ui/components/forms/outline_button.dart';
import 'package:bigpay/ui/components/process_builder.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/ui/theme/responsive.dart';

/// Confirmation sheet: sign out, remove a beneficiary ([destructive], red),
/// or a neutral ask such as opening Settings to grant a permission.
/// A floating bottom sheet on compact widths (actions in thumb reach), a
/// centered capped dialog from medium up. Both route types already keep off
/// a book-mode hinge (DisplayFeatureSubScreen). Resolves true on confirm.
Future<bool> showConfirmSheet(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String message,
  required String confirmText,
  bool destructive = true,
}) async {
  final content = _ConfirmContent(
    icon: icon,
    title: title,
    message: message,
    confirmText: confirmText,
    accent: destructive ? AppColors.danger : AppColors.tint,
  );

  final bool? confirmed;
  if (context.isCompact) {
    confirmed = await showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        margin: const EdgeInsets.all(Spacing.xl),
        decoration: BoxDecoration(
          color: sheetContext.cardBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: content,
      ),
    );
  } else {
    confirmed = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (dialogContext) => Dialog(
        backgroundColor: dialogContext.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        constraints: const BoxConstraints(maxWidth: 400),
        child: content,
      ),
    );
  }
  return confirmed ?? false;
}

/// Sign-out confirmation, shared by More → Sign Out and the shell's
/// back-at-root handler.
Future<void> showSignOutDialog(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final confirmed = await showConfirmSheet(
    context,
    icon: Icons.logout_rounded,
    title: l10n.moreSignOutTitle,
    message: l10n.moreSignOutConfirm,
    confirmText: l10n.moreSignOutTitle,
  );
  if (!confirmed || !context.mounted) return;
  LogoutAction.event = context.dispatchProcess(
    LogoutAction(payload: NoPayload()),
  );
}

class _ConfirmContent extends StatelessWidget {
  const _ConfirmContent({
    required this.icon,
    required this.title,
    required this.message,
    required this.confirmText,
    required this.accent,
  });

  final IconData icon;
  final String title;
  final String message;
  final String confirmText;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    // This context belongs to the sheet/dialog route itself, so
    // Navigator.of resolves the root navigator it was shown on.
    void close(bool result) => Navigator.of(context).pop(result);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(Spacing.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accent, size: 28),
          ),
          const SizedBox(height: Spacing.lg),
          Text(title, textAlign: TextAlign.center, style: context.header1),
          const SizedBox(height: Spacing.sm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: context.p1.copyWith(color: context.textSecondary),
          ),
          const SizedBox(height: Spacing.xxl),
          // Stacked, not side by side: holds at 320dp and text scale 1.3,
          // and keeps the confirm action visually primary.
          FormButton(
            onPressed: () => close(true),
            text: confirmText,
            backgroundColor: accent,
            foregroundColor: AppColors.white,
          ),
          const SizedBox(height: Spacing.md),
          FormOutlineButton(
            onPressed: () => close(false),
            text: AppLocalizations.of(context)!.commonCancel,
          ),
        ],
      ),
    );
  }
}
