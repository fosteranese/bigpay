import 'package:flutter/material.dart';

import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({
    super.key,
    this.title,
    this.subtitle,
    this.subtitleWidget,
    required this.child,
    this.bottomNav,
    this.bottomSize = 100,
    this.background,
    this.showBackBtn = true,
  });
  final String? title;
  final String? subtitle;
  final Widget? subtitleWidget;
  final Widget child;
  final Widget? bottomNav;
  final double bottomSize;
  final Widget? background;
  final bool showBackBtn;

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
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
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
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
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: true,
            snap: true,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: false,
            automaticallyImplyActions: false,
            leadingWidth: 70,
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
            bottom: PreferredSize(
              preferredSize: Size(double.maxFinite, widget.bottomSize),
              child: Container(
                width: double.maxFinite,
                padding: .only(left: 20, right: 20, bottom: 10),
                child: Column(
                  mainAxisSize: .min,
                  mainAxisAlignment: .center,
                  crossAxisAlignment: .start,
                  children: [
                    SizedBox(height: 16),
                    if (widget.title != null)
                      Text(
                        widget.title!,
                        style: AppTypography.display1.copyWith(
                          color: AppColors.black,
                        ),
                      ),
                    if (widget.subtitle != null)
                      Text(
                        widget.subtitle!,
                        style: AppTypography.smallDetails,
                      )
                    else if (widget.subtitleWidget != null)
                      widget.subtitleWidget!,
                  ],
                ),
              ),
            ),
            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: .blur(
                  sigmaX: 12 * _blurOpacity,
                  sigmaY: 12 * _blurOpacity,
                ),
                child: Container(
                  color: AppColors.white.withValues(
                    alpha: 0.15 * _blurOpacity,
                  ),
                ),
              ),
            ),
          ),
          SliverFillRemaining(
            fillOverscroll: true,
            hasScrollBody: false,
            child: Padding(
              padding: const .all(20),
              child: widget.child,
            ),
          ),
        ],
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
