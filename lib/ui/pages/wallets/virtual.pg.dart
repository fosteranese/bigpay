import 'package:flutter/material.dart';

import 'package:bigpay/data/models/account/account.dart';
import 'package:bigpay/data/models/account/mini_statement.dart';
import 'package:bigpay/data/models/account/transaction.dart';
import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/models/wallet/get_wallet_transactions_action.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/forms.dart';
import 'package:bigpay/ui/components/process_builder.dart';
import 'package:bigpay/ui/layouts/dashboard.lo.dart';
import 'package:bigpay/ui/components/empty_state.dart';
import 'package:bigpay/ui/components/skeleton/variants.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/assets/app_images.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/ui/theme/responsive.dart';
import 'package:bigpay/utils/app_modal.dart';
import 'package:bigpay/utils/message.util.dart';

class VirtualWalletPage extends StatelessWidget {
  const VirtualWalletPage({super.key, this.account});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/wallets/virtual',
  );

  final Account? account;

  @override
  Widget build(BuildContext context) {
    return VirtualWalletView(
      account: account,
      onBack: () => AppRouter.router.pop(),
    );
  }
}

class VirtualWalletView extends StatefulWidget {
  const VirtualWalletView({
    super.key,
    this.account,
    required this.onBack,
  });

  final Account? account;
  final VoidCallback onBack;

  @override
  State<VirtualWalletView> createState() => _VirtualWalletViewState();
}

class _VirtualWalletViewState extends State<VirtualWalletView> {
  final _dateFromController = TextEditingController();
  final _dateToController = TextEditingController();
  ExecuteProcessEvent? _txEvent;

  bool get _isVirtual =>
      widget.account?.mode?.toUpperCase() == 'VIRTUAL_WALLET' ||
      widget.account == null;

  String get _sourceValue => widget.account?.sources?.firstOrNull?.value ?? '';

  bool get _hasActiveFilter =>
      _dateFromController.text.isNotEmpty || _dateToController.text.isNotEmpty;

  String _title(BuildContext context) =>
      widget.account?.title ??
      widget.account?.sources?.firstOrNull?.tile ??
      AppLocalizations.of(context)!.walletsVirtualWalletFallback;

  String get _balance =>
      widget.account?.sources?.firstOrNull?.balance ?? '0.00';

  double get _height {
    return _isVirtual ? 160 : 160 - 55;
  }

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions({DateTime? startDate, DateTime? endDate}) {
    String? start;
    String? end;
    if (startDate != null) {
      start =
          '${startDate.year.toString().padLeft(4, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
    }
    if (endDate != null) {
      end =
          '${endDate.year.toString().padLeft(4, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
    }
    _txEvent = context.dispatchProcess(
      GetWalletTransactionsAction(
        payload: MiniStatementPayload(
          sourceValue: _sourceValue,
          startDate: start,
          endDate: end,
        ),
      ),
    );
  }

  void _clearFilter() {
    _dateFromController.clear();
    _dateToController.clear();
    _loadTransactions();
  }

