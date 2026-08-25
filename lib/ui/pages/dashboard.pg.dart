import 'package:bigpay/data/models/general_flow/general_flow_category.dart';
import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/models/actions/action.dart';
import 'package:bigpay/data/models/general_flow/general_flow_form_data.dart';
import 'package:bigpay/models/actions/get_profile_picture_action.dart';
import 'package:bigpay/models/actions/services/get_service_categories_action.dart';
import 'package:bigpay/models/actions/services/get_service_form_data_action.dart';
import 'package:bigpay/ui/components/app_refresh_indicator.dart';
import 'package:bigpay/ui/components/process_builder.dart';
import 'package:bigpay/ui/components/wallet/virtual_wallet_card.dart';
import 'package:bigpay/ui/mixins/dashboard_data_refresh.dart';
import 'package:bigpay/ui/pages/notifications/notifications.pg.dart';
import 'package:bigpay/ui/pages/process_flow/service.pg.dart';
import 'package:bigpay/ui/pages/process_flow/service_form.pg.dart';
import 'package:bigpay/ui/pages/wallets/virtual.pg.dart';
import 'package:bigpay/utils/message.util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:bigpay/data/models/account/source.dart';
import 'package:bigpay/data/models/auth_data/activity.dart';
import 'package:bigpay/data/models/auth_data/activity_datum.dart';
import 'package:bigpay/data/models/auth_data/recent_activity.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/ui/theme/responsive.dart';
import 'package:bigpay/utils/app_state.util.dart';
import 'package:bigpay/utils/avatar.util.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(path: '/dashboard');

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with DashboardDataRefresh {
  final _scrollController = ScrollController();

  /// Drives the app-bar blur as the page scrolls. A notifier (not setState) so
  /// scrolling repaints only the header overlay, not the whole dashboard.
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

  /// Pull-to-refresh: re-fetches the user's dashboard data (activities,
  /// most-used services, wallet balance) plus the avatar, holding the spinner
  /// until the reload lands. Mirrors umb's `RefreshUserData`.
  Future<void> _onRefresh() async {
    GetProfilePictureAction.event = context.dispatchProcess(
      returnSavedResponse: true,
      saveActionResponse: true,
      GetProfilePictureAction(payload: NoPayload()),
    );
    await refreshDashboardData();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return MultiProcessListener(
      listeners: [
        // Pull-to-refresh result: swap in the fresh dashboard data.
        dashboardRefreshListener,
        ProcessListenerConfig<GeneralFlowCategory>(
          event: () => GetServiceCategoriesAction.event,
          listener: (context, snapshot) {
            if (snapshot.isLoading &&
                !snapshot.isSilent &&
                !snapshot.isCached) {
              MessageUtil.displayLoading(context);
              return;
            } else if (!snapshot.isSilent && !snapshot.isCached) {
              MessageUtil.close(context);
            }

            if (snapshot.hasData &&
                !(snapshot.isSilent && !snapshot.isCached)) {
              if (!snapshot.isSilent &&
                  !snapshot.isCached &&
                  (snapshot.data?.forms?.isEmpty ?? true)) {
                MessageUtil.displayErrorDialog(
                  context,
                  title: AppLocalizations.of(context)!.commonServiceUnavailableTitle,
                  message: AppLocalizations.of(context)!.commonServiceUnavailableMessage,
                );
                return;
              }

              AppRouter.router.push(
                ServicePage.route.path,
                extra: {
                  'activityDatum': GetServiceCategoriesAction.activityDatum,
                  'category': snapshot.data,
                },
              );
              return;
            }

            if (snapshot.hasError) {
              MessageUtil.displayErrorDialog(
                context,
                message: snapshot.error!.message,
              );
              return;
            }
          },
        ),
        // A most-used/favourite tap fetches the form directly and jumps
        // straight to the service form, skipping category selection.
        ProcessListenerConfig<GeneralFlowFormData>(
          event: () => GetServiceFormDataAction.event,
          listener: (context, snapshot) {
            if (snapshot.isLoading &&
                !snapshot.isSilent &&
                !snapshot.isCached) {
              MessageUtil.displayLoading(context);
              return;
            } else if (!snapshot.isSilent && !snapshot.isCached) {
              MessageUtil.close(context);
            }

            if (snapshot.hasData &&
                !(snapshot.isSilent && !snapshot.isCached)) {
              if (!snapshot.isSilent &&
                  !snapshot.isCached &&
                  (snapshot.data?.fieldsDatum?.isEmpty ?? true)) {
                MessageUtil.displayErrorDialog(
                  context,
                  title: AppLocalizations.of(context)!.commonServiceUnavailableTitle,
                  message: AppLocalizations.of(context)!.commonServiceUnavailableMessage,
                );
                return;
              }

              AppRouter.router.push(
                ServiceFormPage.route.path,
                extra: {
                  'activityDatum': GetServiceFormDataAction.activityDatum,
                  'category': const GeneralFlowCategory(),
                  'formData': snapshot.data,
                },
              );
              return;
            }

            if (snapshot.hasError) {
              MessageUtil.displayErrorDialog(
                context,
                message: snapshot.error!.message,
              );
              return;
            }
          },
        ),
      ],
      child: Container(
        alignment: .topCenter,
        width: double.maxFinite,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-0.11, -1.0), // Calculates the 176.94° angle
            end: Alignment(0.11, 1.0),
            colors: [
              AppColors.dashboardGradientStart,
              if (isDark) AppColors.dashboardGradientMidDark else AppColors.dashboardGradientMidLight,
              isDark ? AppColors.dashboardGradientEndDark : AppColors.dashboardGradientEndLight,
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
          body: AppRefreshIndicator(
            onRefresh: _onRefresh,
            // The app bar is a sliver, so drop the indicator in below it.
            edgeOffset: MediaQuery.paddingOf(context).top + kToolbarHeight,
            child: BoundedContent(
              maxWidth: context.responsive<double>(
                compact: double.infinity,
                medium: 760,
                expanded: 960,
              ),
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: ClampingScrollPhysics(),
                ),
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
                      child: ProcessBuilder<String>(
                        event: () => GetProfilePictureAction.event,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            AppState.currentUser = AppState.currentUser!
                                .copyWith(
                                  profilePicture: snapshot.data ?? '',
                                );
                            return CircleAvatar(
                              radius: 18,
                              backgroundColor: context.avatarBg,
                              backgroundImage: avatarFromBase64(
                                AppState.currentUser?.profilePicture,
                              ),
                            );
                          }

                          return CircleAvatar(
                            radius: 18,
                            backgroundColor: context.avatarBg,
                          );
                        },
                      ),
                    ),
                    title: Column(
                      mainAxisSize: .min,
                      mainAxisAlignment: .center,
                      crossAxisAlignment: .start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.dashboardWelcomeBack,
                          style: context.caption.copyWith(
                            color: context.divider,
                          ),
                        ),
                        Text(
                          AppState.currentUser?.user?.name ?? '',
                          style: context.p1Medium.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      IconButton(
                        tooltip: AppLocalizations.of(context)!.dashboardNotificationsTooltip,
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.white20,
                        ),
                        onPressed: () =>
                            AppRouter.router.push(NotificationsPage.route.path),
                        icon: SvgPicture.asset(
                          'assets/img/new-notification.svg',
                        ),
                      ),
                    ],
                    centerTitle: false,
                    flexibleSpace: ValueListenableBuilder<double>(
                      valueListenable: _blurOpacity,
                      builder: (context, blur, _) => ClipRect(
                        child: BackdropFilter(
                          filter: .blur(
                            sigmaX: 12 * blur,
                            sigmaY: 12 * blur,
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
                      label: _virtualBalance?.tile,
                      balance: _virtualBalance?.balance,
                      isVirtual: true,
                      showViewDetails: true,
                      onViewDetails: () =>
                          AppRouter.router.push(VirtualWalletPage.route.path),
                    ),
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
                              AppLocalizations.of(context)!.dashboardMostUsedServices,
                              style: context.smallDetailsBold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: context.responsive(
                              compact: 60,
                              medium: 72,
                              expanded: 84,
                            ),
                            // A plain horizontal list rather than a
                            // fixed-fraction PageView — a fraction sized for
                            // a phone (~0.6 of the width) would balloon each
                            // pill to fill most of a wide/expanded window
                            // instead of just showing more of them at their
                            // natural size, which is what more room should
                            // buy here.
                            child: ListView.builder(
                              scrollDirection: .horizontal,
                              itemCount:
                                  AppState.currentUser?.recentActivity
                                      ?.length ??
                                  0,
                              itemBuilder: (context, index) {
                                final item =
                                    AppState.currentUser!.recentActivity![index];
                                return FrequentServiceItem(data: item);
                              },
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
                        AppLocalizations.of(context)!.dashboardServicesHeader,
                        style: context.header3,
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: .all(15),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: context.responsive(
                          compact: 2,
                          medium: 3,
                          expanded: 4,
                        ),
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
          ),
        ),
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
    final item = data;
    return InkWell(
      borderRadius: .circular(14),
      onTap: () {
        GetServiceCategoriesAction.activityDatum = data;
        GetServiceCategoriesAction.event = context.dispatchProcess(
          saveActionResponse: true,
          returnSavedResponse: true,
          GetServiceCategoriesAction(
            endpointFunc: () => GetServiceCategoriesAction.endpointFor(item),
          ),
        );
      },
      child: Container(
        padding: .all(16),
        decoration: BoxDecoration(
          color: context.cardBg,
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
              data.activity?.activityName ??
                  AppLocalizations.of(context)!.commonNotAvailable,
              overflow: .ellipsis,
              maxLines: 1,
              style: context.header4,
            ),
            const Spacer(flex: 1),
            Text(
              data.activity?.description ?? '',
              overflow: .ellipsis,
              maxLines: 2,
              style: context.caption,
            ),
          ],
        ),
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

  /// Fetches this favourite's form directly and hands the result to the
  /// dashboard's central listener, which jumps to the service form. Mirrors
  /// [ActionButton] dispatching [GetServiceCategoriesAction].
  void _open(BuildContext context) {
    GetServiceFormDataAction.activityDatum = ActivityDatum(
      activity: Activity(
        activityId: data.activityId,
        activityType: data.activityType,
        activityName: data.activityName,
        icon: data.icon,
      ),
    );
    GetServiceFormDataAction.event = context.dispatchProcess(
      saveActionResponse: true,
      returnSavedResponse: true,
      GetServiceFormDataAction(
        payload: GetServiceFormDataActionPayload(
          formId: data.formId,
          insId: data.formId,
        ),
        endpointFunc: () =>
            GetServiceFormDataAction.endpointFor(data.activityType),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Scales the pill up alongside the carousel's own responsive height
    // (see the SizedBox wrapping this in the dashboard build) — otherwise
    // a phone-sized pill just reads as small and cramped inside a taller,
    // wider row on a bigger screen instead of using the extra space.
    final iconSize = context.responsive<double>(
      compact: 24,
      medium: 28,
      expanded: 32,
    );
    final padding = context.responsive<double>(
      compact: 5,
      medium: 8,
      expanded: 10,
    );
    final gap = context.responsive<double>(compact: 5, medium: 8, expanded: 10);
    final fontScale = context.responsive<double>(
      compact: 1,
      medium: 1.1,
      expanded: 1.2,
    );

    return GestureDetector(
      onTap: () => _open(context),
      child: Container(
        alignment: .centerLeft,
        margin: .only(left: 10),
        padding: .all(padding),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: .circular(30),
        ),
        child: Row(
          mainAxisSize: .max,
          children: [
            CachedNetworkImage(
              imageUrl:
                  '${AppState.currentUser?.imageBaseUrl}${AppState.currentUser?.imageDirectory}/${data.icon}',
              imageBuilder: (context, imageProvider) {
                return CircleAvatar(
                  radius: iconSize / 2,
                  backgroundColor: context.avatarBg,
                  backgroundImage: imageProvider,
                );
              },
              placeholder: (context, url) => Icon(
                Icons.circle_outlined,
                color: Theme.of(context).primaryColor,
                size: iconSize,
              ),
              errorWidget: (context, url, error) => Icon(
                Icons.circle_outlined,
                color: Theme.of(context).primaryColor,
                size: iconSize,
              ),
            ),

            SizedBox(width: gap),
            Column(
              mainAxisSize: .max,
              mainAxisAlignment: .center,
              crossAxisAlignment: .start,
              children: [
                Text(
                  data.formName ?? '',
                  textAlign: .start,
                  maxLines: 1,
                  overflow: .ellipsis,
                  // This pill lives inside a fixed-height carousel; clamp
                  // rather than let a large system text size overflow it.
                  textScaler: MediaQuery.textScalerOf(
                    context,
                  ).clamp(maxScaleFactor: 1.3),
                  style: context.captionSemibold.copyWith(
                    fontSize: (context.captionSemibold.fontSize ?? 12) *
                        fontScale,
                  ),
                ),
                Text(
                  data.activityName ?? '',
                  textAlign: .start,
                  maxLines: 1,
                  overflow: .ellipsis,
                  textScaler: MediaQuery.textScalerOf(
                    context,
                  ).clamp(maxScaleFactor: 1.3),
                  style: context.caption.copyWith(
                    fontSize: (context.caption.fontSize ?? 11) *
                        fontScale,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
