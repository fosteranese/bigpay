import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/data/models/auth_data/activity_datum.dart';
import 'package:bigpay/data/models/general_flow/general_flow_category.dart';
import 'package:bigpay/models/actions/services/get_service_categories_action.dart';
import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/forms.dart';
import 'package:bigpay/ui/components/process_builder.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/mixins/dashboard_data_refresh.dart';
import 'package:bigpay/ui/pages/process_flow/service.pg.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/components/empty_state.dart';
import 'package:bigpay/ui/components/skeleton/variants.dart';
import 'package:bigpay/ui/theme/assets/app_images.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/ui/theme/foldable.dart';
import 'package:bigpay/utils/app_state.util.dart';
import 'package:bigpay/utils/message.util.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/services',
  );

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> with DashboardDataRefresh {
  final _searchController = TextEditingController();
  String _query = '';

  /// The category shown in the detail pane in split view
  /// ([MasterDetailLayout]) — dispatched through a local event rather than
  /// the shared [GetServiceCategoriesAction.event] static field, so it
  /// doesn't also trigger the app-wide listener (in DashboardPage) that
  /// pushes [ServicePage]. Unused (and the pane not shown) on any other
  /// device, where opening a service dispatches through the static field as
  /// before.
  ActivityDatum? _selectedActivity;
  GeneralFlowCategory? _selectedCategory;
  ExecuteProcessEvent? _categoryEvent;

  void _openService(ActivityDatum item) {
    if (!context.usesSplitView) {
      GetServiceCategoriesAction.activityDatum = item;
      GetServiceCategoriesAction.event = context.dispatchProcess(
        saveActionResponse: true,
        returnSavedResponse: true,
        GetServiceCategoriesAction(
          endpointFunc: () => GetServiceCategoriesAction.endpointFor(item),
        ),
      );
      return;
    }

    // Synchronous, in this tap handler — not deferred to a post-frame
    // callback from inside MasterDetailLayout's build (an earlier version
    // of this did that, and it visibly glitched: the split rendered one
    // frame at the old, sidebar-cramped width, then jumped wider a frame
    // later once the sidebar actually collapsed). Setting it here, before
    // setState, marks MainShell dirty in the same synchronous window as
    // this page's own rebuild, so both resolve in one frame.
    AppState.splitDetailOpenNotifier.value = true;
    setState(() {
      _selectedActivity = item;
      _selectedCategory = null;
      _categoryEvent = context.dispatchProcess(
        saveActionResponse: true,
        returnSavedResponse: true,
        GetServiceCategoriesAction(
          endpointFunc: () => GetServiceCategoriesAction.endpointFor(item),
        ),
      );
    });
  }

  void _closeDetails() {
    AppState.splitDetailOpenNotifier.value = false;
    setState(() {
      _selectedActivity = null;
      _selectedCategory = null;
    });
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(
      () => setState(() => _query = _searchController.text.trim()),
    );
  }

  @override
  void dispose() {
    // Leaving the page entirely (e.g. switching tabs) with a split still
    // open — don't leave the sidebar permanently collapsed with nothing
    // left to justify it.
    if (_selectedActivity != null) {
      AppState.splitDetailOpenNotifier.value = false;
    }
    _searchController.dispose();
    super.dispose();
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
    return MultiProcessListener(
      listeners: [
        dashboardRefreshListener,
        ProcessListenerConfig<GeneralFlowCategory>(
          event: () => _categoryEvent,
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
                final l10n = AppLocalizations.of(context)!;
                MessageUtil.displayErrorDialog(
                  context,
                  title: l10n.commonServiceUnavailableTitle,
                  message: l10n.commonServiceUnavailableMessage,
                );
                return;
              }

              setState(() => _selectedCategory = snapshot.data);
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
      child: MasterDetailLayout(
        detail: _selectedActivity == null || _selectedCategory == null
            ? null
            : ServicePage(
                // Without a key, switching the selection reuses the same
                // State — a stale `_category` (set by a prior pull-to-
                // refresh on a different activity) would then shadow the
                // new `widget.category` instead of a fresh State starting
                // from it. ActivityDatum extends Equatable.
                key: ValueKey(_selectedActivity),
                activityDatum: _selectedActivity!,
                category: _selectedCategory!,
                useScaffold: false,
                onBack: _closeDetails,
              ),
        master: _master(context),
      ),
    );
  }

  Widget _master(BuildContext context) {
    return MainLayout(
      backgroundColor: context.scaffoldBg,
      miniTitle: AppLocalizations.of(context)!.dashboardServicesHeader,
      onRefresh: refreshDashboardData,
      bottom: PreferredSize(
        preferredSize: Size(double.maxFinite, 60),
        child: Padding(
          padding: const .only(
            left: 20,
            right: 20,
            bottom: 10,
          ),
          child: FormInput(
            placeholder: AppLocalizations.of(context)!.commonSearch,
            controller: _searchController,
            suffix: Icon(Icons.search),
          ),
        ),
      ),
      builder: (_) => Builder(
        builder: (context) {
          final activities = _activities;
          final l10n = AppLocalizations.of(context)!;

          if (dashboardRefreshing && activities.isNotEmpty) {
            return SliverList.builder(
              itemCount: activities.length,
              itemBuilder: (_, _) => const Padding(
                padding: EdgeInsets.symmetric(vertical: 5),
                child: ListItemSkeleton(),
              ),
            );
          }

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
                  EmptyState(
                    svgAsset: SvgImages.emptyWallet,
                    title: searching
                        ? l10n.commonNoMatches
                        : l10n.beneficiariesEmptyServices,
                    subtitle: searching
                        ? l10n.servicesNoMatchQuery(_query)
                        : l10n.servicesNoneFound,
                  ),
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
                  onTap: () => _openService(item),
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
                    style: context.caption,
                  ),
                  trailing: Icon(Icons.chevron_right_outlined),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
