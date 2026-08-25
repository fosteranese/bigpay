import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';

import 'package:bigpay/data/models/account/account.dart';
import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/forms.dart';
import 'package:bigpay/ui/layouts/dashboard.lo.dart';
import 'package:bigpay/ui/components/empty_state.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/assets/app_images.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/ui/theme/responsive.dart';
import 'package:bigpay/utils/app_modal.dart';

/// A pushed full page wrapping [VirtualWalletView] — used on every device
/// except a foldable in book mode, where [WalletsPage] shows the same view
/// inline in the second pane instead (see [MasterDetailLayout]).
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

/// Wallet details, independent of how it's hosted — a pushed page
/// ([VirtualWalletPage]) or an inline pane in [WalletsPage]'s foldable
/// book-mode split. For the virtual wallet it shows the balance design; for
/// any other wallet it shows the wallet's title in place of the balance.
///
/// Built without a Scaffold anywhere in the tree (both here and in the
/// [DashboardLayout] it wraps) — a Scaffold nested inside the Expanded pane
/// of a MasterDetailLayout silently fails to render its body on a real device
/// (confirmed on [TransactionDetailsView]'s equivalent bug). One Scaffold at
/// a time avoids it, whichever ancestor happens to supply it.
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
  // Statement date-range fields (shown in the "View Statement" sheet).
  final _dateFromController = TextEditingController();
  final _dateToController = TextEditingController();

  @override
  void dispose() {
    _dateFromController.dispose();
    _dateToController.dispose();
    super.dispose();
  }

  bool get _isVirtual =>
      widget.account?.mode?.toUpperCase() == 'VIRTUAL_WALLET' ||
      widget.account == null;

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
          builder: (blur, alpha) => [
            // EmptyWalletTransactions(),
          ],
        ),
        DraggableScrollableSheet(
          snapSizes: [min, max],
          initialChildSize: min,
          minChildSize: min,
          maxChildSize: max,
          snap: true,
          builder: (context, scrollController) {
            // Capped the same way DashboardLayout above caps itself, so the
            // sheet doesn't disagree with the page on width on a wide screen.
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
                  child: Column(
                    children: [
                      Padding(
                        padding: const .fromLTRB(16, 12, 10, 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context)!.walletsRecentTransactions,
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
                                onPressed: () {
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
                                        onPressed: () {},
                                        text: l10n.commonShowResults,
                                      ),
                                    ],
                                  );
                                },
                                labelSize: 13,
                                text: AppLocalizations.of(context)!.walletsViewStatement,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemBuilder: (context, index) {
                            return TransactionListItem();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class TransactionListItem extends StatelessWidget {
  const TransactionListItem({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
              color: AppColors.success,
              size: 10,
            ),
          ),
        ],
      ),
      title: Text(
        AppLocalizations.of(context)!.walletsFundWalletDemo,
        style: context.formLabels,
      ),
      subtitle: Text(
        '09-Jun-23 12:30pm',
        style: context.caption,
      ),
      trailing: Column(
        mainAxisSize: .max,
        mainAxisAlignment: .center,
        crossAxisAlignment: .end,
        children: [
          Text(
            'GHS 12,000',
            style: context.captionSemibold,
          ),
          Text(
            AppLocalizations.of(context)!.commonSuccess,
            style: context.caption.copyWith(
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyWalletTransactions extends StatelessWidget {
  const EmptyWalletTransactions({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiSliver(
      children: [
        SliverToBoxAdapter(
          child: Padding(
            padding: .symmetric(horizontal: 20),
            child: Text(
              AppLocalizations.of(context)!.walletsRecentTransactions,
              style: context.header1,
            ),
          ),
        ),
        SliverFillRemaining(
          fillOverscroll: true,
          hasScrollBody: false,
          child: Padding(
            padding: const .symmetric(horizontal: 30),
            child: EmptyState(
              svgAsset: SvgImages.emptyWallet,
              title: AppLocalizations.of(context)!.walletsNoTransactionsYet,
              subtitle:
                  AppLocalizations.of(context)!.walletsNoTransactionsSubtitle,
            ),
          ),
        ),
      ],
    );
  }
}
