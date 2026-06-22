import 'package:bigpay/ui/components/forms/forms.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:flutter/material.dart';

import 'package:bigpay/routes/app_router.dart';

class TransactionDetailsPage extends StatefulWidget {
  const TransactionDetailsPage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/history/details',
  );

  @override
  State<TransactionDetailsPage> createState() => _TransactionDetailsPageState();
}

class _TransactionDetailsPageState extends State<TransactionDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        image: DecorationImage(
          image: AssetImage('assets/img/trans-bg.jpg'),
          fit: .cover,
          repeat: .repeat,
          opacity: 0.06,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leadingWidth: 70,
          leading: IconButton.filled(
            style: IconButton.styleFrom(
              backgroundColor: AppColors.white,
              fixedSize: Size(28, 28),
            ),
            onPressed: () {},
            icon: Icon(
              Icons.chevron_left_outlined,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: .center,
            children: [
              _buildTitle(),
              const SizedBox(height: 20),
              Container(
                margin: .symmetric(horizontal: 20),
                padding: .all(24),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: .circular(8),
                ),
                child: Column(
                  children: [
                    TransactionDetailsItem(
                      title: 'Service',
                      value: 'Airtime Top Up',
                    ),
                    TransactionDetailsItem(
                      title: 'Phone number',
                      value: '0245075219',
                    ),
                    Divider(
                      color: Color(0xffF4F5FF),
                      thickness: 4,
                    ),
                    TransactionDetailsItem(
                      title: 'Payment source',
                      value: 'Visa ***9876',
                    ),
                    TransactionDetailsItem(
                      title: 'Amount',
                      value: 'GHS 10.00',
                    ),
                    TransactionDetailsItem(
                      title: 'Charges',
                      value: 'GHS 0.00',
                    ),
                    TransactionDetailsItem(
                      title: 'Total',
                      value: 'GHS 10.00',
                    ),
                    Divider(
                      color: Color(0xffF4F5FF),
                      thickness: 4,
                    ),
                    TransactionDetailsItem(
                      title: 'Date',
                      value: '12 January, 2024 13:45',
                    ),
                    TransactionDetailsItem(
                      title: 'Transaction ID',
                      value: '12345678900987',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const .symmetric(horizontal: 20, vertical: 10),
            child: Column(
              mainAxisSize: .min,
              crossAxisAlignment: .center,
              children: [
                if ('success' == 'success')
                  Row(
                    children: [
                      Expanded(
                        child: FormButton(
                          backgroundColor: AppColors.white,
                          foregroundColor: AppColors.black,
                          onPressed: () {},
                          text: 'Share',
                          icon: Icons.share_outlined,
                          buttonIconAlignment: .left,
                          iconSize: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FormButton(
                          backgroundColor: AppColors.white,
                          foregroundColor: AppColors.black,
                          onPressed: () {},
                          text: 'Save',
                          icon: Icons.group_outlined,
                          buttonIconAlignment: .left,
                          iconSize: 20,
                        ),
                      ),
                    ],
                  )
                else
                  FormButton(
                    backgroundColor: AppColors.white,
                    foregroundColor: AppColors.black,
                    onPressed: () {},
                    text: 'Submit a Complain',
                    svgIcon: 'assets/img/complaint.svg',
                    buttonIconAlignment: .left,
                    iconSize: 20,
                  ),
                const SizedBox(height: 20),
                FormButton(onPressed: () {}, text: 'Back to Home'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    switch ('success') {
      case 'success':
        return Column(
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 45,
              color: AppColors.success,
            ),
            const SizedBox(height: 10),
            Text(
              'Transaction Successful',
              style: AppTypography.display2,
            ),
            Text(
              'Your transaction is complete',
              style: AppTypography.smallDetails.copyWith(
                color: AppColors.black,
              ),
            ),
          ],
        );

      case 'error':
      case 'failed':
        return Column(
          children: [
            Icon(
              Icons.cancel_outlined,
              size: 45,
              color: AppColors.danger,
            ),
            const SizedBox(height: 10),
            Text(
              'Transaction Failed',
              style: AppTypography.display2.copyWith(
                color: AppColors.danger,
              ),
            ),
          ],
        );
    }

    return Text(
      'Transaction Receipt',
      style: AppTypography.display2,
    );
  }
}

class TransactionDetailsItem extends StatelessWidget {
  const TransactionDetailsItem({
    super.key,
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .symmetric(vertical: 5),
      child: Row(
        mainAxisSize: .max,
        mainAxisAlignment: .spaceBetween,
        crossAxisAlignment: .center,
        children: [
          Text(
            title,
            style: title.toLowerCase().contains('total')
                ? AppTypography.header4.copyWith(
                    color: AppColors.black,
                  )
                : AppTypography.caption.copyWith(
                    color: AppColors.fiat,
                  ),
          ),

          Text(
            value,
            style: AppTypography.header4.copyWith(
              color: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }
}
