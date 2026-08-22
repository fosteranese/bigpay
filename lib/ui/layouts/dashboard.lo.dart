import 'package:bigpay/data/models/account/account.dart';
import 'package:bigpay/ui/components/wallet/virtual_wallet_card.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/ui/theme/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DashboardLayout extends StatefulWidget {
  const DashboardLayout({
    super.key,
    this.children,
    this.isDashboard = false,
    this.backgroundColor,
    this.builder,
    this.title,
    this.balance,
    this.isVirtual = true,
    this.onBack,
    this.wallet,
  });
  final List<Widget>? children;
  final bool isDashboard;
  final Color? backgroundColor;
  final List<Widget> Function(double blur, double alpha)? builder;

  /// The wallet's display title — shown in the app bar, and (for a non-virtual
  /// wallet) in place of the balance on the card.
  final String? title;

  /// The wallet balance, shown on the card only for a virtual wallet.
  final String? balance;

  /// Whether this is the virtual wallet — drives the balance vs. title design.
  final bool isVirtual;

  final VoidCallback? onBack;

  final Account? wallet;

  @override
  State<DashboardLayout> createState() => _DashboardLayoutState();
}

class _DashboardLayoutState extends State<DashboardLayout> {
  final _scrollController = ScrollController();

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
    final bgColor = widget.backgroundColor ?? context.cardBg;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        alignment: .topCenter,
        width: double.maxFinite,

        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-0.11, -1.0),
            end: Alignment(0.11, 1.0),
            colors: [
              Color(0xFF385BA9),
              if (isDark) Color(0xFF1E2D5A) else Color(0xFFC5D8FF),
              bgColor,
            ],
            stops: [
              0.0829, // 8.29%
              0.2292, // 22.92%
              0.3634, // 36.34%
            ],
          ),
        ),
        child: BoundedContent(
          maxWidth: context.responsive<double>(
            compact: double.infinity,
            medium: 760,
            expanded: 960,
          ),
          child: CustomScrollView(
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
                actionsPadding: .only(right: 15),
                leadingWidth: widget.isDashboard ? 15 + 36 : 70,
                leading: widget.isDashboard
                    ? Padding(
                        padding: const .only(left: 15),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: context.avatarBg,
                        ),
                      )
                    : IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: context.cardBg,
                          fixedSize: Size(28, 28),
                        ),
                        onPressed: widget.onBack ?? () {},
                        icon: Icon(
                          Icons.chevron_left_outlined,
                        ),
                      ),

                title: widget.isDashboard
                    ? Column(
                        mainAxisSize: .min,
                        mainAxisAlignment: .center,
                        crossAxisAlignment: .start,
                        children: [
                          Text(
                            'Welcome Back',
                            style: AppTypography.caption.copyWith(
                              color: context.divider,
                            ),
                          ),
                          Text(
                            'Tom Dockery',
                            style: AppTypography.p1Medium.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        widget.title ?? 'Wallet',
                        style: AppTypography.p1.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                actions: [
                  if (widget.isDashboard)
                    IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.white20,
                      ),
                      onPressed: () {},
                      icon: SvgPicture.asset('assets/img/new-notification.svg'),
                    ),
                ],
                centerTitle: false,
                flexibleSpace: ValueListenableBuilder<double>(
                  valueListenable: _blurOpacity,
                  builder: (context, blur, _) => ClipRect(
                    child: BackdropFilter(
                      filter: .blur(
                        sigmaX: 60 * blur,
                        sigmaY: 60 * blur,
                      ),
                      child: Container(
                        color: AppColors.white.withValues(
                          alpha: 0.15 * blur,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: VirtualWalletCard(
                  label: widget.title,
                  balance: widget.balance,
                  title: widget.title,
                  isVirtual: widget.isVirtual,
                  wallet: widget.wallet,
                ),
              ),
              ...widget.children ?? [],
              // Sampled per rebuild (not per scroll frame) now that scrolling no
              // longer rebuilds this layout — the builder's slivers are static.
              ...(widget.builder?.call(
                    60 * _blurOpacity.value,
                    0.15 * _blurOpacity.value,
                  ) ??
                  []),
            ],
          ),
        ),
      ),
    );
  }
}
