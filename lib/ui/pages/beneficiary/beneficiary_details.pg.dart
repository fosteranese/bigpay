import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/constants/am_doing.const.dart';
import 'package:bigpay/data/models/auth_data/activity.dart';
import 'package:bigpay/data/models/auth_data/activity_datum.dart';
import 'package:bigpay/data/models/auth_data/preview_datum.dart';
import 'package:bigpay/data/models/general_flow/general_flow_category.dart';
import 'package:bigpay/data/models/general_flow/general_flow_form_data.dart';
import 'package:bigpay/data/models/payee/payee.dart';
import 'package:bigpay/models/actions/beneficiary/delete_payee_action.dart';
import 'package:bigpay/models/actions/services/get_service_form_data_action.dart';
import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/confirm_sheet.dart';
import 'package:bigpay/ui/components/forms/button.dart';
import 'package:bigpay/ui/components/forms/outline_button.dart';
import 'package:bigpay/ui/components/process_builder.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/pages/process_flow/service_form.pg.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/utils/message.util.dart';

/// A pushed full page wrapping [BeneficiaryDetailsView] — used on every
/// device except a foldable in book mode (or a wide screen), where
/// [BeneficiariesPage] shows the same view inline in the second pane instead
/// (see [MasterDetailLayout]).
class BeneficiaryDetailsPage extends StatelessWidget {
  const BeneficiaryDetailsPage({super.key, this.payee});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/beneficiaries/details',
    name: 'beneficiary-details',
  );

  final Payee? payee;

  @override
  Widget build(BuildContext context) {
    return BeneficiaryDetailsView(payee: payee);
  }
}

/// A saved beneficiary's details, with the option to remove it — independent
/// of how it's hosted: a pushed page ([BeneficiaryDetailsPage], default back
/// behavior) or an inline pane in [BeneficiariesPage]'s split view ([onBack]
/// provided, clears the pane's selection instead of popping a route that was
/// never pushed).
class BeneficiaryDetailsView extends StatefulWidget {
  const BeneficiaryDetailsView({super.key, this.payee, this.onBack});

  final Payee? payee;
  final VoidCallback? onBack;

  @override
  State<BeneficiaryDetailsView> createState() => _BeneficiaryDetailsViewState();
}

class _BeneficiaryDetailsViewState extends State<BeneficiaryDetailsView> {
  ExecuteProcessEvent? _deleteEvent;

  /// The in-flight fetch of this beneficiary's form, correlated so a success
  /// opens the service form pre-filled with the payee.
  ExecuteProcessEvent? _sendEvent;

  /// Whether the in-flight fetch is for "edit & send" (true) or "send now"
  /// (false) — decides the [AmDoing] the service form runs with.
  bool _isEditingSend = false;

  /// "Send now": fetch the beneficiary's form definition, then open the
  /// service form pre-filled with the saved payee (see the listener in build).
  void _send() {
    _isEditingSend = false;
    _fetchForm();
  }

  /// "Edit & send": the same pre-filled form, but in edit mode — the form can
  /// correct the saved details, and submitting both updates the saved
  /// beneficiary (Payee/addPayee as an upsert) and pays them.
  void _editAndSend() {
    _isEditingSend = true;
    _fetchForm();
  }

  void _fetchForm() {
    final payee = widget.payee;
    if (payee?.formId == null) return;
    setState(() {
      _sendEvent = context.dispatchProcess(
        saveActionResponse: true,
        returnSavedResponse: true,
        GetServiceFormDataAction(
          payload: GetServiceFormDataActionPayload(
            formId: payee!.formId,
            insId: payee.formId,
          ),
          endpointFunc: () =>
              GetServiceFormDataAction.endpointFor(payee.activityType),
        ),
      );
    });
  }

