import 'package:flutter/material.dart';

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

/// Centers [child] and caps its width once the viewport grows past phone
/// size, so content doesn't stretch edge-to-edge on a tablet, an unfolded
/// foldable, or a desktop window.
class BoundedContent extends StatelessWidget {
  const BoundedContent({super.key, required this.child, this.maxWidth});

  final Widget child;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final cap =
        maxWidth ??
        context.responsive<double>(
          compact: double.infinity,
          medium: 640,
          expanded: 720,
        );
    if (cap == double.infinity) return child;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: cap),
        child: child,
      ),
    );
  }
}
