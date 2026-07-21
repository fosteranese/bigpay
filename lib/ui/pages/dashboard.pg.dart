import 'package:bigpay/data/models/account/source.dart';
import 'package:bigpay/data/models/auth_data/activity_datum.dart';
import 'package:bigpay/data/models/auth_data/recent_activity.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/button.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/ui/theme/assets/app_images.dart';
import 'package:bigpay/utils/app_state.util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(path: '/dashboard');

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
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

  Source? get _virtualBalance {
    return AppState.currentUser?.customerData
        ?.where((item) {
          return item.mode?.toUpperCase() == 'VIRTUAL_WALLET';
        })
        .firstOrNull
        ?.sources
        ?.firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Scaffold(
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
                    AppState.currentUser?.user?.name ?? '',
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
            SliverToBoxAdapter(
              child: VirtualWalletCard(virtualBalance: _virtualBalance),
            ),
            if (AppState.currentUser?.recentActivity?.isNotEmpty ?? false)
              SliverToBoxAdapter(
                child: Column(
                  mainAxisSize: .min,
                  mainAxisAlignment: .start,
                  crossAxisAlignment: .start,
                  children: [
                    Padding(
                      padding: const .symmetric(horizontal: 20),
                      child: Text(
                        'Most used services',
                        style: AppTypography.smallDetailsBold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 60,
                      child: PageView(
                        scrollDirection: .horizontal,
                        pageSnapping: true,
                        controller: PageController(
                          viewportFraction: 0.60,
                          keepPage: true,
                        ),
                        padEnds: false,
                        children:
                            AppState.currentUser?.recentActivity?.map((item) {
                              return FrequentServiceItem(data: item);
                            }).toList() ??
                            [],
                      ),
                    ),
                  ],
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const .only(
                  top: 20,
                  left: 15,
                  right: 15,
                ),
                child: Text(
                  'Services',
                  style: AppTypography.header3,
                ),
              ),
            ),
            SliverPadding(
              padding: .all(15),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  mainAxisExtent: 124,
                ),
                delegate: SliverChildListDelegate(
                  AppState.currentUser?.activities?.map((item) {
                        return ActionButton(
                          data: item,
                        );
                      }).toList() ??
                      [],
                ),
              ),
            ),
            // Clear the floating bottom nav so the last cards aren't hidden.
            const SliverToBoxAdapter(child: SizedBox(height: 110)),
          ],
        ),
      ),
    );
  }
}

class VirtualWalletCard extends StatelessWidget {
  VirtualWalletCard({
    super.key,
    required this._virtualBalance,
  });

  final Source? _virtualBalance;
  final _visible = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  _virtualBalance?.tile ?? 'Virtual Wallet Balance',
                  style: AppTypography.smallDetails.copyWith(
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 10),
                ValueListenableBuilder(
                  valueListenable: _visible,
                  builder: (context, visible, child) {
                    return Row(
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
                                text: visible
                                    ? _virtualBalance?.balance ?? '0.00'
                                    : '* *** **',
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
                          onPressed: () {
                            _visible.value = !_visible.value;
                          },
                          icon: SvgPicture.asset(
                            visible ? SvgImages.invisible : SvgImages.visible,
                            colorFilter: .mode(AppColors.white, .srcIn),
                            width: 24,
                          ),
                        ),
                      ],
                    );
                  },
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
    );
  }
}

class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    required this.data,
  });

  final ActivityDatum data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: .all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: .circular(14),
      ),
      child: Column(
        mainAxisSize: .max,
        crossAxisAlignment: .start,
        children: [
          CachedNetworkImage(
            imageUrl:
                '${AppState.currentUser?.imageBaseUrl}${AppState.currentUser?.imageDirectory}/${data.activity?.icon}',
            width: 24,
            height: 24,
            placeholder: (context, url) => Icon(
              Icons.circle_outlined,
              color: Theme.of(context).primaryColor,
              size: 24,
            ),
            errorWidget: (context, url, error) => Icon(
              Icons.circle_outlined,
              color: Theme.of(context).primaryColor,
              size: 24,
            ),
          ),
          const Spacer(flex: 4),
          Text(
            data.activity?.activityName ?? 'N/A',
            overflow: .ellipsis,
            maxLines: 1,
            style: AppTypography.header4,
          ),
          const Spacer(flex: 1),
          Text(
            data.activity?.description ?? '',
            overflow: .ellipsis,
            maxLines: 2,
            style: AppTypography.caption,
          ),
        ],
      ),
    );
  }
}

class FrequentServiceItem extends StatelessWidget {
  const FrequentServiceItem({
    super.key,
    required this.data,
  });

  final RecentActivity data;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: .centerLeft,
      margin: .only(left: 10),
      padding: .all(5),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: .circular(30),
      ),
      child: Row(
        mainAxisSize: .max,
        children: [
          CachedNetworkImage(
            imageUrl:
                '${AppState.currentUser?.imageBaseUrl}${AppState.currentUser?.imageDirectory}/${data.icon}',
            // width: 24,
            // height: 24,
            imageBuilder: (context, imageProvider) {
              return CircleAvatar(
                backgroundColor: AppColors.tintShade3,
                backgroundImage: imageProvider,
              );
            },
            placeholder: (context, url) => Icon(
              Icons.circle_outlined,
              color: Theme.of(context).primaryColor,
              size: 24,
            ),
            errorWidget: (context, url, error) => Icon(
              Icons.circle_outlined,
              color: Theme.of(context).primaryColor,
              size: 24,
            ),
          ),

          const SizedBox(width: 5),
          Column(
            mainAxisSize: .max,
            mainAxisAlignment: .center,
            crossAxisAlignment: .start,
            children: [
              Text(
                data.formName ?? '',
                textAlign: .start,
                overflow: .ellipsis,
                style: AppTypography.captionSemibold,
              ),
              Text(
                data.activityName ?? '',
                textAlign: .start,
                overflow: .ellipsis,
                style: AppTypography.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
