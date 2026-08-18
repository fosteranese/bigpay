import 'package:flutter/material.dart';

import 'package:bigpay/ui/theme/app_theme.dart';

/// A [RefreshIndicator] with the app's pull-to-refresh styling in one place:
/// the spinner adapts to the theme (white on dark, brand primary on light) and
/// sits on the card background.
///
/// [edgeOffset] pushes the indicator down past a header — set it to the height
/// of any app bar/sliver above the scroll view so the spinner drops in from
/// under the header rather than behind it. Defaults to 0 (flush to the top).
class AppRefreshIndicator extends StatelessWidget {
  const AppRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
    this.edgeOffset = 0,
  });

  final Future<void> Function() onRefresh;
  final Widget child;
  final double edgeOffset;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return RefreshIndicator(
      onRefresh: onRefresh,
      edgeOffset: edgeOffset,
      color: isDark ? AppColors.white : AppColors.primary,
      backgroundColor: context.cardBg,
      child: child,
    );
  }
}
