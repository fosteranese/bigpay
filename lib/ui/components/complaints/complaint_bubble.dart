import 'package:flutter/material.dart';

import 'package:bigpay/data/models/complaint/complaint_message.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/utils/date.util.dart';

/// One message in a complaint trail, styled as a chat bubble — the
/// customer's on the right, support's on the left. Every bubble shows its
/// own timestamp.
///
/// [isGroupStart]/[isGroupEnd] mark this message's position in a
/// consecutive run from the same sender (on the same day). The corner
/// facing the neighboring bubble in that run — top on the sender's side
/// when it isn't the first, bottom when it isn't the last — flattens, so a
/// burst of quick replies reads as one connected stack with only its outer
/// corners rounded, rather than a pile of separately-rounded pills.
class ComplaintBubble extends StatelessWidget {
  const ComplaintBubble({
    super.key,
    required this.message,
    this.isGroupStart = true,
    this.isGroupEnd = true,
  });

  final ComplaintMessage message;
  final bool isGroupStart;
  final bool isGroupEnd;

  @override
  Widget build(BuildContext context) {
    final fromUser = message.fromUser;

    // Rounder than before (20 vs the old 14, and a softer 6 rather than a
    // near-square 2 for the grouped corner) — closer to the fuller, more
    // pill-shaped bubble Android's own Material 3 Messages app uses, rather
    // than the tighter, more rectangular bubble this started as. The two
    // corners on the sender's side (right for the user, left for support)
    // flatten wherever this bubble touches a neighbor in the same run; the
    // outer two corners stay fully rounded regardless of grouping.
    final bubble = Container(
      padding: const .symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: fromUser ? AppColors.primary : context.cardBg,
        borderRadius: .only(
          topLeft: .circular(fromUser || isGroupStart ? 20 : 6),
          topRight: .circular(!fromUser || isGroupStart ? 20 : 6),
          bottomLeft: .circular(fromUser || isGroupEnd ? 20 : 6),
          bottomRight: .circular(!fromUser || isGroupEnd ? 20 : 6),
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
              child: Row(
                mainAxisSize: .min,
                children: [
                  Text(
                    DateUtil.time(message.date),
                    style: context.caption.copyWith(
                      fontSize: 10,
                      color: fromUser
                          ? AppColors.white.withValues(alpha: 0.7)
                          : context.textSecondary,
                    ),
                  ),
                  // A static "sent" mark, not a real read receipt — there's
                  // no delivery/read status in the data, so this never
                  // changes state; it's here purely so the customer's own
                  // messages read as sent, matching a familiar chat pattern.
                  if (fromUser) ...[
                    const SizedBox(width: 3),
                    Icon(
                      Icons.done_all,
                      size: 12,
                      color: AppColors.white.withValues(alpha: 0.7),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );

    // A literal max width, not a fraction of the available space — a real
    // shrink-to-content bubble needs a LOOSE upper bound (ConstrainedBox),
    // not FractionallySizedBox: despite its name, widthFactor gives the
    // child a TIGHT constraint (minWidth == maxWidth), forcing every bubble
    // to that exact width regardless of how short its text was — which is
    // why "hi" was rendering as wide as a full sentence. A fixed px cap
    // (matching what most chat UIs actually use, rather than a percentage
    // of screen width) doesn't have that problem and still can't overflow a
    // split-view/book-mode pane, since MasterDetailLayout's narrowest pane
    // is wider than this. ConstrainedBox supports intrinsics, unlike
    // LayoutBuilder, which can't sit inside MainLayout's
    // SliverFillRemaining(hasScrollBody: false) — that sliver probes its
    // child's intrinsic height, and LayoutBuilder can't answer that (it
    // throws, silently blanking the whole pane).
    return Padding(
      padding: EdgeInsets.only(
        top: isGroupStart ? 8 : 2,
        bottom: 2,
      ),
      child: Align(
        alignment: fromUser ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: bubble,
        ),
      ),
    );
  }
}

/// A centered day-grouping pill between messages sent on different calendar
/// days ("Today", "Yesterday", a weekday, or a short date) — the same
/// divider every modern chat app, including Android's own Messages app,
/// uses to break a trail into per-day groups instead of one continuous,
/// undated run of bubbles.
class ComplaintDateDivider extends StatelessWidget {
  const ComplaintDateDivider({super.key, required this.date});

  final String? date;

  @override
  Widget build(BuildContext context) {
    final label = DateUtil.dayLabel(date);
    if (label.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const .symmetric(vertical: 10),
      child: Center(
        child: Container(
          padding: const .symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: context.divider,
            borderRadius: .circular(20),
          ),
          child: Text(
            label,
            style: context.caption.copyWith(color: context.textSecondary),
          ),
        ),
      ),
    );
  }
}
