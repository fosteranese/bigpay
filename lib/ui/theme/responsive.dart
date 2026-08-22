import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:bigpay/ui/theme/foldable.dart';

/// Material window-size-class breakpoints. Keyed off current viewport width,
/// not device type — a landscape phone or an unfolded foldable lands in the
/// same bucket as a small tablet, which is the point.
class Breakpoints {
  Breakpoints._();

  static const medium = 600.0; // tablet portrait / unfolded foldable
  static const expanded = 840.0; // tablet landscape / desktop
  static const wide = 1100.0; // room for sidebar + master + detail together
}

extension ResponsiveContext on BuildContext {
  double get _width => MediaQuery.sizeOf(this).width;

  bool get isCompact => _width < Breakpoints.medium;
  bool get isMedium =>
      _width >= Breakpoints.medium && _width < Breakpoints.expanded;
  bool get isExpanded => _width >= Breakpoints.expanded;

  /// Wide enough for a sidebar (248) + a master list pane (~400) + a usable
  /// detail pane all at once — see [MasterDetailLayout].
  bool get isWide => _width >= Breakpoints.wide;

  /// Drives the [MainShell] nav-rail switch — bottom pill nav below this,
  /// side rail at or above it.
  bool get isTabletOrLarger => !isCompact;

  T responsive<T>({required T compact, T? medium, T? expanded}) {
    if (_width >= Breakpoints.expanded) return expanded ?? medium ?? compact;
    if (_width >= Breakpoints.medium) return medium ?? compact;
    return compact;
  }

  /// Breakpoint-scaled spacing — the shared layouts' outer padding grows a
  /// little past phone width, alongside (not instead of) the content-width
  /// cap in [BoundedContent].
  double get gutter =>
      responsive<double>(compact: 20, medium: 28, expanded: 36);
}

/// The width centered content should cap itself to — the same logic
/// [BoundedContent] uses, exposed for call sites that can't just wrap a
/// child in a widget (e.g. modal bottom sheets). In book mode, this is the
/// left pane's width: [MediaQuery] reports the *whole* unfolded window
/// (both panes plus the seam), so capping to the ordinary tablet/desktop
/// width and centering across that would straddle the hinge instead of
/// sitting inside one pane.
double contentCapWidth(BuildContext context, {double? maxWidth}) {
  final hinge = context.isBookMode ? context.hingeBounds : null;
  if (hinge != null) {
    return maxWidth == null ? hinge.left : math.min(maxWidth, hinge.left);
  }
  return maxWidth ??
      context.responsive<double>(
        compact: double.infinity,
        medium: 640,
        expanded: 720,
      );
}

/// Centers [child] and caps its width once the viewport grows past phone
/// size, so content doesn't stretch edge-to-edge on a tablet, an unfolded
/// foldable, or a desktop window. On a foldable in book mode, confines
/// itself to the left pane instead of centering across the hinge.
class BoundedContent extends StatelessWidget {
  const BoundedContent({super.key, required this.child, this.maxWidth});

  final Widget child;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final cap = contentCapWidth(context, maxWidth: maxWidth);
    if (cap == double.infinity) return child;

    final hinge = context.isBookMode ? context.hingeBounds : null;
    if (hinge != null) {
      // heightFactor: 1 on both Aligns — the outer one (for the pane
      // confinement) is just as prone to the size-inflation issue described
      // below as the inner one is, and without it here too, it would still
      // undo the inner fix for a Scaffold-measured slot.
      return Align(
        alignment: Alignment.centerLeft,
        heightFactor: 1,
        child: SizedBox(
          width: hinge.left,
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: cap),
              child: child,
            ),
          ),
        ),
      );
    }

    // heightFactor: 1 matters here — without it, Center reports its own
    // size as the *full* incoming (loose) constraints regardless of the
    // child's actual height. That's harmless for a greedy filler like
    // MainLayout's CustomScrollView (which fills to the max anyway), but
    // when this same BoundedContent wraps something Scaffold measures for
    // its own sizing — bottomNavigationBar — Scaffold reads back that
    // inflated "full height" and reserves all remaining space for it,
    // squeezing body down to zero. heightFactor: 1 makes Center shrink-wrap
    // to the child's true height instead, so Scaffold measures it correctly.
    return Center(
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: cap),
        child: child,
      ),
    );
  }
}
