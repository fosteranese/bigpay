import 'package:flutter/material.dart';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/constants/activity_type.const.dart';
import 'package:bigpay/constants/am_doing.const.dart';
import 'package:bigpay/data/models/auth_data/activity_datum.dart';
import 'package:bigpay/data/models/general_flow/form_verification_response.dart';
import 'package:bigpay/data/models/general_flow/general_flow_category.dart';
import 'package:bigpay/data/models/general_flow/general_flow_fields_datum.dart';
import 'package:bigpay/data/models/general_flow/general_flow_form_data.dart';
import 'package:bigpay/data/models/payee/payee.dart';
import 'package:bigpay/models/actions/services/get_service_form_data_action.dart';
import 'package:bigpay/models/actions/services/verify_service_form_action.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/forms.dart';
import 'package:bigpay/ui/components/process_builder.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/pages/process_flow/summary.pg.dart';
import 'package:bigpay/utils/message.util.dart';

class ServiceFormPage extends StatefulWidget {
  const ServiceFormPage({
    super.key,
    required this.activityDatum,
    required this.category,
    required this.formData,
    this.amDoing = AmDoing.transaction,
  });
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/services/form',
  );
  final ActivityDatum activityDatum;
  final GeneralFlowCategory category;
  final GeneralFlowFormData formData;
  final AmDoing amDoing;

  @override
  State<ServiceFormPage> createState() => _ServiceFormPageState();
}

class _ServiceFormPageState extends State<ServiceFormPage> {
  final _canSubmit = ValueNotifier(false);
  ExecuteProcessEvent? _submitEvent;
  Map<String, dynamic> _formData = {};

  /// The form definition currently on screen. Seeded from the one passed in,
  /// then replaced by a pull-to-refresh.
  late GeneralFlowFormData _form;

  /// The in-flight form-definition refresh, correlated by the listener.
  ExecuteProcessEvent? _refreshEvent;

  List<(GeneralFlowFieldsDatum, TextEditingController, FocusNode)> _formItems =
      [];

  @override
  void initState() {
    super.initState();
    _form = widget.formData;
    _buildFormItems();
    _recomputeCanSubmit();
  }

  /// Builds the editable field list from [_form]. Disposes any prior controllers
  /// first, so it's safe to call again on a refresh.
  void _buildFormItems() {
    _disposeFormItems();

    // Matching umb's `_generateField`: when the form needs verification, only
    // the fields required for it are collected here — the rest are gathered on
    // the summary/confirmation screen. Otherwise every visible, editable field
    // is shown. The amount field is floated to the top when present.
    final requireVerification = _form.form?.requireVerification == 1;
    final visible = (_form.fieldsDatum ?? [])
        .where(
          (f) =>
              f.field?.fieldVisible == 1 &&
              f.field?.readOnly != 1 &&
              (!requireVerification || f.field?.requiredForVerification == 1),
        )
        .toList();
    final amountIndex = visible.indexWhere((f) => f.field?.isAmount == 1);
    if (amountIndex > 0) {
      visible.insert(0, visible.removeAt(amountIndex));
    }

    _formItems = visible.map((item) {
      final controller = TextEditingController(
        text: item.field?.defaultValue ?? '',
      )..addListener(_recomputeCanSubmit);
      return (item, controller, FocusNode());
    }).toList();
  }

  void _disposeFormItems() {
    for (final (_, controller, focusNode) in _formItems) {
      controller.removeListener(_recomputeCanSubmit);
      controller.dispose();
      focusNode.dispose();
    }
  }

  /// Pull-to-refresh: re-fetches this form's definition and rebuilds the fields,
  /// holding the spinner until it lands. Any half-entered values are reset to
  /// the fresh defaults.
  Future<void> _onRefresh() async {
    final event = context.dispatchProcess(
      GetServiceFormDataAction(
        payload: GetServiceFormDataActionPayload(
          formId: _form.form?.formId,
          insId: _form.form?.formId,
        ),
        endpointFunc: _formDataEndpoint,
      ),
    );
    setState(() => _refreshEvent = event);
    await context.awaitProcess(event);
  }

  String _formDataEndpoint() {
    switch (_form.form?.activityType) {
      case ActivityTypesConst.fblCollect:
        return '/FBLCollect/formsDataByInsId';
      case ActivityTypesConst.quickFlow:
      case ActivityTypesConst.quickFlowAlt:
        return '/QuickFlow/formDataByFormId';
      case ActivityTypesConst.fblOnline:
      case ActivityTypesConst.enquiry:
      default:
        return '/FBLOnline/formDataByFormId';
    }
  }

  /// Submit is enabled once every mandatory visible field has a value.
  void _recomputeCanSubmit() {
    _canSubmit.value = _formItems.every((item) {
      final mandatory = item.$1.field?.fieldMandatory == 1;
      return !mandatory || item.$2.text.trim().isNotEmpty;
    });
  }

