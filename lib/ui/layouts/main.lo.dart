import 'package:bigpay/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/ui/components/app_refresh_indicator.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/ui/theme/assets/app_images.dart';
import 'package:bigpay/ui/theme/responsive.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({
    super.key,
    this.title,
    this.subtitle,
    this.subtitleWidget,
    this.stepIndicator,
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
    this.onBack,
    this.bottomAlign = false,
  });
  final String? title;
  final String? subtitle;
  final Widget? subtitleWidget;
  final Widget? stepIndicator;
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

  /// Overrides the back button's action and forces it to show regardless of
  /// [showBackBtn]/`AppRouter.router.canPop()` — for a detail view reused as
  /// inline pane content in a [MasterDetailLayout] detail pane, where
  /// there's nothing to pop (the master page is still the top route) but
  /// "back" should still clear the pane's selection. Pushed-page usage
  /// leaves this null and keeps the default pop-the-route behavior.
  final VoidCallback? onBack;

  /// True to anchor [child] + [bottomNav] to the bottom of the available
  /// area on a bigger screen, instead of the default centering. A generic
  /// form reads best centered, but a chat thread should sit at the bottom
  /// the same way it does on phone (where [bottomNav] is docked to the
  /// screen edge regardless of this flag) — a short conversation floating
  /// mid-screen with equal blank margins above and below reads as broken,
  /// not as a deliberate layout. Ignored when [BuildContext.isCompact]
  /// (bottomNav docks to the Scaffold's own bottom bar there either way).
  final bool bottomAlign;

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

  /// Past expanded width (with [MainLayout.maxWidth] set), the step
  /// indicator moves into [_AuthBrandPanel] as a labeled vertical stepper
  /// instead — showing the same slim bar again in the header here would be
  /// a redundant second copy of it right next to the fuller version.
  bool _usesBrandPanelStepIndicator(BuildContext context) =>
      widget.maxWidth != null && context.isExpanded;

  static const _headerStepIndicatorHeight = 20.0;

  @override
  Widget build(BuildContext context) {
    final page = Container(
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

    // A narrow single-purpose form (maxWidth set — the 14 auth pages) reads
    // as an empty, unfinished phone screen stretched onto a wide window.
    // Past expanded width there's room to do what onboarding flows elsewhere
    // usually do with that space: a brand panel alongside the form instead
    // of around it. The form pane below is untouched — same BoundedContent
    // cap, same centering — just now sized against the remaining width
    // instead of the whole window.
    if (widget.maxWidth == null || !context.isExpanded) return page;

    return Row(
      crossAxisAlignment: .stretch,
      children: [
        _AuthBrandPanel(
          width: context.isWide ? 480 : 420,
          stepIndicator: widget.stepIndicator,
        ),
        Expanded(child: page),
      ],
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
    // On a phone, the CTA belongs docked to the screen's bottom edge (thumb
    // reach, stays put above the keyboard) — that's untouched here. On a
    // bigger screen that same docking is what stretches the gap between the
    // last field and the button across the whole leftover viewport height,
    // since the fields stay pinned to the top of a now much-taller body.
    // Past medium width, fold the button back into the normal content flow
    // instead (right after `child`) and center the resulting group — closes
    // the gap to a normal in-flow spacing and reads as a deliberate,
    // centered card rather than a phone layout stretched onto a big canvas.
    final dockBottomNav = context.isCompact;

    final bottomNavContent = widget.bottomNav == null
        ? null
        : (dockBottomNav
              ? SafeArea(child: widget.bottomNav!)
              : SafeArea(top: false, child: widget.bottomNav!));

    final pageContent = (dockBottomNav || bottomNavContent == null)
        ? widget.child
        : (widget.child == null
              ? bottomNavContent
              : Column(
                  mainAxisSize: .min,
                  crossAxisAlignment: .stretch,
                  children: [
                    widget.child!,
                    // A bit more room than the mobile in-form spacing here —
                    // this gap now separates two visually distinct groups
                    // (the content and the CTA) sitting on their own in the
                    // middle of a big screen, not a button following the
                    // next field down a phone's cramped column.
                    SizedBox(
                      height: context.responsiveSpacing(
                        compact: 24,
                        medium: 32,
                        expanded: 40,
                      ),
                    ),
                    bottomNavContent,
                  ],
                ));

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
              leading:
                  widget.onBack != null ||
                      (AppRouter.router.canPop() && widget.showBackBtn)
                  ? IconButton.filled(
                      tooltip: AppLocalizations.of(context)!.commonBack,
                      style: IconButton.styleFrom(
                        backgroundColor: context.cardBg,
                        foregroundColor: context.textPrimary,
                        fixedSize: Size(44, 44),
                      ),
                      onPressed: widget.onBack ?? AppRouter.router.pop,
                      icon: Icon(
                        Icons.chevron_left_outlined,
                      ),
                    )
                  : null,
              bottom:
                  widget.bottom ??
                  PreferredSize(
                    preferredSize: Size(
                      double.maxFinite,
                      widget.bottomSize +
                          (widget.stepIndicator != null &&
                                  !_usesBrandPanelStepIndicator(context)
                              ? _headerStepIndicatorHeight
                              : 0),
                    ),
                    child: Container(
                      width: double.maxFinite,
                      padding: .only(
                        left: context.gutter,
                        right: context.gutter,
                        bottom: context.isShortHeight ? 4 : 10,
                      ),
                      child: Column(
                        mainAxisSize: .min,
                        mainAxisAlignment: .center,
                        crossAxisAlignment: .start,
                        children: [
                          SizedBox(height: context.isShortHeight ? 8 : 16),
                          if (widget.stepIndicator != null &&
                              !_usesBrandPanelStepIndicator(context)) ...[
                            widget.stepIndicator!,
                            SizedBox(height: context.isShortHeight ? 8 : 12),
                          ],
                          if (widget.title != null && widget.actions == null)
                            FittedBox(
                              child: Text(
                                widget.title!,
                                style:
                                    (widget.titleStyle ??
                                            context.display2)
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
                                    style: context.display1.copyWith(
                                      color: context.textPrimary,
                                    ),
                                  ),
                                ),
                                if (widget.actions != null) widget.actions!,
                              ],
                            ),
                          if (!context.isShortHeight && widget.subtitle != null)
                            Text(
                              widget.subtitle!,
                              style: context.smallDetails,
                            )
                          else if (!context.isShortHeight &&
                              widget.subtitleWidget != null)
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
            else if (pageContent != null)
              SliverFillRemaining(
                fillOverscroll: true,
                hasScrollBody: false,
                child: Container(
                  color: widget.bodyColor,
                  padding: .all(context.gutter),
                  alignment: dockBottomNav
                      ? null
                      : (widget.bottomAlign
                            ? Alignment.bottomCenter
                            : Alignment.center),
                  // The step indicator used to be injected here (compact
                  // width only) — moved into the header, right above the
                  // title, so it reads as persistent flow progress instead
                  // of scrolling away with the page's own content, and so
                  // it shows at medium width too instead of only compact.
                  child: pageContent,
                ),
              ),
          ],
        ),
      ),
    );

    final Widget? dockedBottomNav = (!dockBottomNav || bottomNavContent == null)
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
              child: bottomNavContent,
            ),
          );

    if (!widget.useScaffold) {
      // Skipping Scaffold here (see the field doc on useScaffold) also
      // drops the Material ancestor it normally provides — needed by
      // ordinary Material widgets like TextField for ink splashes etc.
      // Material.transparency supplies that ancestor without adding a
      // color/elevation layer of its own.
      return Material(
        type: MaterialType.transparency,
        child: Container(
          color: widget.backgroundColor,
          child: dockedBottomNav == null
              ? body
              : Column(
                  children: [
                    Expanded(child: body),
                    dockedBottomNav,
                  ],
                ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: body,
      bottomNavigationBar: dockedBottomNav,
    );
  }
}

/// The wide-screen companion pane for a narrow auth/onboarding form — see
/// [MainLayout.build]. Deliberately generic (no step-specific copy) since
/// it's shared by all 14 sign-up/sign-in/forgot-password screens alike.
class _AuthBrandPanel extends StatelessWidget {
  const _AuthBrandPanel({required this.width, this.stepIndicator});

  final double width;
  final Widget? stepIndicator;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppGradients.walletCard.colors,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            mainAxisSize: .min,
            children: [
              SvgPicture.asset(
                SvgImages.icon,
                width: 180,
                colorFilter: const ColorFilter.mode(
                  AppColors.white,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                AppLocalizations.of(context)!.authBrandTagline,
                textAlign: .center,
                style: context.p1.copyWith(
                  color: AppColors.white.withValues(alpha: 0.85),
                  decoration: TextDecoration.none,
                ),
              ),
              if (stepIndicator != null) ...[
                const SizedBox(height: 32),
                stepIndicator!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
