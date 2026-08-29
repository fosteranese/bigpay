import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'package:bigpay/ui/theme/app_theme.dart';

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.border,
      highlightColor: context.border.withValues(alpha: 0.3),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: context.border,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class SkeletonCircle extends StatelessWidget {
  const SkeletonCircle({
    super.key,
    required this.size,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.border,
      highlightColor: context.border.withValues(alpha: 0.3),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: context.border,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class SkeletonText extends StatelessWidget {
  const SkeletonText({
    super.key,
    required this.width,
    this.height = 14,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(
      width: width,
      height: height,
      borderRadius: 4,
    );
  }
}
