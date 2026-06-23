import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/pages/history/transaction_details.pg.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/utils/app_modal.dart';
import 'package:flutter/material.dart';

import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/forms.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/summary',
  );

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  @override
  Widget build(BuildContext context) {
    return MainLayout(
      subtitleWidget: Column(
        children: [
          Text(
            'Transaction Summary',
            textAlign: .center,
            style: AppTypography.display2,
          ),
          const SizedBox(height: 10),
          Text(
            'Kindly confirm the transaction details before you proceed',
            textAlign: .center,
            style: AppTypography.smallDetails,
          ),
        ],
      ),
      bottomNav: FormButton(
        onPressed: () {},
        text: 'Continue',
      ),
      child: Container(
        // alignment: .center,
        padding: .all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: .circular(12),
        ),
        child: Column(
          mainAxisSize: .min,
          mainAxisAlignment: .start,
          crossAxisAlignment: .center,
          children: [
            TransactionDetailsItem(
              title: 'Service',
              value: 'MoMo to Bank Account',
            ),
            Divider(
              color: AppColors.offWhite,
            ),
            TransactionDetailsItem(
              title: 'Amount',
              value: 'GHS 10.00',
            ),
            Divider(
              color: AppColors.offWhite,
            ),
            TransactionDetailsItem(
              title: 'Payment Method',
              value: 'MTN Mobile Money (0245***219)',
            ),
            Divider(
              color: AppColors.offWhite,
            ),
            TransactionDetailsItem(
              title: 'Charges',
              value: 'GHS 5.00',
            ),
            Divider(
              color: AppColors.offWhite,
            ),
            TransactionDetailsItem(
              title: 'Total Amount',
              value: 'GHS 2,505.00',
            ),
          ],
        ),
      ),
    );
  }
}
