import 'package:flutter/material.dart';

import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/components/skeleton/skeleton.dart';

class WalletCardSkeleton extends StatelessWidget {
  const WalletCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 177,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.border,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkeletonBox(width: 40, height: 24, borderRadius: 4),
              const Spacer(),
              SkeletonCircle(size: 24),
            ],
          ),
          const SizedBox(height: 16),
          SkeletonText(width: 120, height: 18),
          const SizedBox(height: 8),
          SkeletonText(width: 80, height: 14),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: SkeletonBox(
                  width: double.infinity,
                  height: 46,
                  borderRadius: 8,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SkeletonBox(
                  width: double.infinity,
                  height: 46,
                  borderRadius: 8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TransactionItemSkeleton extends StatelessWidget {
  const TransactionItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          SkeletonCircle(size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonText(width: 140, height: 14),
                const SizedBox(height: 6),
                SkeletonText(width: 100, height: 12),
              ],
            ),
          ),
          SkeletonText(width: 60, height: 14),
        ],
      ),
    );
  }
}

class ListItemSkeleton extends StatelessWidget {
  const ListItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        children: [
          SkeletonCircle(size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonText(width: 160, height: 14),
                const SizedBox(height: 6),
                SkeletonText(width: 120, height: 12),
              ],
            ),
          ),
          SkeletonBox(width: 24, height: 24, borderRadius: 4),
        ],
      ),
    );
  }
}

/// A chat trail's loading state — a handful of pill-shaped shimmer blocks
/// alternating sides at varied widths, echoing the eventual bubble layout
/// instead of a generic row skeleton (which doesn't remotely resemble what
/// a chat thread actually looks like) sitting awkwardly in the middle of
/// the pane.
class ChatBubbleSkeleton extends StatelessWidget {
  const ChatBubbleSkeleton({super.key});

  static const _bubbles = [
    (alignEnd: false, width: 190.0),
    (alignEnd: true, width: 230.0),
    (alignEnd: true, width: 130.0),
    (alignEnd: false, width: 250.0),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final bubble in _bubbles)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Align(
              alignment: bubble.alignEnd
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: SkeletonBox(
                width: bubble.width,
                height: 40,
                borderRadius: 20,
              ),
            ),
          ),
      ],
    );
  }
}
