import 'package:bigpay/data/models/general_flow/request_response.dart';
import 'package:bigpay/ui/components/forms/forms.dart';
import 'package:bigpay/ui/pages/dashboard.pg.dart';
import 'package:bigpay/ui/pages/history/history.pg.dart';
import 'package:bigpay/ui/pages/process_flow/service.pg.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:flutter/material.dart';

import 'package:bigpay/routes/app_router.dart';
import 'package:go_router/go_router.dart';

class TransactionDetailsPage extends StatefulWidget {
  const TransactionDetailsPage({
    super.key,
    required this.receipt,
  });
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/history/details',
  );

  final RequestResponse receipt;

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
            onPressed: () {
              context.pop();
            },
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
                      value: widget.receipt.formName ?? '',
                    ),
                    TransactionDetailsItem(
                      title: 'Transaction ID',
                      value: widget.receipt.activityName ?? '',
                    ),
                    Divider(
                      color: Color(0xffF4F5FF),
                      thickness: 4,
                    ),
                    ...widget.receipt.previewData.map((item) {
                      return TransactionDetailsItem(
                        title: item.key ?? '',
                        value: item.value ?? '',
                      );
                    }),
                    Divider(
                      color: Color(0xffF4F5FF),
                      thickness: 4,
                    ),
                    TransactionDetailsItem(
                      title: 'Date',
                      value: widget.receipt.receiptDateTime ?? '',
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
                if (widget.receipt.status == 1)
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
                FormButton(
                  onPressed: () {
                    AppRouter.router.popUntilNamedRoutes([
                      DashboardPage.route.path,
                      ServicePage.route.path,
                      HistoryPage.route.path,
                    ]);
                  },
                  text: 'Back to Home',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    switch (widget.receipt.status) {
      case 1:
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

      case 0:
      case 3:
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
          Expanded(
            child: Text(
              title,
              textAlign: .left,
              style: title.toLowerCase().contains('total')
                  ? AppTypography.header4.copyWith(
                      color: AppColors.black,
                    )
                  : AppTypography.caption.copyWith(
                      color: AppColors.fiat,
                    ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              value,
              textAlign: .right,
              style: AppTypography.header4.copyWith(
                color: AppColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
