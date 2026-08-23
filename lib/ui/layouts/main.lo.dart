import 'package:bigpay/routes/app_router.dart';
import 'package:flutter/material.dart';

import 'package:bigpay/ui/components/app_refresh_indicator.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/ui/theme/responsive.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({
    super.key,
    this.title,
    this.subtitle,
    this.subtitleWidget,
    this.child,
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
    this.flexibleSpace,
    this.builder,
    this.backgroundColor = Colors.transparent,
    this.onRefresh,
    this.useScaffold = true,
    this.maxWidth,
  });
  final String? title;
  final String? subtitle;
  final Widget? subtitleWidget;
  final Widget? child;
  final Widget? bottomNav;
  final double bottomSize;
  final Widget? background;
  final bool showBackBtn;
  final Widget? actions;
  final String? miniTitle;
  final TextStyle? titleStyle;
  final Color? appBarColor;
  final Color bodyColor;
  final PreferredSizeWidget? bottom;
  final double appBarBottomColor;
  final Color backgroundColor;
  final Widget? flexibleSpace;
  final Widget Function(ScrollController scrollController)? builder;

  /// Pull-to-refresh handler. When set, the scroll body gets a
  /// [RefreshIndicator]; the future should complete when the reload lands.
  final Future<void> Function()? onRefresh;

  /// False to render without an owning Scaffold — for use as inline pane
  /// content in a [MasterDetailLayout] detail pane, where a Scaffold nested
  /// inside the pane's Expanded silently fails to render its body on a real
  /// device. Pushed-page usage (the default) is unaffected.
  final bool useScaffold;

  /// Overrides [BoundedContent]'s default width cap (640/720 at
  /// medium/expanded) — for pages whose content is naturally much narrower
  /// than a generic content page, e.g. a single-column auth form with one or
  /// two fields and a button, which looks stretched-out at the generic cap.
  final double? maxWidth;

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final ScrollController _scrollController = ScrollController();

  /// Drives the app-bar blur as the page scrolls. A notifier (not setState) so
  /// scrolling repaints only the header overlay, not the whole scroll body.
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
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
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

  Widget _wrapRefresh(Widget child) {
    if (widget.onRefresh == null) return child;
    // The app bar is a sliver inside the scroll view, so offset the indicator
    // down by the header height — it then drops in from under the header, the
    // way it does on the (real-AppBar) history layout.
    final headerHeight =
        widget.bottom?.preferredSize.height ?? widget.bottomSize;
    return AppRefreshIndicator(
      onRefresh: widget.onRefresh!,
      edgeOffset:
          MediaQuery.paddingOf(context).top + kToolbarHeight + headerHeight,
      child: child,
    );
  }

  Widget _buildMainPage() {
    final body = BoundedContent(
      maxWidth: widget.maxWidth,
      child: _wrapRefresh(
        CustomScrollView(
          controller: _scrollController,
          physics: widget.onRefresh != null
              ? const AlwaysScrollableScrollPhysics(
                  parent: ClampingScrollPhysics(),
                )
              : const ClampingScrollPhysics(),
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
              title: (widget.miniTitle?.isNotEmpty ?? false)
                  ? Text(
                      widget.miniTitle!,
                      style: context.p1,
                    )
                  : null,
              leading: AppRouter.router.canPop() && widget.showBackBtn
                  ? IconButton.filled(
                      tooltip: 'Back',
                      style: IconButton.styleFrom(
                        backgroundColor: context.cardBg,
                        foregroundColor: context.textPrimary,
                        fixedSize: Size(44, 44),
                      ),
                      onPressed: () {
                        AppRouter.router.pop();
                      },
                      icon: Icon(
                        Icons.chevron_left_outlined,
                      ),
                    )
                  : null,
              bottom:
                  widget.bottom ??
                  PreferredSize(
                    preferredSize: Size(double.maxFinite, widget.bottomSize),
                    child: Container(
                      width: double.maxFinite,
                      padding: .only(
                        left: context.gutter,
                        right: context.gutter,
                        bottom: 10,
                      ),
                      child: Column(
                        mainAxisSize: .min,
                        mainAxisAlignment: .center,
                        crossAxisAlignment: .start,
                        children: [
                          SizedBox(height: 16),
                          if (widget.title != null && widget.actions == null)
                            FittedBox(
                              child: Text(
                                widget.title!,
                                style:
                                    (widget.titleStyle ??
                                            AppTypography.display2)
                                        .copyWith(
                                          color: context.textPrimary,
                                        ),
                              ),
                            )
                          else if (widget.title != null &&
                              widget.actions != null)
                            Row(
                              mainAxisSize: .max,
                              crossAxisAlignment: .center,
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.title!,
                                    style: AppTypography.display1.copyWith(
                                      color: context.textPrimary,
                                    ),
                                  ),
                                ),
                                if (widget.actions != null) widget.actions!,
                              ],
                            ),
                          if (widget.subtitle != null)
                            Text(
                              widget.subtitle!,
                              style: context.smallDetails,
                            )
                          else if (widget.subtitleWidget != null)
                            widget.subtitleWidget!,
                        ],
                      ),
                    ),
                  ),
              flexibleSpace:
                  widget.flexibleSpace ??
                  ValueListenableBuilder<double>(
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

            if (widget.builder != null)
              widget.builder!(_scrollController)
            else if (widget.child != null)
              SliverFillRemaining(
                fillOverscroll: true,
                hasScrollBody: false,
                child: Container(
                  color: widget.bodyColor,
                  padding: .all(context.gutter),
                  child: widget.child,
                ),
              ),
          ],
        ),
      ),
    );

    final Widget? bottomNav = widget.bottomNav == null
        ? null
        : BoundedContent(
            maxWidth: widget.maxWidth,
            child: Container(
              padding: .only(
                right: context.gutter,
                left: context.gutter,
                top: 15,
                bottom: 10,
              ),
              child: SafeArea(
                child: widget.bottomNav!,
              ),
            ),
          );

    if (!widget.useScaffold) {
      return Container(
        color: widget.backgroundColor,
        child: bottomNav == null
            ? body
            : Column(
                children: [
                  Expanded(child: body),
                  bottomNav,
                ],
              ),
      );
    }

    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: body,
      bottomNavigationBar: bottomNav,
    );
  }
}
