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

    return Align(
      alignment: fromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const .symmetric(vertical: 4),
        padding: const .symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: fromUser ? AppColors.primary : AppColors.white,
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
                  style: AppTypography.caption.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
              ),
            Text(
              message.message ?? '',
              style: AppTypography.smallDetails.copyWith(
                color: fromUser ? AppColors.white : AppColors.black,
              ),
            ),
            if (message.date?.isNotEmpty ?? false)
              Padding(
                padding: const .only(top: 4),
                child: Text(
                  message.date!,
                  style: AppTypography.caption.copyWith(
                    fontSize: 10,
                    color: fromUser
                        ? AppColors.white.withValues(alpha: 0.7)
                        : AppColors.subtitleGrey,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