  /// Prefills the other fields from a selected payee's saved values, matching
  /// on field name (the backend stores the keys lower-camel).
  void _prefillFromPayee(Payee payee) {
    final saved = payee.formData;
    if (saved == null) return;

    for (final (datum, controller, _) in _formItems) {
      final name = datum.field?.fieldName;
      if (name == null) continue;
      final value = saved[name] ?? saved[_lowerCamel(name)];
      if (value != null) controller.text = value.toString();
    }

    _recomputeCanSubmit();
  }

  String _lowerCamel(String value) =>
      value.isEmpty ? value : '${value[0].toLowerCase()}${value.substring(1)}';

  /// Verifies the filled form on the backend; the confirmation it returns is
  /// shown on the summary screen (see the listener in [build]).
  void _submit() {
    FocusScope.of(context).unfocus();
    _form.fieldsDatum?.forEach((item) {
      _formData[item.field?.fieldName ?? ''] = item.field?.defaultValue ?? '';
    });

    _formData.addAll(<String, dynamic>{
      for (final (datum, controller, _) in _formItems)
        if (datum.field?.fieldName != null)
          datum.field!.fieldName!: controller.text.trim(),
    });

    _submitEvent = context.dispatchProcess(
      VerifyServiceFormAction(
        payload: VerifyServiceFormActionPayload(
          insId: _form.institution?.insId,
          formId: _form.form?.formId,
          formData: _formData,
        ),
        endpointFunc: _verifyEndpoint,
      ),
    );
  }

  String _verifyEndpoint() {
    switch (_form.form?.activityType) {
      case ActivityTypesConst.fblCollect:
        return '/FBLCollect/verifyForm';
      case ActivityTypesConst.quickFlow:
      case ActivityTypesConst.quickFlowAlt:
        return '/QuickFlow/verifyForm';
      case ActivityTypesConst.fblOnline:
      case ActivityTypesConst.enquiry:
      default:
        return '/FBLOnline/verifyForm';
    }
  }

  @override
  void dispose() {
    _disposeFormItems();
    _canSubmit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProcessListener(
      listeners: [
        // Pull-to-refresh result: rebuild the fields from the fresh definition.
        ProcessListenerConfig<GeneralFlowFormData>(
          event: () => _refreshEvent,
          listener: (context, snapshot) {
            if (snapshot.hasData &&
                (snapshot.data?.fieldsDatum?.isNotEmpty ?? false)) {
              setState(() {
                _form = snapshot.data!;
                _buildFormItems();
              });
              _recomputeCanSubmit();
            }
          },
        ),
        ProcessListenerConfig<FormVerificationResponse>(
          event: () => _submitEvent,
          listener: (context, snapshot) {
            if (snapshot.isLoading) {
              MessageUtil.displayLoading(context);
              return;
            } else {
              MessageUtil.close(context);
            }

            if (snapshot.hasData) {
              _submitEvent = null;
              AppRouter.router.push(
                SummaryPage.route.path,
                extra: {
                  'activityDatum': widget.activityDatum,
                  'category': widget.category,
                  'formData': _form,
                  'amDoing': widget.amDoing,
                  'verification': snapshot.data,
                },
              );
              return;
            }

            if (snapshot.hasError) {
              _submitEvent = null;
              MessageUtil.displayErrorDialog(
                context,
                message: snapshot.error!.message,
              );
            }
          },
        ),
      ],
      child: MainLayout(
        bottomSize: 72,
        title: _form.form?.formName ?? '',
        subtitle: _form.form?.description ?? '',
        onRefresh: _onRefresh,
        bottomNav: ValueListenableBuilder(
          valueListenable: _canSubmit,
          builder: (context, canSubmit, child) {
            return FormButton(
              enabled: canSubmit,
              onPressed: _submit,
              text: 'Submit',
            );
          },
        ),
        child: Form(
          child: Column(
            mainAxisSize: .min,
            mainAxisAlignment: .start,
            crossAxisAlignment: .center,
            children: _buildFormFields,
          ),
        ),
      ),
    );
  }

  List<Widget> get _buildFormFields {
    final items = <Widget>[];
    for (final (index, (datum, controller, focusNode)) in _formItems.indexed) {
      final isLast = index == _formItems.length - 1;
      items.add(
        Padding(
          padding: const .only(bottom: 15),
          child: FormFieldInput(
            datum: datum,
            controller: controller,
            focusNode: focusNode,
            isLast: isLast,
            onPayeeSelected: _prefillFromPayee,
            next: (_) {
              if (isLast) {
                FocusScope.of(context).unfocus();
              } else {
                _formItems[index + 1].$3.requestFocus();
              }
            },
          ),
        ),
      );
    }
    return items;
  }
}
