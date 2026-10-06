import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/data/models/payee/payee.dart';
import 'package:bigpay/models/actions/beneficiary/delete_payee_action.dart';
import 'package:bigpay/models/actions/beneficiary/get_payees_action.dart';
import 'package:bigpay/models/actions/beneficiary/pay_payee_action.dart';
import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/forms.dart';
import 'package:bigpay/ui/components/process_builder.dart';
import 'package:bigpay/ui/components/skeleton/variants.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/pages/beneficiary/add_beneficiary.pg.dart';
import 'package:bigpay/ui/pages/beneficiary/beneficiary_details.pg.dart';
import 'package:bigpay/ui/components/confirm_sheet.dart';
import 'package:bigpay/ui/components/empty_state.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/assets/app_images.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/ui/theme/foldable.dart';
import 'package:bigpay/utils/authentication.util.dart';
import 'package:bigpay/utils/message.util.dart';

class BeneficiariesPage extends StatefulWidget {
  const BeneficiariesPage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/beneficiaries',
  );

  @override
  State<BeneficiariesPage> createState() => _BeneficiariesPageState();
}

class _BeneficiariesPageState extends State<BeneficiariesPage> with RouteAware {
  final _searchController = TextEditingController();

  ExecuteProcessEvent? _event;
  ExecuteProcessEvent? _deleteEvent;
  List<Payee>? _payees;
  String _query = '';

  /// In-flight "send now" payment (Payee/payPayee) from a row's quick action,
  /// correlated so a success shows the confirmation.
  ExecuteProcessEvent? _payEvent;

  /// The beneficiary shown in the detail pane in split view
  /// ([MasterDetailLayout]) — unused (and the pane not shown) on any other
  /// device, where opening a beneficiary pushes [BeneficiaryDetailsPage]
  /// instead.
  Payee? _selectedPayee;

  /// "Send now" from a list row: the final submission — authorize with a PIN
  /// and pay the saved beneficiary directly (`Payee/payPayee`); no form opens.
  void _send(Payee payee) {
    if (payee.payeeId == null) return;
    AuthenticationUtil.pin(
      data: const {},
      allowBiometric: true,
      onSuccess: (pin) {
        if (!mounted) return;
        _payEvent = context.dispatchProcess(
          PayPayeeAction(
            payload: PayPayeeActionPayload(payeeId: payee.payeeId, pin: pin),
          ),
        );
      },
    );
  }

  void _openDetails(Payee payee) {
    if (context.usesSplitView) {
      setState(() => _selectedPayee = payee);
      return;
    }

    AppRouter.router.push(
      BeneficiaryDetailsPage.route.path,
      extra: payee,
    );
  }

