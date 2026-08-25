import 'dart:math' as math;
import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:flutter/material.dart';

import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/responsive.dart';
import 'package:bigpay/utils/app_state.util.dart';

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
class MasterDetailLayout extends StatefulWidget {
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
  State<MasterDetailLayout> createState() => _MasterDetailLayoutState();
}

class _MasterDetailLayoutState extends State<MasterDetailLayout> {
  // Reflects our own split state into AppState.splitDetailOpenNotifier so
  // MainShell can collapse the sidebar/rail while a tab-root page (Services,
  // Wallets, History) is actually showing a detail pane — otherwise those
  // pages read differently from a pushed split view (Complaints,
  // Beneficiaries), which already has the full window to itself since
  // pushed routes don't carry the sidebar. Deferred to a post-frame
  // callback rather than set synchronously in build(): this runs as a
  // side effect of building, and MainShell (an ancestor) listens to it —
  // mutating an ancestor's dependency mid-build is the kind of thing
  // Flutter's build-phase assertions exist to catch.
  void _syncSidebarCollapse(bool splitting) {
    if (AppState.splitDetailOpenNotifier.value == splitting) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) AppState.splitDetailOpenNotifier.value = splitting;
    });
  }

  @override
  void dispose() {
    // Leaving the page entirely (e.g. switching tabs) — don't leave the
    // sidebar permanently collapsed with nothing left to justify it.
    if (AppState.splitDetailOpenNotifier.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppState.splitDetailOpenNotifier.value = false;
      });
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hinge = context.isBookMode ? context.hingeBounds : null;
    final isSplitting =
        (hinge != null || context.isWide) && widget.detail != null;
    _syncSidebarCollapse(isSplitting);

    if (hinge == null && !context.isWide) {
      return widget.master;
    }

    // Nothing selected yet — let master use the whole window instead of
    // splitting into a cramped list pane plus a mostly-empty "select
    // something" pane. The split only earns its keep once there's a detail
    // to actually show.
    if (widget.detail == null) {
      return widget.master;
    }
    final resolvedDetail = widget.detail!;

    // Some foldables (e.g. Pixel Fold's continuous hinge) report a
    // zero-width hairline rather than a physical seam — floor the gap so the
    // divider stays visible instead of collapsing to nothing.
    final gapWidth = math.max(hinge?.width ?? 24.0, 24.0);
    const minDetailWidth = 320.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        // hinge.left is reported in the window's own coordinate space
        // (origin at the physical screen's top-left), not this widget's
        // local one — only safe to use directly when this widget itself
        // starts at the window's left edge. The sidebar-collapse above
        // handles the steady state, but the *first* frame a split turns on
        // (sidebar still visible, MainShell hasn't reacted yet) still needs
        // this: however much narrower this widget's own local width is
        // than the full window is exactly how much horizontal space fixed
        // chrome ahead of it has already consumed — subtracting that turns
        // the global hinge offset into the correct local one. (Checking
        // only that hinge.left *fits inside* the local width isn't
        // sufficient on its own — a global offset can easily still be
        // smaller than the local width while still being the wrong
        // number.)
        final windowWidth = MediaQuery.sizeOf(context).width;
        final precedingChromeWidth = math.max(
          0.0,
          windowWidth - constraints.maxWidth,
        );
        final localHingeLeft = hinge != null
            ? hinge.left - precedingChromeWidth
            : null;
        final masterPaneWidth =
            (localHingeLeft != null &&
                localHingeLeft >= minDetailWidth &&
                localHingeLeft + gapWidth + minDetailWidth <=
                    constraints.maxWidth)
            ? localHingeLeft
            : widget.masterWidth;

        return Row(
          crossAxisAlignment: .stretch,
          children: [
            SizedBox(width: masterPaneWidth, child: widget.master),
            // Explicitly painted, not left transparent — with nothing else
            // behind this Row (MasterDetailLayout sits directly under
            // MainShell's transparent-background Scaffold), an unpainted
            // gap let whatever's further back than that show through as a
            // solid black bar the width of the real hinge seam.
            Container(
              width: gapWidth,
              color: context.scaffoldBg,
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
      },
    );
  }
}
