import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sliver_tools/sliver_tools.dart';

import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/forms.dart';
import 'package:bigpay/ui/layouts/dashboard.lo.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/utils/app_modal.dart';

class VirtualWalletPage extends StatefulWidget {
  const VirtualWalletPage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/wallets/virtual',
  );

  @override
  State<VirtualWalletPage> createState() => _VirtualWalletPageState();
}

class _VirtualWalletPageState extends State<VirtualWalletPage> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    const appBarHeight = kToolbarHeight;
    final totalAppBarHeight = statusBarHeight + appBarHeight;

    (screenHeight - statusBarHeight) / screenHeight;

    final max = (screenHeight - statusBarHeight) / screenHeight;
    final min =
        (screenHeight - (statusBarHeight + totalAppBarHeight + 160)) /
        screenHeight;
    return Stack(
      children: [
        DashboardLayout(
          backgroundColor: AppColors.white,
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
                backgroundColor: AppColors.white,

                appBar: AppBar(
                  backgroundColor: AppColors.white,
                  surfaceTintColor: AppColors.white,
                  actionsPadding: .symmetric(horizontal: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: .vertical(top: .circular(20)),
                  ),
                  primary: false,
                  title: Text(
                    'Recent Transactions',
                    style: AppTypography.header1,
                  ),
                  actions: [
                    SizedBox(
                      width: 130,
                      child: FormButton(
                        backgroundColor: AppColors.tintShade3,
                        foregroundColor: AppColors.black,
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
                                controller: TextEditingController(),
                              ),
                              const SizedBox(height: 10),
                              FormDateInput(
                                label: 'Date To',
                                placeholder: 'DD/MM/YY',
                                controller: TextEditingController(),
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
            backgroundColor: AppColors.backgroundPale,
          ),
          CircleAvatar(
            backgroundColor: AppColors.white,
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
        style: AppTypography.formLabels,
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
            style: AppTypography.captionSemibold,
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
              style: AppTypography.header1,
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
                  style: AppTypography.p1Medium,
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
