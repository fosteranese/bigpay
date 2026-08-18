import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sliver_tools/sliver_tools.dart';

import 'package:bigpay/data/models/account/account.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/forms.dart';
import 'package:bigpay/ui/layouts/dashboard.lo.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/utils/app_modal.dart';

/// Wallet details. For the virtual wallet it shows the balance design; for any
/// other wallet it shows the wallet's title in place of the balance.
class VirtualWalletPage extends StatefulWidget {
  const VirtualWalletPage({super.key, this.account});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/wallets/virtual',
  );

  final Account? account;

  @override
  State<VirtualWalletPage> createState() => _VirtualWalletPageState();
}

class _VirtualWalletPageState extends State<VirtualWalletPage> {
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

  String get _title =>
      widget.account?.title ??
      widget.account?.sources?.firstOrNull?.tile ??
      'Virtual Wallet';

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

    (screenHeight - statusBarHeight) / screenHeight;

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
          title: _title,
          balance: _balance,
          onBack: () => AppRouter.router.pop(),
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
            return ClipRRect(
              borderRadius: .vertical(top: .circular(20)),
              child: Scaffold(
                primary: false,
                backgroundColor: context.cardBg,
                appBar: AppBar(
                  backgroundColor: context.cardBg,
                  surfaceTintColor: context.cardBg,
                  actionsPadding: .symmetric(horizontal: 10),
                  automaticallyImplyLeading: false,
                  automaticallyImplyActions: false,
                  centerTitle: false,
                  shape: RoundedRectangleBorder(
                    borderRadius: .vertical(top: .circular(20)),
                  ),
                  primary: false,
                  title: Text(
                    'Recent Transactions',
                    style: context.header1,
                  ),
                  actions: [
                    SizedBox(
                      width: 130,
                      child: FormButton(
                        backgroundColor: context.avatarBg,
                        foregroundColor: context.textPrimary,
                        padding: .zero,
                        height: 30,
                        onPressed: () {
                          AppModal.showBottomModal(
                            context,
                            label: 'Choose a date range',
                            padding: .all(20),
                            children: [
                              Text(
                                'The statement will be sent to your email address',
                                style: AppTypography.caption,
                              ),
                              const SizedBox(height: 20),
                              FormDateInput(
                                label: 'Date From',
                                placeholder: 'DD/MM/YY',
                                controller: _dateFromController,
                              ),
                              const SizedBox(height: 10),
                              FormDateInput(
                                label: 'Date To',
                                placeholder: 'DD/MM/YY',
                                controller: _dateToController,
                              ),
                              const SizedBox(height: 20),
                              FormButton(
                                height: 54,
                                onPressed: () {},
                                text: 'Show Results',
                              ),
                            ],
                          );
                        },
                        labelSize: 13,
                        text: 'View Statement',
                      ),
                    ),
                  ],
                ),
                body: ListView.builder(
                  controller: scrollController,
                  itemBuilder: (context, index) {
                    return TransactionListItem();
                  },
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
        'Fund Wallet',
        style: context.formLabels,
      ),
      subtitle: Text(
        '09-Jun-23 12:30pm',
        style: AppTypography.caption,
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
            'Success',
            style: AppTypography.caption.copyWith(
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
              'Recent Transactions',
              style: context.header1,
            ),
          ),
        ),
        SliverFillRemaining(
          fillOverscroll: true,
          hasScrollBody: false,
          child: Padding(
            padding: const .symmetric(horizontal: 30),
            child: Column(
              mainAxisSize: .max,
              mainAxisAlignment: .center,
              crossAxisAlignment: .center,
              children: [
                const Spacer(flex: 1),
                SvgPicture.asset('assets/img/empty-wallet.svg'),
                Text(
                  'No transactions yet',
                  textAlign: .center,
                  style: context.p1Medium,
                ),
                Text(
                  'Your financial journey starts here. Once you send or receive funds, your activity will appear in this space',
                  textAlign: .center,
                  style: AppTypography.smallDetails,
                ),
                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
