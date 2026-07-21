import 'package:bigpay/data/models/general_flow/general_flow_category.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/constants/activity_type.const.dart';
import 'package:bigpay/data/models/auth_data/activity_datum.dart';
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

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/services',
  );

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  ExecuteProcessEvent? mainEvent;
  ActivityDatum? _activityDatum;

  @override
  Widget build(BuildContext context) {
    return ProcessListener<GeneralFlowCategory>(
      event: () => mainEvent,
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

          AppRouter.router.push(
            ServicePage.route.path,
            extra: {
              'activityDatum': _activityDatum,
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
      child: MainLayout(
        backgroundColor: Color(0xffEEF0FA),
        miniTitle: 'Services',
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
              controller: TextEditingController(),
              suffix: Icon(Icons.search),
            ),
          ),
        ),
        builder: (_) => Builder(
          builder: (context) {
            if (AppState.currentUser?.activities?.isEmpty ?? false) {
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
                      'Empty Services',
                      style: AppTypography.p1Bold,
                    ),
                    Text(
                      'No Services found',
                      style: AppTypography.caption,
                    ),
                    Spacer(flex: 6),
                  ],
                ),
              );
            }

            return SliverList.builder(
              itemCount: AppState.currentUser?.activities?.length ?? 0,
              itemBuilder: (context, index) {
                final item =
                    AppState.currentUser?.activities![index] as ActivityDatum;
                return Padding(
                  padding: const .symmetric(
                    horizontal: 20,
                    vertical: 5,
                  ),
                  child: ListTile(
                    onTap: () {
                      _activityDatum = item;
                      mainEvent = context.dispatchProcess(
                        saveActionResponse: true,
                        returnSavedResponse: true,
                        GetServiceCategoriesAction(
                          endpointFunc: () {
                            if (item.activity?.endpoint?.isNotEmpty ?? false) {
                              return item.activity!.endpoint!;
                            }

                            switch (item.activity?.activityType) {
                              case ActivityTypesConst.fblOnline:
                              case ActivityTypesConst.enquiry:
                                return '/FBLOnline/categories/${item.activity?.activityId}';

                              case ActivityTypesConst.fblCollect:
                                return '/FBLCollect/categories/${item.activity?.activityId}';

                              case ActivityTypesConst.quickFlow:
                              case ActivityTypesConst.quickFlowAlt:
                                return '/QuickFlow/categories/${item.activity?.activityId}';

                              default:
                                return '/FBLOnline/categories/${item.activity?.activityId}';
                            }
                          },
                        ),
                      );
                    },
                    contentPadding: .symmetric(
                      horizontal: 15,
                    ),
                    tileColor: AppColors.white,
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
                      style: AppTypography.header4,
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
