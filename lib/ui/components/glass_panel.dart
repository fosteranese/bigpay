import 'package:flutter/material.dart';

class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.borderRadius = 24,
    this.backdropBlur = 21,
    this.padding = const .all(30),
  });

  final Widget child;
  final double borderRadius;
  final double backdropBlur;
  final EdgeInsets padding;

  static const _lightInset = _InsetShadow(
    offset: Offset(-12.4, 12.4),
    color: Color(0x22FFFFFF),
    blur: 12.4,
  );
  static const _darkInset = _InsetShadow(
    offset: Offset(12.4, -12.4),
    color: Color(0x22A5A5A5),
    blur: 12.4,
  );

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: .circular(borderRadius),
      child: BackdropFilter(
        filter: .blur(
          sigmaX: backdropBlur,
          sigmaY: backdropBlur,
        ),
        child: CustomPaint(
          foregroundPainter: _InsetShadowPainter(
            const [_lightInset, _darkInset],
            borderRadius,
          ),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

class _InsetShadow {
  const _InsetShadow({
    required this.offset,
    required this.color,
    required this.blur,
  });

  final Offset offset;
  final Color color;
  final double blur;
}

class _InsetShadowPainter extends CustomPainter {
  const _InsetShadowPainter(this.shadows, this.radius);

  final List<_InsetShadow> shadows;
  final double radius;

  /// Matches Flutter's own BoxShadow blur-radius→sigma conversion.
  static double _sigma(double radius) => radius * 0.57735 + 0.5;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );

    // Everything is painted inside the panel's rounded rect.
    canvas.save();
    canvas.clipRRect(rrect);

    for (final shadow in shadows) {
      final paint = Paint()
        ..color = shadow.color
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, _sigma(shadow.blur));

      // Shadow of the panel shifted by the offset, subtracted from a plane —
      // what remains inside the clip is a soft band on the edge away from the
      // offset, i.e. the inset shadow.
      final plane = Path()
        ..addRect(
          Rect.fromLTRB(
            -size.width,
            -size.height,
            size.width * 2,
            size.height * 2,
          ),
        );
      final shifted = Path()..addRRect(rrect.shift(shadow.offset));
      final band = Path.combine(PathOperation.difference, plane, shifted);

      canvas.drawPath(band, paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _InsetShadowPainter oldDelegate) =>
      oldDelegate.shadows != shadows || oldDelegate.radius != radius;
}
