import 'package:bigpay/ui/pages/kyc/kyc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/constants/am_doing.const.dart';
import 'package:bigpay/data/models/auth_data/activity_datum.dart';
import 'package:bigpay/data/models/general_flow/general_flow_category.dart';
import 'package:bigpay/data/models/general_flow/general_flow_form.dart';
import 'package:bigpay/data/models/general_flow/general_flow_form_data.dart';
import 'package:bigpay/models/actions/services/get_service_categories_action.dart';
import 'package:bigpay/models/actions/services/get_service_form_data_action.dart';
import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/process_builder.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/pages/process_flow/service_form.pg.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/utils/app_state.util.dart';
import 'package:bigpay/utils/message.util.dart';

class ServicePage extends StatefulWidget {
  const ServicePage({
    super.key,
    required this.activityDatum,
    required this.category,
    this.amDoing = AmDoing.transaction,
    this.useScaffold = true,
    this.onBack,
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

  /// Clears the split pane's selection instead of popping a route — for
  /// inline pane usage (see [useScaffold]), where there's nothing to pop
  /// (the services list is still the top route). Left null for pushed-page
  /// usage, which keeps the default back-pops-the-route behavior.
  final VoidCallback? onBack;

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

  List<GeneralFlowForm> get _forms =>
      (_category ?? widget.category).forms ?? const [];

  /// A service with a single form has nothing to choose on this page — open
  /// that form straight away, and (as a pushed page) swap this page out of
  /// the stack so back from the form doesn't land on a one-item list. Inline
  /// in a split pane there's no route of ours to replace, so it just pushes.
  bool get _skipToForm => _forms.length == 1;

  @override
  void initState() {
    super.initState();
    if (_skipToForm) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _openForm(_forms.first);
      });
    }
  }

  void _openForm(GeneralFlowForm item) {
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
              GetServiceFormDataAction.endpointFor(item.activityType),
        ),
      );
    };
    Kyc.onSuccess!.call();
    // Ties the retry to this request: a 6000 from anything else must not
    // re-run it after verification.
    Kyc.retryEvent = mainEvent;
  }

  @override
  Widget build(BuildContext context) {
    final forms = _forms;
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

              final extra = {
                'activityDatum': widget.activityDatum,
                'category': widget.category,
                'formData': snapshot.data,
                'amDoing': widget.amDoing,
              };
              if (_skipToForm && widget.useScaffold) {
                AppRouter.router.pushReplacement(
                  ServiceFormPage.route.path,
                  extra: extra,
                );
              } else {
                AppRouter.router.push(ServiceFormPage.route.path, extra: extra);
              }
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
      child: MainLayout(
        useScaffold: widget.useScaffold,
        onBack: widget.onBack,
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
                onTap: () => _openForm(item),
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
}
