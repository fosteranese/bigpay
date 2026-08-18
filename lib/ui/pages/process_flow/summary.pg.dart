import 'package:flutter/material.dart';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/constants/activity_type.const.dart';
import 'package:bigpay/constants/am_doing.const.dart';
import 'package:bigpay/data/models/auth_data/activity_datum.dart';
import 'package:bigpay/data/models/general_flow/form_verification_response.dart';
import 'package:bigpay/data/models/general_flow/general_flow_category.dart';
import 'package:bigpay/data/models/general_flow/general_flow_fields_datum.dart';
import 'package:bigpay/data/models/general_flow/general_flow_form_data.dart';
import 'package:bigpay/data/models/general_flow/request_response.dart';
import 'package:bigpay/data/models/payee/payee.dart';
import 'package:bigpay/models/actions/beneficiary/add_payee_action.dart';
import 'package:bigpay/models/actions/services/process_request_action.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/forms.dart';
import 'package:bigpay/ui/components/process_builder.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/pages/beneficiary/beneficiaries.pg.dart';
import 'package:bigpay/ui/pages/history/transaction_details.pg.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/utils/authentication.util.dart';
import 'package:bigpay/utils/message.util.dart';

/// Confirmation screen shown after a form is verified: it renders the
/// verification's `previewData` (amount, charges, total, entered fields) and —
/// mirroring umb's `ConfirmationFormPage` — any remaining editable fields the
/// user still has to complete here.
///
/// The form screen only collects the fields needed to verify
/// (`requiredForVerification == 1`); the rest of the visible, editable fields
/// are gathered on this screen, then merged with the verified data into the
/// process request.
///
/// Continue processes the request — collecting an OTP/PIN first when the
/// verification says an auth factor is required.
class SummaryPage extends StatefulWidget {
  const SummaryPage({
    super.key,
    this.verification,
    this.formData,
    this.activityDatum,
    this.category,
    this.amDoing = AmDoing.transaction,
  });

  static PageRouteDefinition route = PageRouteDefinition(
    path: '/services/summary',
  );

  /// The `verifyForm` result. Nullable so a direct hit on the route degrades
  /// gracefully.
  final FormVerificationResponse? verification;
  final GeneralFlowFormData? formData;
  final ActivityDatum? activityDatum;
  final GeneralFlowCategory? category;

  /// Whether Continue processes a transaction or saves the form as a
  /// beneficiary.
  final AmDoing amDoing;

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  ExecuteProcessEvent? _processEvent;
  ExecuteProcessEvent? _payeeEvent;

  bool get _isAddBeneficiary => widget.amDoing == AmDoing.addBeneficiary;

  final _canContinue = ValueNotifier(true);

  /// Visible, editable fields that weren't needed for verification — collected
  /// on this screen. Matches umb's `ConfirmationFormPage._setupFormData`.
  late final List<(GeneralFlowFieldsDatum, TextEditingController, FocusNode)>
  _editableItems;

  /// Every other field (hidden, read-only, or already used for verification).
  /// Their values come from the verified data, not user input.
  late final List<GeneralFlowFieldsDatum> _preFields;

  @override
  void initState() {
    super.initState();

    final fields = widget.formData?.fieldsDatum ?? const [];

    bool isEditable(GeneralFlowFieldsDatum f) =>
        f.field?.fieldVisible == 1 &&
        f.field?.readOnly != 1 &&
        f.field?.requiredForVerification != 1;

    final editable = fields.where(isEditable).toList();
    _preFields = fields.where((f) => !isEditable(f)).toList();

    // Keep the amount at the top when it happens to be an editable field, to
    // match the form screen's ordering.
    final amountIndex = editable.indexWhere((f) => f.field?.isAmount == 1);
    if (amountIndex > 0) {
      editable.insert(0, editable.removeAt(amountIndex));
    }

    final verified = widget.verification?.formData ?? const {};
    _editableItems = editable.map((item) {
      final name = item.field?.fieldName;
      final existing = (name == null ? null : verified[name])?.toString();
      final text = (existing != null && existing.isNotEmpty)
          ? existing
          : (item.field?.defaultValue ?? '');
      final controller = TextEditingController(text: text)
        ..addListener(_recomputeCanContinue);
      return (item, controller, FocusNode());
    }).toList();

    _recomputeCanContinue();
  }

