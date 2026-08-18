import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/constants/activity_type.const.dart';
import 'package:bigpay/constants/am_doing.const.dart';
import 'package:bigpay/data/models/auth_data/activity_datum.dart';
import 'package:bigpay/data/models/general_flow/general_flow_category.dart';
import 'package:bigpay/models/actions/services/get_service_categories_action.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/forms.dart';
import 'package:bigpay/ui/components/process_builder.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/pages/process_flow/service.pg.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/utils/app_state.util.dart';
import 'package:bigpay/utils/message.util.dart';

/// The service picker for adding a beneficiary. Picking a service loads its
/// forms and continues the normal service flow in [AmDoing.addBeneficiary]
/// mode, so the confirmation step saves the payee instead of paying.
///
/// It uses a local dispatch (not the static [GetServiceCategoriesAction.event])
/// so the dashboard's central listener — which would open the service for a
/// transaction — doesn't also fire.
class AddBeneficiaryPage extends StatefulWidget {
  const AddBeneficiaryPage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/beneficiaries/add',
    name: 'add-beneficiary',
  );

  @override
  State<AddBeneficiaryPage> createState() => _AddBeneficiaryPageState();
}

class _AddBeneficiaryPageState extends State<AddBeneficiaryPage> {
  final _searchController = TextEditingController();
  String _query = '';

  ExecuteProcessEvent? _event;
  ActivityDatum? _selected;

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

  void _openService(ActivityDatum item) {
    _selected = item;
    _event = context.dispatchProcess(
      saveActionResponse: true,
      returnSavedResponse: true,
      GetServiceCategoriesAction(
        endpointFunc: () {
          if (item.activity?.endpoint?.isNotEmpty ?? false) {
            return item.activity!.endpoint!;
          }
          switch (item.activity?.activityType) {
            case ActivityTypesConst.fblCollect:
              return '/FBLCollect/categories/${item.activity?.activityId}';
            case ActivityTypesConst.quickFlow:
            case ActivityTypesConst.quickFlowAlt:
              return '/QuickFlow/categories/${item.activity?.activityId}';
            case ActivityTypesConst.fblOnline:
            case ActivityTypesConst.enquiry:
            default:
              return '/FBLOnline/categories/${item.activity?.activityId}';
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProcessListener<GeneralFlowCategory>(
      event: () => _event,
      listener: (context, snapshot) {
        if (snapshot.isLoading && !snapshot.isSilent && !snapshot.isCached) {
          MessageUtil.displayLoading(context);
          return;
        } else if (!snapshot.isSilent && !snapshot.isCached) {
          MessageUtil.close(context);
        }

        if (snapshot.hasData && !(snapshot.isSilent && !snapshot.isCached)) {
          if (!snapshot.isSilent &&
              !snapshot.isCached &&
              (snapshot.data?.forms?.isEmpty ?? true)) {
            MessageUtil.displayErrorDialog(
              context,
              title: 'Service Unavailable',
              message: 'This service is currently not available',
            );
            return;
          }

          _event = null;
          AppRouter.router.push(
            ServicePage.route.path,
            extra: {
              'activityDatum': _selected,
              'category': snapshot.data,
              'amDoing': AmDoing.addBeneficiary,
            },
          );
          return;
        }

        if (snapshot.hasError) {
          MessageUtil.displayErrorDialog(
            context,
            message: snapshot.error!.message,
          );
        }
      },
      child: MainLayout(
        backgroundColor: context.scaffoldBg,
        title: 'Add Beneficiary',
        subtitle: 'Choose a service to save a beneficiary for',
        bottom: PreferredSize(
          preferredSize: Size(double.maxFinite, 60),
          child: Padding(
            padding: const .only(left: 20, right: 20, bottom: 10),
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
              return SliverFillRemaining(
                fillOverscroll: true,
                hasScrollBody: false,
                child: Column(
                  mainAxisAlignment: .center,
                  children: [
                    const Spacer(flex: 3),
                    SvgPicture.asset('assets/img/empty-wallet.svg'),
                    Text(
                      _query.isNotEmpty ? 'No matches' : 'Empty Services',
                      style: context.p1Bold,
                    ),
                    const Spacer(flex: 6),
                  ],
                ),
              );
            }

            return SliverList.builder(
              itemCount: activities.length,
              itemBuilder: (context, index) {
                final item = activities[index];
                return Padding(
                  padding: const .symmetric(horizontal: 20, vertical: 5),
                  child: ListTile(
                    onTap: () => _openService(item),
                    contentPadding: .symmetric(horizontal: 15),
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
      ),
    );
  }
}
