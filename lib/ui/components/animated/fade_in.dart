import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

/// A one-time, subtle fade + slide-up entrance for content.
///
/// A thin wrapper over `animate_do`'s [FadeInUp] with restrained defaults — a
/// 12px rise over 300ms — so content "settles" into place rather than calling
/// attention to itself. Plays once on mount; a rebuild of the same [State]
/// won't replay it.
class FadeInView extends StatelessWidget {
  const FadeInView({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 300),
    this.from = 12,
  });

  final Widget child;

  /// Delay before the entrance starts — stagger sibling items with a small
  /// increment per index.
  final Duration delay;

  final Duration duration;

  /// Vertical offset (logical pixels) the child starts from.
  final double from;

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      delay: delay,
      duration: duration,
      curve: Curves.easeOutCubic,
      from: from,
      child: child,
    );
  }
}