  void _closeDetails() {
    setState(() => _selectedPayee = null);
    _load();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(
      () => setState(() => _query = _searchController.text.trim()),
    );
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      appRouteObserver.subscribe(this, route);
    }
  }

  // Returning from the details screen — a beneficiary may have been deleted.
  @override
  void didPopNext() => setState(_load);

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    _searchController.dispose();
    super.dispose();
  }

  void _load() {
    _event = context.dispatchProcess(
      const GetPayeesAction(),
      returnSavedResponse: true,
      saveActionResponse: true,
    );
  }

  List<Payee> get _filtered {
    final all = _payees ?? const [];
    if (_query.isEmpty) return all;
    final query = _query.toLowerCase();
    return all
        .where(
          (p) => [p.title, p.value, p.formName, p.shortTitle].any(
            (f) => f?.toLowerCase().contains(query) ?? false,
          ),
        )
        .toList();
  }

  Future<bool> _confirmDelete(Payee payee) {
    final l10n = AppLocalizations.of(context)!;
    return showConfirmSheet(
      context,
      icon: Icons.person_remove_outlined,
      title: l10n.beneficiariesRemoveTitle,
      message: l10n.beneficiariesRemoveConfirm(payee.displayName),
      confirmText: l10n.commonRemove,
    );
  }

  void _delete(Payee payee) {
    setState(() {
      _payees = List.of(_payees ?? const [])..remove(payee);
      if (_selectedPayee?.payeeId == payee.payeeId) _selectedPayee = null;
    });
    _deleteEvent = context.dispatchProcess(
      DeletePayeeAction(payload: DeletePayeePayload(payeeId: payee.payeeId)),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '?';
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    return MasterDetailLayout(
      detail: _selectedPayee == null
          ? null
          : BeneficiaryDetailsView(
              // See the matching key on ComplaintDetailView — without one,
              // switching the master-list selection reuses the same State
              // instead of creating a fresh one for the new payee.
              key: ValueKey(_selectedPayee!.payeeId),
              payee: _selectedPayee,
              onBack: _closeDetails,
            ),
      master: _master(context),
    );
  }

  Widget _master(BuildContext context) {
    return MultiProcessListener(
      listeners: [
        ProcessListenerConfig<bool>(
          event: () => _deleteEvent,
          listener: (context, snapshot) {
            if (snapshot.hasError) {
              _deleteEvent = null;
              MessageUtil.displayErrorDialog(
                context,
                message: snapshot.error!.message,
              );
              // Restore the optimistic removal.
              _load();
            } else if (snapshot.isSuccessful) {
              _deleteEvent = null;
            }
          },
        ),
        ProcessListenerConfig<bool>(
          event: () => _payEvent,
          listener: (context, snapshot) {
            if (snapshot.isLoading) {
              MessageUtil.displayLoading(context);
              return;
            }
            MessageUtil.close(context);

            if (snapshot.isSuccessful) {
              _payEvent = null;
              final l10n = AppLocalizations.of(context)!;
              MessageUtil.displaySuccessDialog(
                context,
                title: l10n.beneficiariesSentTitle,
                message: snapshot.message ?? l10n.beneficiariesSentMessage,
                onOk: _load,
              );
            } else if (snapshot.hasError) {
              _payEvent = null;
              MessageUtil.displayErrorDialog(
                context,
                message: snapshot.error!.message,
              );
            }
          },
        ),
      ],
      child: MainLayout(
        showBackBtn: true,
        bottomSize: 129,
        title: AppLocalizations.of(context)!.moreBeneficiaries,
        onRefresh: () async {
          _load();
          await context.awaitProcess(_event);
        },
        actions: SizedBox(
          width: 110,
          child: FormButton(
            padding: .zero,
            height: 44,
            labelSize: 13,
            onPressed: () =>
                AppRouter.router.push(AddBeneficiaryPage.route.path),
            text: AppLocalizations.of(context)!.commonAddNew,
            icon: Icons.add,
            buttonIconAlignment: .left,
            iconSize: 16,
          ),
        ),
        subtitleWidget: Container(
          padding: .only(top: 20),
          child: FormInput(
            placeholder: AppLocalizations.of(context)!.commonSearch,
            controller: _searchController,
            suffix: Icon(Icons.search),
            textInputAction: .search,
          ),
        ),
        child: ProcessConsumer<List<Payee>>(
          event: () => _event,
          listener: (context, snapshot) {
            if (snapshot.hasData) {
              setState(() => _payees = snapshot.data);
            }
          },
          builder: (context, snapshot) {
            if (snapshot.isLoading) {
              return Column(
                mainAxisSize: .min,
                children: List.generate(
                  6,
                  (_) => const ListItemSkeleton(),
                ),
              );
            }

            final beneficiaries = _filtered;
            if (beneficiaries.isEmpty) {
              return _query.isNotEmpty
                  ? _noMatches()
                  : const EmptyBeneficiaries();
            }

            return Column(
              children: [
                for (final payee in beneficiaries) _buildItem(payee),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildItem(Payee payee) {
    final l10n = AppLocalizations.of(context)!;
    final name = payee.displayName;
    final value = payee.value;
    final formName = payee.formName;

    return Dismissible(
      key: ValueKey(payee.payeeId ?? name),
      direction: .endToStart,
      confirmDismiss: (_) => _confirmDelete(payee),
      onDismissed: (_) => _delete(payee),
      background: Container(
        margin: const .only(bottom: 12),
        alignment: .centerRight,
        padding: const .symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: .circular(16),
        ),
        child: SvgPicture.asset(SvgImages.trash),
      ),
      child: Container(
        margin: const .only(bottom: 12),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: .circular(16),
          border: .all(color: context.border),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: .circular(16),
            onTap: () => _openDetails(payee),
            child: Padding(
              padding: const .all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: context.avatarBg,
                    child: Text(_initials(name), style: context.p1Medium),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: .start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: .ellipsis,
                          style: context.p1Medium,
                        ),
                        if (value?.isNotEmpty ?? false) ...[
                          const SizedBox(height: 2),
                          Text(
                            value!,
                            maxLines: 1,
                            overflow: .ellipsis,
                            style: context.smallDetails,
                          ),
                        ],
                        if (formName?.isNotEmpty ?? false) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const .symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: context.avatarBg,
                              borderRadius: .circular(100),
                            ),
                            child: Text(
                              formName!,
                              style: context.smallDetailsMedium,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // "Send now": pay the saved beneficiary directly (PIN +
                  // Payee/payPayee). A single soft circular action — no
                  // chevron, so the trailing stays clean and the card tap
                  // alone opens the details.
                  if (payee.formId?.isNotEmpty ?? false)
                    IconButton(
                      tooltip: l10n.beneficiariesSendNow,
                      onPressed: () => _send(payee),
                      style: IconButton.styleFrom(
                        backgroundColor: context.avatarBg,
                        foregroundColor: AppColors.primary,
                      ),
                      icon: const Icon(Icons.north_east, size: 18),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _noMatches() {
    return Padding(
      padding: const .symmetric(vertical: 60),
      child: EmptyState(
        svgAsset: SvgImages.emptyWallet,
        title: AppLocalizations.of(context)!.beneficiariesNoMatchQuery(_query),
      ),
    );
  }
}

class EmptyBeneficiaries extends StatelessWidget {
  const EmptyBeneficiaries({super.key});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      svgAsset: SvgImages.emptyWallet,
      title: AppLocalizations.of(context)!.beneficiariesEmptyTitle,
      subtitle: AppLocalizations.of(context)!.beneficiariesEmptySubtitle,
    );
  }
}