  @override
  void dispose() {
    for (final (_, controller, focusNode) in _editableItems) {
      controller.removeListener(_recomputeCanContinue);
      controller.dispose();
      focusNode.dispose();
    }
    _canContinue.dispose();
    super.dispose();
  }

  /// Continue stays enabled while every mandatory editable field has a value.
  void _recomputeCanContinue() {
    _canContinue.value = _editableItems.every((item) {
      final mandatory = item.$1.field?.fieldMandatory == 1;
      return !mandatory || item.$2.text.trim().isNotEmpty;
    });
  }

  /// Prefills the other editable fields from a selected payee's saved values,
  /// matching on field name (the backend stores the keys lower-camel).
  void _prefillFromPayee(Payee payee) {
    final saved = payee.formData;
    if (saved == null) return;

    for (final (datum, controller, _) in _editableItems) {
      final name = datum.field?.fieldName;
      if (name == null) continue;
      final value = saved[name] ?? saved[_lowerCamel(name)];
      if (value != null) controller.text = value.toString();
    }

    _recomputeCanContinue();
  }

  String _lowerCamel(String value) =>
      value.isEmpty ? value : '${value[0].toLowerCase()}${value.substring(1)}';

  /// The full form data for the process request: the verified data, with the
  /// pre-filled fields keyed by field name and the editable fields overlaid
  /// with what the user entered here. Mirrors umb's `getFormData`.
  Map<String, dynamic> _buildPayload() {
    final verified = widget.verification?.formData ?? const {};
    final payload = <String, dynamic>{};

    for (final datum in _preFields) {
      final name = datum.field?.fieldName;
      if (name == null) continue;
      payload[name] = verified[name] ?? datum.field?.defaultValue;
    }

    for (final (datum, controller, _) in _editableItems) {
      final name = datum.field?.fieldName;
      if (name == null) continue;
      payload[name] = controller.text.trim();
    }

    return {...verified, ...payload};
  }

  void _continue() {
    FocusScope.of(context).unfocus();

    final payload = _buildPayload();
    final authModes = widget.verification?.authMode ?? const [];

    if (authModes.isNotEmpty) {
      AuthenticationUtil.start(
        authModes: authModes,
        payload: payload,
        complete: ({otp, required payload, pin, secretAnswer}) {
          // Dismiss the auth dialog before processing.
          AppRouter.router.pop();
          _process(
            otp: otp,
            payload: payload,
            pin: pin,
            secretAnswer: secretAnswer,
          );
        },
      );
      return;
    }

    _process(payload: payload);
  }

  void _process({
    String? otp,
    required Map<String, dynamic> payload,
    String? pin,
    String? secretAnswer,
  }) {
    final paymentMode =
        (payload['SourceAccount'] ?? payload['sourceAccount'] ?? '').toString();

    final actionPayload = ProcessRequestActionPayload(
      activityId: widget.activityDatum?.activity?.activityId,
      formId: widget.formData?.form?.formId,
      formData: payload,
      paymentMode: paymentMode,
      otp: otp,
      pin: pin,
      secretAnswer: secretAnswer,
    );

    // Same payload either way — a beneficiary is just a saved, unprocessed
    // request.
    if (_isAddBeneficiary) {
      _payeeEvent = context.dispatchProcess(
        AddPayeeAction(payload: actionPayload),
      );
      return;
    }

    _processEvent = context.dispatchProcess(
      ProcessRequestAction(
        payload: actionPayload,
        endpointFunc: _processEndpoint,
      ),
    );
  }

  String _processEndpoint() {
    switch (widget.formData?.form?.activityType) {
      case ActivityTypesConst.fblCollect:
        return '/FBLCollect/processRequest';
      case ActivityTypesConst.quickFlow:
      case ActivityTypesConst.quickFlowAlt:
        return '/QuickFlow/processRequest';
      case ActivityTypesConst.fblOnline:
      case ActivityTypesConst.enquiry:
      default:
        return '/FBLOnline/processRequest';
    }
  }

