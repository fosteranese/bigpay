import 'package:flutter/material.dart';

import 'package:bigpay/data/models/complaint/complaint_message.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';

/// One message in a complaint trail, styled as a chat bubble — the customer's
/// messages on the right, support's on the left.
class ComplaintBubble extends StatelessWidget {
  const ComplaintBubble({super.key, required this.message});

  final ComplaintMessage message;

  @override
  Widget build(BuildContext context) {
    final fromUser = message.fromUser;

    // Caps each bubble to 75% of whatever width this widget actually has
    // available (the chat pane's own width, already narrowed by
    // BoundedContent/MasterDetailLayout) — not the full window, or a bubble
    // in a split-view/book-mode pane would balloon past its edge. A
    // LayoutBuilder would do this more directly, but it can't sit inside
    // MainLayout's SliverFillRemaining(hasScrollBody: false): that sliver
    // probes its child's intrinsic height, and LayoutBuilder can't answer
    // that (it throws, silently blanking the whole pane). FractionallySizedBox
    // supports intrinsics, so it's the safe way to express the same cap.
    return FractionallySizedBox(
      alignment: fromUser ? Alignment.centerRight : Alignment.centerLeft,
      widthFactor: 0.75,
      child: Align(
        alignment: fromUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const .symmetric(vertical: 4),
          padding: const .symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: fromUser ? AppColors.primary : context.cardBg,
            borderRadius: .only(
              topLeft: const .circular(14),
              topRight: const .circular(14),
              bottomLeft: .circular(fromUser ? 14 : 2),
              bottomRight: .circular(fromUser ? 2 : 14),
            ),
          ),
          child: Column(
            mainAxisSize: .min,
            crossAxisAlignment: fromUser ? .end : .start,
            children: [
              if (!fromUser && (message.sender?.isNotEmpty ?? false))
                Padding(
                  padding: const .only(bottom: 3),
                  child: Text(
                    message.sender!,
                    style: context.caption.copyWith(
                      color: context.accentGreen,
                    ),
                  ),
                ),
              Text(
                message.message ?? '',
                style: context.smallDetails.copyWith(
                  color: fromUser ? AppColors.white : context.textPrimary,
                ),
              ),
              if (message.date?.isNotEmpty ?? false)
                Padding(
                  padding: const .only(top: 4),
                  child: Text(
                    message.date!,
                    style: context.caption.copyWith(
                      fontSize: 10,
                      color: fromUser
                          ? AppColors.white.withValues(alpha: 0.7)
                          : context.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
