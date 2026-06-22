import 'package:flutter/material.dart';

class MyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  // final Widget child;
  final Widget Function(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  )
  builder;

  MyHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.builder,
  });

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return builder(context, shrinkOffset, overlapsContent);
  }

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => false;
}

class Cliper extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  Cliper({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => false;
}
