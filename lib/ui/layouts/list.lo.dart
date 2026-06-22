import 'package:flutter/material.dart';

import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';

class ListLayout extends StatefulWidget {
  const ListLayout({
    super.key,
    this.title,
    this.subtitle,
    this.subtitleWidget,
    required this.child,
    this.bottomNav,
    this.bottomSize = 100,
    this.background,
    this.showBackBtn = true,
    this.actions,
    this.miniTitle,
    this.titleStyle,
    this.appBarColor,
    this.bodyColor = Colors.transparent,
    this.bottom,
    this.appBarBottomColor = 0,
  });
  final String? title;
  final String? subtitle;
  final Widget? subtitleWidget;
  final Widget Function(ScrollController scrollController) child;
  final Widget? bottomNav;
  final double bottomSize;
  final Widget? background;
  final bool showBackBtn;
  final List<Widget>? actions;
  final String? miniTitle;
  final TextStyle? titleStyle;
  final Color? appBarColor;
  final Color bodyColor;
  final PreferredSizeWidget? bottom;
  final double appBarBottomColor;

  @override
  State<ListLayout> createState() => _ListLayoutState();
}

class _ListLayoutState extends State<ListLayout> {
  final ScrollController _scrollController = ScrollController();
  double _blurOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final opacity = (_scrollController.offset / 80).clamp(0.0, 1.0);
      if (opacity != _blurOpacity) {
        setState(() => _blurOpacity = opacity);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: .topCenter,
          end: .bottomCenter,
          stops: [0.0, 0.3077],
          colors: [
            AppColors.background,
            AppColors.white,
          ],
        ),
      ),
      child: (widget.background == null)
          ? _buildMainPage()
          : Stack(
              children: [
                widget.background!,
                _buildMainPage(),
              ],
            ),
    );
  }

  Scaffold _buildMainPage() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        automaticallyImplyActions: false,
        leadingWidth: 70,
        actions: widget.actions,
        title: (widget.miniTitle?.isNotEmpty ?? false)
            ? Text(
                widget.miniTitle!,
                style: AppTypography.p1,
              )
            : null,
        leading: widget.showBackBtn
            ? IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.white,
                  fixedSize: Size(28, 28),
                ),
                onPressed: () {},
                icon: Icon(
                  Icons.chevron_left_outlined,
                ),
              )
            : null,
        bottom: widget.bottom,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: .blur(
              sigmaX: 12 * _blurOpacity,
              sigmaY: 12 * _blurOpacity,
            ),
            child: Container(
              margin: .only(
                bottom: widget.appBarBottomColor,
              ),
              color:
                  widget.appBarColor ??
                  AppColors.white.withValues(
                    alpha: 0.15 * _blurOpacity,
                  ),
            ),
          ),
        ),
      ),

      body: Container(
        color: widget.bodyColor,
        // padding: const .all(20),
        child: widget.child(_scrollController),
      ),

      bottomNavigationBar: widget.bottomNav != null
          ? Container(
              padding: .only(
                right: 20,
                left: 20,
                top: 15,
                bottom: 10,
              ),
              child: SafeArea(
                child: widget.bottomNav!,
              ),
            )
          : null,
    );
  }
}