  /// (title, value) rows: the service name followed by the server's preview
  /// rows. Rows without a value are dropped.
  List<(String, String)> get _rows {
    final rows = <(String, String)>[];

    final service =
        widget.formData?.form?.formName ??
        widget.activityDatum?.activity?.activityName ??
        '';
    if (service.isNotEmpty) {
      rows.add(('Service', service));
    }

    for (final item in widget.verification?.previewData ?? const []) {
      final key = item.key;
      final value = item.value;
      if (key == null || value == null || value.isEmpty) continue;
      rows.add((key, value));
    }

    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final rows = _rows;

    return MultiProcessListener(
      listeners: [
        ProcessListenerConfig<RequestResponse>(
          event: () => _processEvent,
          listener: (context, snapshot) {
            if (snapshot.isLoading) {
              MessageUtil.displayLoading(context);
              return;
            } else {
              MessageUtil.close(context);
            }

            if (snapshot.isSuccessful) {
              _processEvent = null;
              AppRouter.router.push(
                TransactionDetailsPage.route.path,
                extra: snapshot.data,
              );
              return;
            }

            if (snapshot.hasError) {
              _processEvent = null;
              MessageUtil.displayErrorDialog(
                context,
                message: snapshot.error!.message,
              );
            }
          },
        ),
        // Add-beneficiary saves the same payload via Payee/addPayee; on success
        // return to the beneficiaries list.
        ProcessListenerConfig<bool>(
          event: () => _payeeEvent,
          listener: (context, snapshot) {
            if (snapshot.isLoading) {
              MessageUtil.displayLoading(context);
              return;
            } else {
              MessageUtil.close(context);
            }

            if (snapshot.isSuccessful) {
              _payeeEvent = null;
              MessageUtil.displaySuccessDialog(
                context,
                message: snapshot.message ?? 'Beneficiary saved.',
                onOk: () =>
                    AppRouter.router.go(BeneficiariesPage.route.path),
              );
              return;
            }

            if (snapshot.hasError) {
              _payeeEvent = null;
              MessageUtil.displayErrorDialog(
                context,
                message: snapshot.error!.message,
              );
            }
          },
        ),
      ],
      child: MainLayout(
        subtitleWidget: Column(
          children: [
            Text(
              _isAddBeneficiary ? 'Beneficiary Summary' : 'Transaction Summary',
              textAlign: .center,
              style: context.display2,
            ),
            const SizedBox(height: 10),
            Text(
              _isAddBeneficiary
                  ? 'Confirm the beneficiary details before you save'
                  : 'Kindly confirm the transaction details before you proceed',
              textAlign: .center,
              style: context.smallDetails,
            ),
          ],
        ),
        bottomNav: ValueListenableBuilder(
          valueListenable: _canContinue,
          builder: (context, canContinue, child) {
            return FormButton(
              enabled: canContinue,
              onPressed: _continue,
              text: _isAddBeneficiary ? 'Save Beneficiary' : 'Continue',
            );
          },
        ),
        child: Column(
          mainAxisSize: .min,
          crossAxisAlignment: .stretch,
          children: [
            Container(
              padding: .all(20),
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: .circular(12),
              ),
              child: Column(
                mainAxisSize: .min,
                mainAxisAlignment: .start,
                crossAxisAlignment: .center,
                children: [
                  for (final (index, (title, value)) in rows.indexed) ...[
                    TransactionDetailsItem(title: title, value: value),
                    if (index != rows.length - 1)
                      Divider(color: context.divider),
                  ],
                ],
              ),
            ),
            if (_editableItems.isNotEmpty) ...[
              const SizedBox(height: 20),
              ..._buildEditableFields,
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> get _buildEditableFields {
    final items = <Widget>[];
    for (final (index, (datum, controller, focusNode))
        in _editableItems.indexed) {
      final isLast = index == _editableItems.length - 1;
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
                _editableItems[index + 1].$3.requestFocus();
              }
            },
          ),
        ),
      );
    }
    return items;
  }
}