  @override
  void dispose() {
    _dateFromController.dispose();
    _dateToController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final statusBarHeight = MediaQuery.paddingOf(context).top;
    const appBarHeight = kToolbarHeight;
    final totalAppBarHeight = statusBarHeight + appBarHeight;

    final max = (screenHeight - statusBarHeight) / screenHeight;
    final min =
        (screenHeight - (statusBarHeight + totalAppBarHeight + _height)) /
        screenHeight;
    return Stack(
      children: [
        DashboardLayout(
          backgroundColor: context.cardBg,
          isVirtual: _isVirtual,
          wallet: widget.account,
          title: _title(context),
          balance: _balance,
          onBack: widget.onBack,
          builder: (blur, alpha) => [],
        ),
        DraggableScrollableSheet(
          snapSizes: [min, max],
          initialChildSize: min,
          minChildSize: min,
          maxChildSize: max,
          snap: true,
          builder: (context, scrollController) {
            return BoundedContent(
              maxWidth: context.responsive<double>(
                compact: double.infinity,
                medium: 760,
                expanded: 960,
              ),
              child: ClipRRect(
                borderRadius: .vertical(top: .circular(20)),
                child: Container(
                  color: context.cardBg,
                  child: ProcessBuilder<MiniStatement>(
                    event: () => _txEvent,
                    builder: (context, snapshot) {
                      return CustomScrollView(
                        controller: scrollController,
                        slivers: [
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const .fromLTRB(16, 12, 10, 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .walletsRecentTransactions,
                                      style: context.header1,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 130,
                                    child: FormButton(
                                      backgroundColor: context.avatarBg,
                                      foregroundColor: context.textPrimary,
                                      padding: .zero,
                                      height: 44,
                                      onPressed: _showDateFilter,
                                      labelSize: 13,
                                      text: AppLocalizations.of(context)!
                                          .walletsViewStatement,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (snapshot.isLoading)
                            SliverPadding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              sliver: SliverList.separated(
                                itemCount: 6,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (_, _) =>
                                    const TransactionItemSkeleton(),
                              ),
                            )
                          else if (snapshot.hasError)
                            SliverToBoxAdapter(
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.error_outline_rounded,
                                        size: 40,
                                        color: AppColors.danger,
                                      ),
                                      const SizedBox(height: Spacing.lg),
                                      Text(
                                        snapshot.message ??
                                            AppLocalizations.of(context)!
                                                .commonRetry,
                                        textAlign: TextAlign.center,
                                        style: context.p1Medium,
                                      ),
                                      const SizedBox(height: Spacing.xl),
                                      FormButton(
                                        text: AppLocalizations.of(context)!
                                            .commonRetry,
                                        onPressed: () {
                                          MessageUtil.close(context);
                                          _loadTransactions();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          else if ((snapshot.data?.transactions ?? []).isEmpty)
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: Padding(
                                padding: const .symmetric(horizontal: 30),
                                child: EmptyState(
                                  svgAsset: SvgImages.emptyWallet,
                                  title: AppLocalizations.of(context)!
                                      .walletsNoTransactionsYet,
                                  subtitle: AppLocalizations.of(context)!
                                      .walletsNoTransactionsSubtitle,
                                ),
                              ),
                            )
                          else
                            SliverPadding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              sliver: SliverList.separated(
                                itemCount:
                                    snapshot.data!.transactions!.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (_, index) =>
                                    TransactionListItem(
                                      transaction: snapshot
                                          .data!.transactions![index],
                                    ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _showDateFilter() {
    final l10n = AppLocalizations.of(context)!;
    AppModal.showBottomModal(
      context,
      label: l10n.walletsChooseDateRange,
      padding: .all(20),
      children: [
        Text(
          l10n.walletsStatementEmailNotice,
          style: context.caption,
        ),
        const SizedBox(height: Spacing.xl),
        FormDateInput(
          label: l10n.walletsDateFromLabel,
          placeholder: l10n.commonDateFormatPlaceholder,
          controller: _dateFromController,
        ),
        const SizedBox(height: 10),
        FormDateInput(
          label: l10n.walletsDateToLabel,
          placeholder: l10n.commonDateFormatPlaceholder,
          controller: _dateToController,
        ),
        const SizedBox(height: Spacing.xl),
        FormButton(
          height: 54,
          onPressed: () {
            final start = _parseDate(_dateFromController.text);
            final end = _parseDate(_dateToController.text);
            _loadTransactions(startDate: start, endDate: end);
            AppRouter.router.pop();
          },
          text: l10n.commonShowResults,
        ),
        if (_hasActiveFilter) ...[
          const SizedBox(height: 10),
          FormButton(
            height: 54,
            backgroundColor: context.cardBg,
            foregroundColor: AppColors.danger,
            onPressed: () {
              _clearFilter();
              AppRouter.router.pop();
            },
            text: l10n.historyClearFilter,
          ),
        ],
      ],
    );
  }

  DateTime? _parseDate(String text) {
    if (text.isEmpty) return null;
    try {
      final date = DateTime.parse(text);
      return date;
    } catch (_) {}
    return null;
  }
}

class TransactionListItem extends StatelessWidget {
  const TransactionListItem({super.key, required this.transaction});

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.debitCreditFlag?.toLowerCase() == 'cr';
    return ListTile(
      leading: Stack(
        alignment: .bottomRight,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: context.scaffoldBg,
          ),
          CircleAvatar(
            backgroundColor: context.cardBg,
            radius: 9,
            child: Icon(
              Icons.north_east_outlined,
              color: isCredit ? AppColors.success : AppColors.danger,
              size: 10,
            ),
          ),
        ],
      ),
      title: Text(
        transaction.transactionType ?? '',
        style: context.formLabels,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        transaction.postDate ?? '',
        style: context.caption,
      ),
      trailing: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            transaction.amount ?? '',
            style: context.captionSemibold.copyWith(
              color: isCredit ? AppColors.success : AppColors.danger,
            ),
          ),
          Text(
            transaction.narration ?? '',
            style: context.caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
