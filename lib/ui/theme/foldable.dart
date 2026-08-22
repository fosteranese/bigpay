import 'dart:math' as math;
import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:flutter/material.dart';

import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/ui/theme/responsive.dart';

/// Reads the device's fold/hinge geometry, exposed by Flutter as
/// [MediaQueryData.displayFeatures]. Purely additive to the width-based
/// breakpoints in [responsive.dart] — a foldable that isn't currently
/// half-opened (or a device with no hinge at all) behaves exactly like any
/// other screen at that width.
extension FoldableContext on BuildContext {
  DisplayFeature? get _hinge {
    for (final feature in MediaQuery.of(this).displayFeatures) {
      if (feature.type == DisplayFeatureType.hinge ||
          feature.type == DisplayFeatureType.fold) {
        return feature;
      }
    }
    return null;
  }

  /// True when the device is a foldable, currently in the half-opened
  /// ("book"/"tabletop") posture — the case where splitting content across
  /// the hinge into two panes makes sense.
  bool get isBookMode => _hinge?.state == DisplayFeatureState.postureHalfOpened;

  /// The hinge's bounds in logical pixels, if there is one — regardless of
  /// posture. Null on any non-foldable device.
  Rect? get hingeBounds => _hinge?.bounds;

  /// Whether a list→detail page should show its detail inline
  /// ([MasterDetailLayout]) rather than push a separate page — either a real
  /// foldable hinge (book mode) or just a wide-enough regular screen.
  bool get usesSplitView => isBookMode || isWide;
}

/// Splits [master] and [detail] into two side-by-side panes whenever
/// [BuildContext.usesSplitView] is true — across a real foldable hinge in
/// book mode, or a fixed-width [masterWidth] pane on any other wide screen.
/// Otherwise just renders [master] full-width, so this is a no-op wrapper on
/// a phone or a medium (tablet/rail-width) screen.
///
/// [detail] is optional — pass null to show [emptyDetail] (e.g. "select an
/// item") in the second pane before anything's been picked.
class MasterDetailLayout extends StatelessWidget {
  const MasterDetailLayout({
    super.key,
    required this.master,
    this.detail,
    this.emptyDetail,
    this.masterWidth = 400,
  });

  final Widget master;
  final Widget? detail;
  final Widget? emptyDetail;

  /// Master-pane width for the wide-screen (non-hinge) case. Ignored in real
  /// book mode, where the hinge's own position determines the split.
  final double masterWidth;

  @override
  Widget build(BuildContext context) {
    final hinge = context.isBookMode ? context.hingeBounds : null;
    if (hinge == null && !context.isWide) {
      return master;
    }

    final masterPaneWidth = hinge?.left ?? masterWidth;
    // Some foldables (e.g. Pixel Fold's continuous hinge) report a
    // zero-width hairline rather than a physical seam — floor the gap so the
    // divider stays visible instead of collapsing to nothing.
    final gapWidth = math.max(hinge?.width ?? 24.0, 24.0);

    return Row(
      crossAxisAlignment: .stretch,
      children: [
        SizedBox(width: masterPaneWidth, child: master),
        SizedBox(
          width: gapWidth,
          child: Center(
            child: Container(
              width: 1,
              color: context.textTertiary.withValues(alpha: 0.3),
            ),
          ),
        ),
        Expanded(
          child: detail ?? emptyDetail ?? const SizedBox.shrink(),
        ),
      ],
    );
  }
}

/// The "nothing selected yet" state for a [MasterDetailLayout] detail pane —
/// a soft icon circle plus a short message, so every list→detail flow gets
/// the same polish instead of each hand-rolling its own `Center(Text(...))`.
class PaneEmptyState extends StatelessWidget {
  const PaneEmptyState({
    super.key,
    required this.icon,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: .min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.avatarBg,
              ),
              child: Icon(icon, size: 28, color: context.textTertiary),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: context.smallDetails,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
