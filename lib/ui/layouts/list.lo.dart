import 'package:flutter/material.dart';

import 'package:bigpay/ui/components/app_refresh_indicator.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/ui/theme/responsive.dart';

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
    this.onRefresh,
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

  /// Pull-to-refresh handler. When set, the list gets a [RefreshIndicator];
  /// the future should complete when the reload lands.
  final Future<void> Function()? onRefresh;

  @override
  State<ListLayout> createState() => _ListLayoutState();
}

class _ListLayoutState extends State<ListLayout> {
  final ScrollController _scrollController = ScrollController();

  /// Drives the app-bar blur as the page scrolls. A notifier (not setState) so
  /// scrolling repaints only the header overlay, not the whole list body.
  final ValueNotifier<double> _blurOpacity = ValueNotifier(0.0);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      _blurOpacity.value = (_scrollController.offset / 80).clamp(0.0, 1.0);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _blurOpacity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: .topCenter,
          end: .bottomCenter,
          stops: [0.0, 0.3077],
          colors: [
            context.scaffoldBg,
            context.cardBg,
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
                style: context.p1,
              )
            : null,
        leading: widget.showBackBtn
            ? IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: context.cardBg,
                  fixedSize: Size(28, 28),
                ),
                onPressed: () {},
                icon: Icon(
                  Icons.chevron_left_outlined,
                ),
              )
            : null,
        bottom: widget.bottom,
        flexibleSpace: ValueListenableBuilder<double>(
          valueListenable: _blurOpacity,
          builder: (context, blur, _) => ClipRect(
            child: BackdropFilter(
              filter: .blur(
                sigmaX: 12 * blur,
                sigmaY: 12 * blur,
              ),
              child: Container(
                margin: .only(
                  bottom: widget.appBarBottomColor,
                ),
                color:
                    widget.appBarColor ??
                    context.appBarOverlay.withValues(
                      alpha: blur,
                    ),
              ),
            ),
          ),
        ),
      ),

      body: BoundedContent(
        child: Container(
          color: widget.bodyColor,
          child: widget.onRefresh != null
              ? AppRefreshIndicator(
                  onRefresh: widget.onRefresh!,
                  child: widget.child(_scrollController),
                )
              : widget.child(_scrollController),
        ),
      ),

      bottomNavigationBar: widget.bottomNav != null
          ? BoundedContent(
              child: Container(
                padding: .only(
                  right: 20,
                  left: 20,
                  top: 15,
                  bottom: 10,
                ),
                child: SafeArea(
                  child: widget.bottomNav!,
                ),
              ),
            )
          : null,
    );
  }
}
