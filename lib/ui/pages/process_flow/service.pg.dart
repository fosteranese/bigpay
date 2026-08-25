import 'package:bigpay/ui/pages/kyc/kyc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/constants/am_doing.const.dart';
import 'package:bigpay/constants/status.const.dart';
import 'package:bigpay/data/models/auth_data/activity_datum.dart';
import 'package:bigpay/data/models/general_flow/general_flow_category.dart';
import 'package:bigpay/data/models/general_flow/general_flow_form_data.dart';
import 'package:bigpay/models/actions/services/get_service_categories_action.dart';
import 'package:bigpay/models/actions/services/get_service_form_data_action.dart';
import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/forms.dart';
import 'package:bigpay/ui/components/process_builder.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/pages/kyc/intro-kyc.pg.dart';
import 'package:bigpay/ui/pages/process_flow/service_form.pg.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/utils/app_modal.dart';
import 'package:bigpay/utils/app_state.util.dart';
import 'package:bigpay/utils/message.util.dart';

class ServicePage extends StatefulWidget {
  const ServicePage({
    super.key,
    required this.activityDatum,
    required this.category,
    this.amDoing = AmDoing.transaction,
    this.useScaffold = true,
  });
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/services/service',
  );
  final ActivityDatum activityDatum;
  final GeneralFlowCategory category;
  final AmDoing amDoing;

  /// False to render without an owning Scaffold — for use as inline pane
  /// content in a [MasterDetailLayout] detail pane (see [ServicesPage]), where
  /// a Scaffold nested inside the pane's Expanded silently fails to render
  /// its body on a real device. Pushed-page usage (the default) is
  /// unaffected.
  final bool useScaffold;

  @override
  State<ServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  ExecuteProcessEvent? mainEvent;

  /// The in-flight category refresh, correlated by the listener in [build].
  ExecuteProcessEvent? _refreshEvent;

  /// The forms shown on this page. Seeded from the category passed in, then
  /// replaced by a pull-to-refresh.
  GeneralFlowCategory? _category;

  /// Pull-to-refresh: re-fetches this activity's categories/forms and holds the
  /// spinner until they land.
  Future<void> _onRefresh() async {
    final event = context.dispatchProcess(
      saveActionResponse: true,
      returnSavedResponse: true,
      GetServiceCategoriesAction(
        endpointFunc: () =>
            GetServiceCategoriesAction.endpointFor(widget.activityDatum),
      ),
    );
    setState(() => _refreshEvent = event);
    await context.awaitProcess(event);
  }

  @override
  Widget build(BuildContext context) {
    final forms = (_category ?? widget.category).forms ?? const [];
    return MultiProcessListener(
      listeners: [
        ProcessListenerConfig<GeneralFlowCategory>(
          event: () => _refreshEvent,
          listener: (context, snapshot) {
            if (snapshot.hasData) {
              setState(() => _category = snapshot.data);
            }
          },
        ),
        ProcessListenerConfig<GeneralFlowFormData>(
          event: () => mainEvent,
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
                final l10n = AppLocalizations.of(context)!;
                MessageUtil.displayErrorDialog(
                  context,
                  title: l10n.commonServiceUnavailableTitle,
                  message: l10n.commonServiceUnavailableMessage,
                );
                return;
              }

              AppRouter.router.push(
                ServiceFormPage.route.path,
                extra: {
                  'activityDatum': widget.activityDatum,
                  'category': widget.category,
                  'formData': snapshot.data,
                  'amDoing': widget.amDoing,
                },
              );
              return;
            }

            if (snapshot.hasError) {
              if (snapshot.error?.code == StatusCodeConstants.verifyIdentify) {
                _verify();
                return;
              }

              MessageUtil.displayErrorDialog(
                context,
                message: snapshot.error!.message,
              );
              return;
            }
          },
        ),
      ],
      child: MainLayout(
        useScaffold: widget.useScaffold,
        bottomSize: 50,
        title: widget.activityDatum.activity?.activityName ?? '',
        onRefresh: _onRefresh,
        builder: (_) => SliverList.builder(
          itemCount: forms.length,
          itemBuilder: (context, index) {
            final item = forms[index];
            return Padding(
              padding: const .symmetric(
                horizontal: 20,
                vertical: 5,
              ),
              child: ListTile(
                onTap: () {
                  Kyc.onSuccess = () {
                    mainEvent = context.dispatchProcess(
                      saveActionResponse: true,
                      returnSavedResponse: true,
                      GetServiceFormDataAction(
                        payload: GetServiceFormDataActionPayload(
                          formId: item.formId,
                          insId: item.formId,
                        ),
                        endpointFunc: () =>
                            GetServiceFormDataAction.endpointFor(
                              item.activityType,
                            ),
                      ),
                    );
                  };
                  Kyc.onSuccess!.call();
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
                      '${AppState.currentUser?.imageBaseUrl}${AppState.currentUser?.imageDirectory}/${item.icon}',
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
                  item.formName ?? '',
                  style: context.header4,
                ),
                subtitle: Text(
                  item.description ?? '',
                  style: context.caption,
                ),
                trailing: Icon(Icons.chevron_right_outlined),
              ),
            );
          },
        ),
      ),
    );
  }

  void _verify() {
    final l10n = AppLocalizations.of(context)!;
    AppModal.showBottomModal(
      context,
      label: l10n.servicesVerifyIdentityTitle,
      padding: .all(20),
      children: [
        SizedBox(height: 10),
        Text(
          l10n.servicesVerifyIdentityMessage,
          style: context.smallDetails.copyWith(
            color: context.textPrimary,
          ),
        ),
        SizedBox(height: Spacing.xl),
        Align(
          alignment: .bottomRight,
          child: Text(
            l10n.servicesPercentComplete,
            style: context.caption,
          ),
        ),
        SizedBox(height: 5),
        Container(
          height: 8,
          alignment: .centerLeft,
          decoration: BoxDecoration(
            borderRadius: .circular(20),
            gradient: LinearGradient(
              begin: Alignment.topCenter, // 180deg points from top to bottom
              end: Alignment.bottomCenter,
              stops: [
                0.0,
                0.5052,
                1.0,
              ], // Exact CSS percentage stops
              colors: [
                context.textTertiary,
                context.border,
                context.divider,
              ],
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraint) {
              return Container(
                width: 0.6 * constraint.maxWidth,
                decoration: BoxDecoration(
                  borderRadius: .circular(20),
                  color: context.accentGreen,
                ),
              );
            },
          ),
        ),
        SizedBox(height: 30),
        FormButton(
          height: 45,
          onPressed: () {
            Kyc.route = ServicePage.route;
            AppRouter.router.pop();
            AppRouter.router.push(IntroKycPage.route.path);
          },
          text: l10n.servicesStartVerification,
        ),
      ],
    );
  }
}
