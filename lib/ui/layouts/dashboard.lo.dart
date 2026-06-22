import 'package:bigpay/ui/components/forms/button.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/ui/theme/assets/app_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DashboardLayout extends StatefulWidget {
  const DashboardLayout({
    super.key,
    this.children,
    this.isDashboard = false,
    this.backgroundColor = const Color(0xFFF8F8F8),
    this.builder,
  });
  final List<Widget>? children;
  final bool isDashboard;
  final Color backgroundColor;
  final List<Widget> Function(double blur, double alpha)? builder;

  @override
  State<DashboardLayout> createState() => _DashboardLayoutState();
}

class _DashboardLayoutState extends State<DashboardLayout> {
  final _scrollController = ScrollController();
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
    return Scaffold(
      body: Container(
        alignment: .topCenter,
        width: double.maxFinite,

        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-0.11, -1.0), // Calculates the 176.94° angle
            end: Alignment(0.11, 1.0),
            colors: [
              Color(0xFF385BA9),
              Color(0xFFC5D8FF),
              widget.backgroundColor,
            ],
            stops: [
              0.0829, // 8.29%
              0.2292, // 22.92%
              0.3634, // 36.34%
            ],
          ),
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
                        backgroundColor: AppColors.tintShade3,
                      ),
                    )
                  : IconButton.filled(
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.white,
                        fixedSize: Size(28, 28),
                      ),
                      onPressed: () {},
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
                            color: AppColors.fade,
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
                      'Virtual Wallet',
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
              flexibleSpace: ClipRect(
                child: BackdropFilter(
                  filter: .blur(
                    sigmaX: 60 * _blurOpacity,
                    sigmaY: 60 * _blurOpacity,
                  ),
                  child: Container(
                    color: AppColors.white.withValues(
                      alpha: 0.15 * _blurOpacity,
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                width: double.maxFinite,
                height: 177,
                margin: const .all(15),
                decoration: BoxDecoration(
                  borderRadius: .circular(12),
                  gradient: LinearGradient(
                    begin: Alignment(
                      0.84,
                      0.44,
                    ), // Calculates the 293.59° angle
                    end: Alignment(-0.84, -0.44),
                    colors: [
                      Color(0xFF221E55),
                      Color(0xFF20428C),
                    ],
                    stops: [
                      0.17, // 17%
                      0.5109, // 51.09%
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Align(
                      alignment: .topRight,
                      child: ClipRRect(
                        borderRadius: .circular(12),
                        child: SvgPicture.asset(
                          'assets/img/card-corner-icon.svg',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const .symmetric(
                        vertical: 22,
                        horizontal: 18,
                      ),
                      child: Column(
                        mainAxisSize: .max,
                        crossAxisAlignment: .start,
                        children: [
                          Text(
                            '${widget.isDashboard ? 'Virtual ' : ''}Wallet Balance',
                            style: AppTypography.smallDetails.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisSize: .max,
                            mainAxisAlignment: .start,
                            crossAxisAlignment: .center,
                            children: [
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'GHS ',
                                      style: AppTypography.display1.copyWith(
                                        color: AppColors.secondary,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '20,000.00',
                                      style: AppTypography.display1,
                                    ),
                                  ],
                                ),
                              ),

                              IconButton.filled(
                                style: IconButton.styleFrom(
                                  alignment: .center,
                                  padding: .all(5),
                                  backgroundColor: AppColors.white11,
                                  fixedSize: Size(25, 25),
                                  minimumSize: Size(25, 25),
                                  maximumSize: Size(25, 25),
                                ),
                                onPressed: () {},
                                icon: SvgPicture.asset(
                                  SvgImages.invisible,
                                  colorFilter: .mode(AppColors.white, .srcIn),
                                ),
                              ),
                            ],
                          ),
                          Spacer(),
                          Row(
                            children: [
                              Expanded(
                                child: FormButton(
                                  backgroundColor: AppColors.white11,
                                  height: 46,
                                  onPressed: () {},
                                  text: 'Fund Wallet',
                                  labelSize: 13,
                                  svgIcon: 'assets/img/wallet.svg',
                                  iconSize: 15,
                                  buttonIconAlignment: .left,
                                ),
                              ),
                              if (widget.isDashboard) const SizedBox(width: 10),
                              if (widget.isDashboard)
                                Expanded(
                                  child: FormButton(
                                    backgroundColor: AppColors.white11,
                                    height: 46,
                                    onPressed: () {},
                                    text: 'View Details',
                                    labelSize: 13,
                                    svgIcon: 'assets/img/trending-up.svg',
                                    iconSize: 15,
                                    buttonIconAlignment: .left,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ...widget.children ?? [],
            ...(widget.builder?.call(60 * _blurOpacity, 0.15 * _blurOpacity) ??
                []),
          ],
        ),
      ),
    );
  }
}
