import 'package:flutter/material.dart';

import 'package:bigpay/data/models/general_flow/request_response.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/forms.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/pages/dashboard.pg.dart';
import 'package:bigpay/ui/pages/history/transaction_details.pg.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';

/// Transaction receipt shown after a request is processed.
class DonePage extends StatelessWidget {
  const DonePage({super.key, this.receipt});

  static PageRouteDefinition route = PageRouteDefinition(
    path: '/services/done',
  );

  final RequestResponse? receipt;

  /// Reference, preview rows, and the date — whichever the receipt carries.
  List<(String, String)> get _rows {
    final rows = <(String, String)>[];

    final reference = receipt?.reference;
    if (reference != null && reference.isNotEmpty) {
      rows.add(('Reference', reference));
    }

    for (final item in receipt?.previewData ?? const []) {
      final key = item.key;
      final value = item.value;
      if (key == null || value == null || value.isEmpty) continue;
      rows.add((key, value));
    }

    final date = receipt?.receiptDateTime ?? receipt?.receiptDate;
    if (date != null && date.isNotEmpty) {
      rows.add(('Date', date));
    }

    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final rows = _rows;
    final amount = receipt?.amount;

    return MainLayout(
      showBackBtn: false,
      subtitleWidget: Column(
        children: [
          const CircleAvatar(
            radius: 42.5,
            backgroundColor: AppColors.tintShade3,
            child: Icon(
              Icons.check_circle_outline,
              color: AppColors.success,
              size: 45,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            receipt?.statusLabel ?? 'Transaction Successful',
            textAlign: .center,
            style: AppTypography.header1,
          ),
          if (amount != null && amount.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(amount, textAlign: .center, style: AppTypography.display2),
          ],
        ],
      ),
      bottomNav: FormButton(
        onPressed: () => AppRouter.router.go(DashboardPage.route.path),
        text: 'Done',
      ),
      child: rows.isEmpty
          ? const SizedBox.shrink()
          : Container(
              padding: .all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: .circular(12),
              ),
              child: Column(
                mainAxisSize: .min,
                children: [
                  for (final (index, (title, value)) in rows.indexed) ...[
                    TransactionDetailsItem(title: title, value: value),
                    if (index != rows.length - 1)
                      Divider(color: AppColors.offWhite),
                  ],
                ],
              ),
            ),
    );
  }
}