  void _onFormFetched(BuildContext context, ProcessSnapshot snapshot) {
    final l10n = AppLocalizations.of(context)!;
    if (snapshot.isLoading && !snapshot.isSilent && !snapshot.isCached) {
      MessageUtil.displayLoading(context);
      return;
    } else if (!snapshot.isSilent && !snapshot.isCached) {
      MessageUtil.close(context);
    }

    if (snapshot.hasData && !(snapshot.isSilent && !snapshot.isCached)) {
      final formData = snapshot.data as GeneralFlowFormData?;
      if (!snapshot.isSilent &&
          !snapshot.isCached &&
          (formData?.fieldsDatum?.isEmpty ?? true)) {
        MessageUtil.displayErrorDialog(
          context,
          title: l10n.commonServiceUnavailableTitle,
          message: l10n.commonServiceUnavailableMessage,
        );
        return;
      }
      _sendEvent = null;
      final payee = widget.payee;
      AppRouter.router.push(
        ServiceFormPage.route.path,
        extra: {
          'activityDatum': ActivityDatum(
            activity: Activity(
              activityId: payee?.activityId,
              activityType: payee?.activityType,
              activityName: payee?.activityName,
              icon: payee?.icon,
            ),
          ),
          'category': const GeneralFlowCategory(),
          'formData': formData,
          'payee': payee,
          'amDoing': _isEditingSend
              ? AmDoing.editBeneficiary
              : AmDoing.transaction,
        },
      );
      return;
    }

    if (snapshot.hasError) {
      MessageUtil.displayErrorDialog(context, message: snapshot.error!.message);
    }
  }

  String _name(BuildContext context) =>
      widget.payee?.displayName ??
      AppLocalizations.of(context)!.beneficiariesFallbackName;

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '?';
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  /// Short label for the avatar — the backend's own [Payee.shortTitle] when
  /// present (matches umb), otherwise computed initials.
  String get _avatarLabel =>
      widget.payee?.shortTitle ?? _initials(_name(context));

  /// The saved field values to show, preferring the backend's display-ready
  /// `previewData` (label + value) and falling back to the raw `formData`
  /// keys (labelized, minus the amount — a beneficiary is a recipient, not a
  /// transaction).
  List<(String, String)> get _details {
    final preview = widget.payee?.previewData ?? const <PreviewDatum>[];
    if (preview.isNotEmpty) {
      return preview
          .where((e) => (e.value?.toString().isNotEmpty ?? false))
          .map((e) => (e.key ?? '', e.value ?? ''))
          .toList();
    }
    final data = widget.payee?.formData ?? const {};
    return data.entries
        .where((e) => (e.value?.toString().isNotEmpty ?? false))
        .where((e) => e.key.toLowerCase() != 'amount')
        .map((e) => (_label(e.key), e.value.toString()))
        .toList();
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showConfirmSheet(
      context,
      icon: Icons.person_remove_outlined,
      title: l10n.beneficiariesRemoveTitle,
      message: l10n.beneficiariesRemoveConfirm(_name(context)),
      confirmText: l10n.commonRemove,
    );
    if (!confirmed || !mounted) return;
    _deleteEvent = context.dispatchProcess(
      DeletePayeeAction(
        payload: DeletePayeePayload(payeeId: widget.payee?.payeeId),
      ),
    );
  }

