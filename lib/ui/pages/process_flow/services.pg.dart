import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/data/models/auth_data/activity_datum.dart';
import 'package:bigpay/data/models/auth_data/auth_data.dart';
import 'package:bigpay/models/actions/refresh_dashboard_action.dart';
import 'package:bigpay/models/actions/services/get_service_categories_action.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/forms.dart';
import 'package:bigpay/ui/components/process_builder.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/utils/app_state.util.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/services',
  );

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  final _searchController = TextEditingController();
  String _query = '';

  /// The in-flight dashboard refresh, correlated by the listener in [build].
  ExecuteProcessEvent? _refreshEvent;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(
      () => setState(() => _query = _searchController.text.trim()),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Pull-to-refresh: the services list is drawn from the user's account data,
  /// so re-fetch it (activities and all) and hold the spinner until it lands.
  Future<void> _onRefresh() async {
    final event = context.dispatchProcess(const RefreshDashboardAction());
    setState(() => _refreshEvent = event);
    await context.awaitProcess(event);
  }

  /// The user's services, narrowed by the search query against the service
  /// name and description.
  List<ActivityDatum> get _activities {
    final all = (AppState.currentUser?.activities ?? const [])
        .cast<ActivityDatum>();
    if (_query.isEmpty) return all;

    final query = _query.toLowerCase();
    return all
        .where(
          (e) =>
              (e.activity?.activityName ?? '').toLowerCase().contains(query) ||
              (e.activity?.description ?? '').toLowerCase().contains(query),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return ProcessListener<AuthData>(
      event: () => _refreshEvent,
      listener: (context, snapshot) {
        if (snapshot.hasData) {
          setState(() => AppState.currentUser = snapshot.data);
        }
      },
      child: MainLayout(
        backgroundColor: context.scaffoldBg,
        miniTitle: 'Services',
        onRefresh: _onRefresh,
        bottom: PreferredSize(
          preferredSize: Size(double.maxFinite, 60),
          child: Padding(
            padding: const .only(
              left: 20,
              right: 20,
              bottom: 10,
            ),
            child: FormInput(
              placeholder: 'Search',
              controller: _searchController,
              suffix: Icon(Icons.search),
            ),
          ),
        ),
        builder: (_) => Builder(
          builder: (context) {
            final activities = _activities;

            if (activities.isEmpty) {
              final searching = _query.isNotEmpty;
              return SliverFillRemaining(
                fillOverscroll: true,
                hasScrollBody: false,
                child: Column(
                  mainAxisSize: .max,
                  mainAxisAlignment: .center,
                  crossAxisAlignment: .center,
                  children: [
                    Spacer(flex: 3),
                    SvgPicture.asset('assets/img/empty-wallet.svg'),
                    Text(
                      searching ? 'No matches' : 'Empty Services',
                      style: context.p1Bold,
                    ),
                    Text(
                      searching
                          ? 'No services match "$_query"'
                          : 'No Services found',
                      style: AppTypography.caption,
                    ),
                    Spacer(flex: 6),
                  ],
                ),
              );
            }

            return SliverList.builder(
              itemCount: activities.length,
              itemBuilder: (context, index) {
                final item = activities[index];
                return Padding(
                  padding: const .symmetric(
                    horizontal: 20,
                    vertical: 5,
                  ),
                  child: ListTile(
                    onTap: () {
                      GetServiceCategoriesAction.activityDatum = item;
                      GetServiceCategoriesAction.event = context
                          .dispatchProcess(
                            saveActionResponse: true,
                            returnSavedResponse: true,
                            GetServiceCategoriesAction(
                              endpointFunc: () =>
                                  GetServiceCategoriesAction.endpointFor(item),
                            ),
                          );
                    },
                    contentPadding: .symmetric(
                      horizontal: 15,
                    ),
                    tileColor: context.cardBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: .circular(14),
                    ),
                    leading: CachedNetworkImage(
                      imageUrl:
                          '${AppState.currentUser?.imageBaseUrl}${item.imageDirectory}/${item.activity?.icon}',
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
                    title: Text(
                      item.activity?.activityName ?? '',
                      style: context.header4,
                    ),
                    subtitle: Text(
                      item.activity?.description ?? '',
                      style: AppTypography.caption,
                    ),
                    trailing: Icon(Icons.chevron_right_outlined),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
