import 'dart:math' as math;
import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:flutter/material.dart';

import 'package:bigpay/ui/theme/app_theme.dart';
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

  /// True when this context lives inside a [MasterDetailLayout]'s pane —
  /// its parent has already confined it to one side of the split (e.g. the
  /// detail pane, which sits on the *right* of the hinge). [BoundedContent]
  /// uses this to skip its own hinge-avoidance in that case: re-confining
  /// pane content to the left-of-hinge width would push it to hug whichever
  /// edge faces the hinge instead of centering in its own, already-correct
  /// box — which is why, before this check existed, a modal opened from
  /// [MasterDetailLayout]'s detail pane (e.g. the wallet page's "View
  /// Statement" sheet) rendered hard against the left edge instead of
  /// staying inside the pane it was actually opened from.
  bool get isInsideSplitPane =>
      findAncestorWidgetOfExactType<MasterDetailLayout>() != null;
}

/// Splits [master] and [detail] into two side-by-side panes whenever
/// [BuildContext.usesSplitView] is true *and* something's actually selected
/// — across a real foldable hinge in book mode, or a fixed-width
/// [masterWidth] pane on any other wide screen. Otherwise (including
/// whenever [detail] is null — nothing selected yet) just renders [master]
/// full-width, so this is a no-op wrapper on a phone or a medium
/// (tablet/rail-width) screen, and doesn't split into a cramped list pane
/// plus an empty detail pane before the user has picked anything.
class MasterDetailLayout extends StatelessWidget {
  const MasterDetailLayout({
    super.key,
    required this.master,
    this.detail,
    this.masterWidth = 400,
  });

  final Widget master;
  final Widget? detail;

  /// Master-pane width for the wide-screen (non-hinge) case. Ignored in real
  /// book mode, where the hinge's own position determines the split.
  final double masterWidth;

  @override
  Widget build(BuildContext context) {
    final hinge = context.isBookMode ? context.hingeBounds : null;
    if (hinge == null && !context.isWide) {
      return master;
    }

    // Nothing selected yet — let master use the whole window instead of
    // splitting into a cramped list pane plus a mostly-empty "select
    // something" pane. The split only earns its keep once there's a detail
    // to actually show.
    if (detail == null) {
      return master;
    }
    final resolvedDetail = detail!;

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
        Expanded(child: resolvedDetail),
      ],
    );
  }
}
