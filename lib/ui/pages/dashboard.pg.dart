import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/button.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/ui/theme/assets/app_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(path: '/dashboard');

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
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
              Color(0xFFF8F8F8),
            ],
            stops: [
              0.0829, // 8.29%
              0.2292, // 22.92%
              0.3634, // 36.34%
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              actionsPadding: .only(right: 15),
              leadingWidth: 15 + 36,
              leading: Padding(
                padding: const .only(left: 15),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.tintShade3,
                ),
              ),
              title: Column(
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
              ),
              actions: [
                IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.white20,
                  ),
                  onPressed: () {},
                  icon: SvgPicture.asset('assets/img/new-notification.svg'),
                ),
              ],

              centerTitle: false,
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
                      child: SvgPicture.asset(
                        'assets/img/card-corner-icon.svg',
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
                            'Virtual Wallet Balance',
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
                              const SizedBox(width: 10),
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
          ],
        ),
      ),
    );
  }
}
