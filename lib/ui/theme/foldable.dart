import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:flutter/material.dart';

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
}

/// Splits [master] and [detail] across a foldable's hinge when the device is
/// half-opened ([BuildContext.isBookMode]); otherwise just renders [master]
/// full-width, so this is a no-op wrapper on every non-foldable device.
///
/// [detail] is optional — pass null to show [emptyDetail] (e.g. "select an
/// item") in the second pane before anything's been picked.
class FoldAwareLayout extends StatelessWidget {
  const FoldAwareLayout({
    super.key,
    required this.master,
    this.detail,
    this.emptyDetail,
  });

  final Widget master;
  final Widget? detail;
  final Widget? emptyDetail;

  @override
  Widget build(BuildContext context) {
    final hinge = context.hingeBounds;
    if (!context.isBookMode || hinge == null) {
      return master;
    }

    return Row(
      children: [
        SizedBox(width: hinge.left, child: master),
        // The hinge itself — content stays clear of the crease.
        SizedBox(width: hinge.width),
        Expanded(
          child: detail ?? emptyDetail ?? const SizedBox.shrink(),
        ),
      ],
    );
  }
}