  String _label(String key) {
    // "SourceAccount" -> "Source Account"
    final spaced = key.replaceAllMapped(
      RegExp(r'(?<=[a-z])(?=[A-Z])'),
      (m) => ' ',
    );
    return spaced.isEmpty
        ? key
        : '${spaced[0].toUpperCase()}${spaced.substring(1)}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final name = _name(context);
    final meta = <(String, String)>[
      if (widget.payee?.activityName?.isNotEmpty ?? false)
        (l10n.beneficiariesTransactionType, widget.payee!.activityName!),
      if (widget.payee?.formName?.isNotEmpty ?? false)
        (l10n.beneficiariesService, widget.payee!.formName!),
    ];
    final details = _details;

    return MultiProcessListener(
      listeners: [
        ProcessListenerConfig<bool>(
          event: () => _deleteEvent,
          listener: (context, snapshot) {
            if (snapshot.isLoading) {
              MessageUtil.displayLoading(context);
              return;
            }
            MessageUtil.close(context);

            if (snapshot.isSuccessful) {
              _deleteEvent = null;
              if (widget.onBack != null) {
                widget.onBack!();
              } else {
                AppRouter.router.pop();
              }
            } else if (snapshot.hasError) {
              _deleteEvent = null;
              MessageUtil.displayErrorDialog(
                context,
                message: snapshot.error!.message,
              );
            }
          },
        ),
        ProcessListenerConfig<GeneralFlowFormData>(
          event: () => _sendEvent,
          listener: _onFormFetched,
        ),
      ],
      child: MainLayout(
        useScaffold: widget.onBack == null,
        onBack: widget.onBack,
        bottomSize: 130,
        title: l10n.beneficiariesDetailsTitle,
        bottomNav: Column(
          mainAxisSize: .min,
          children: [
            if (widget.payee?.formId?.isNotEmpty ?? false) ...[
              FormButton(
                onPressed: _send,
                text: l10n.beneficiariesSendNow,
                icon: Icons.north_east,
                buttonIconAlignment: .left,
                iconSize: 20,
              ),
              const SizedBox(height: Spacing.sm),
              // Secondary action: correct the saved details, then pay.
              FormOutlineButton(
                onPressed: _editAndSend,
                text: l10n.beneficiariesEditAndSend,
                icon: Icons.edit_outlined,
                buttonIconAlignment: .left,
                iconSize: 20,
              ),
              const SizedBox(height: Spacing.sm),
            ],
            // Tertiary, not a filled red slab: removing is the rare action on
            // this page, and it confirms before doing anything.
            FormOutlineButton(
              onPressed: _delete,
              text: l10n.beneficiariesRemoveButton,
              foregroundColor: AppColors.danger,
              iconColor: AppColors.danger,
              icon: Icons.person_remove_outlined,
              buttonIconAlignment: .left,
              iconSize: 20,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            // Avatar in a white ring with a soft shadow — the umb "beneficiary
            // details" hero look (an initial avatar floating on the page).
            Center(
              child: Container(
                padding: const .all(4),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.10),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: context.avatarBg,
                  child: Text(_avatarLabel, style: context.header1),
                ),
              ),
            ),
            const SizedBox(height: Spacing.lg),
            Text(name, style: context.display2, textAlign: .center),
            const SizedBox(height: Spacing.lg),
            if (meta.isNotEmpty) ...[
              _sectionCard([
                for (final (index, entry) in meta.indexed) ...[
                  _detailRow(entry.$1, entry.$2, copyable: false),
                  if (index != meta.length - 1)
                    Divider(height: 1, color: context.divider),
                ],
              ]),
              const SizedBox(height: Spacing.md),
            ],
            _sectionCard([
              if (details.isEmpty)
                _detailRow(
                  l10n.beneficiariesRecipientLabel,
                  widget.payee?.value ?? '-',
                )
              else
                for (final (index, entry) in details.indexed) ...[
                  _detailRow(entry.$1, entry.$2),
                  if (index != details.length - 1)
                    Divider(height: 1, color: context.divider),
                ],
            ]),
          ],
        ),
      ),
    );
  }

  /// A card with rounded corners and a border, holding one or more rows with
  /// dividers between them — the umb "details" card look.
  Widget _sectionCard(List<Widget> children) {
    return Container(
      padding: const .symmetric(horizontal: Spacing.lg),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: .circular(16),
        border: .all(color: context.border),
      ),
      child: Column(mainAxisSize: .min, children: children),
    );
  }

  /// Label over value (reads better than a squeezed two-column row once
  /// values get long, e.g. account numbers), with an optional copy action
  /// since these are exactly the values people paste elsewhere.
  Widget _detailRow(String label, String value, {bool copyable = true}) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const .symmetric(vertical: Spacing.md),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(label, style: context.smallDetails),
                const SizedBox(height: 2),
                Text(value, style: context.p1Medium),
              ],
            ),
          ),
          if (copyable)
            IconButton(
              tooltip: l10n.commonCopy,
              icon: Icon(
                Icons.copy_rounded,
                size: 18,
                color: context.textSecondary,
              ),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: value));
                if (!mounted) return;
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(l10n.commonCopied)));
              },
            ),
        ],
      ),
    );
  }
}
