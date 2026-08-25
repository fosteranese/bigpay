import 'package:bigpay/data/models/general_flow/request_response.dart';
import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/ui/components/forms/forms.dart';
import 'package:bigpay/ui/pages/dashboard.pg.dart';
import 'package:bigpay/ui/pages/history/history.pg.dart';
import 'package:bigpay/ui/pages/process_flow/service.pg.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/ui/theme/responsive.dart';
import 'package:flutter/material.dart';

import 'package:bigpay/routes/app_router.dart';
import 'package:go_router/go_router.dart';

/// A pushed full page wrapping [TransactionDetailsView] — used on every
/// device except a foldable in book mode, where [HistoryPage] shows the same
/// view inline in the second pane instead (see [MasterDetailLayout]).
class TransactionDetailsPage extends StatelessWidget {
  const TransactionDetailsPage({
    super.key,
    required this.receipt,
  });
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/history/details',
  );

  final RequestResponse receipt;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TransactionDetailsView(
        receipt: receipt,
        onBack: () => context.pop(),
      ),
    );
  }
}

/// The transaction receipt content itself, independent of how it's hosted —
/// a pushed page ([TransactionDetailsPage], [onBack] provided) or an inline
/// pane in [HistoryPage]'s foldable book-mode split ([onBack] null, no back
/// button since the master list stays visible alongside it).
///
/// Deliberately built from plain layout widgets (Column) rather than its own
/// nested Scaffold: a Scaffold nested inside the Expanded pane of
/// [MasterDetailLayout] silently fails to render its `body` slot (confirmed on
/// a real device — the appBar/bottomNavigationBar render fine, the body
/// doesn't, with no error). One Scaffold in the tree at a time avoids it —
/// [TransactionDetailsPage] supplies the only one, in both hosting contexts.
class TransactionDetailsView extends StatelessWidget {
  const TransactionDetailsView({
    super.key,
    required this.receipt,
    this.onBack,
  });

  final RequestResponse receipt;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.scaffoldBg,
        image: DecorationImage(
          image: AssetImage('assets/img/trans-bg.jpg'),
          fit: .cover,
          repeat: .repeat,
          opacity: 0.06,
        ),
      ),
      child: Column(
        children: [
          if (onBack != null)
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const .fromLTRB(20, 12, 20, 0),
                child: Align(
                  alignment: .centerLeft,
                  child: IconButton.filled(
                    tooltip: AppLocalizations.of(context)!.commonBack,
                    style: IconButton.styleFrom(
                      backgroundColor: context.cardBg,
                      foregroundColor: context.textPrimary,
                      fixedSize: Size(44, 44),
                    ),
                    onPressed: onBack,
                    icon: Icon(
                      Icons.chevron_left_outlined,
                    ),
                  ),
                ),
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              child: BoundedContent(
                child: Column(
                  mainAxisSize: .min,
                  mainAxisAlignment: .center,
                  children: [
                    const SizedBox(height: Spacing.xl),
                    _buildTitle(context),
                    const SizedBox(height: Spacing.xl),
                    Container(
                      margin: .symmetric(horizontal: 20),
                      padding: .all(24),
                      decoration: BoxDecoration(
                        color: context.cardBg,
                        borderRadius: .circular(8),
                      ),
                      child: Column(
                        children: [
                          TransactionDetailsItem(
                            title: AppLocalizations.of(context)!.historyServiceLabel,
                            value: receipt.formName ?? '',
                          ),
                          TransactionDetailsItem(
                            title: AppLocalizations.of(context)!.historyTransactionIdLabel,
                            value: receipt.activityName ?? '',
                          ),
                          Divider(
                            color: context.divider,
                            thickness: 4,
                          ),
                          ...receipt.previewData.map((item) {
                            return TransactionDetailsItem(
                              title: item.key ?? '',
                              value: item.value ?? '',
                            );
                          }),
                          Divider(
                            color: context.divider,
                            thickness: 4,
                          ),
                          TransactionDetailsItem(
                            title: AppLocalizations.of(context)!.commonDateLabel,
                            value: receipt.receiptDateTime ?? '',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const .symmetric(horizontal: 20, vertical: 10),
              child: BoundedContent(
                child: Column(
                  mainAxisSize: .min,
                  crossAxisAlignment: .center,
                  children: [
                    if (receipt.status == 1)
                      Row(
                        children: [
                          Expanded(
                            child: FormButton(
                              backgroundColor: context.cardBg,
                              foregroundColor: context.textPrimary,
                              onPressed: () {},
                              text: AppLocalizations.of(context)!.commonShare,
                              icon: Icons.share_outlined,
                              buttonIconAlignment: .left,
                              iconSize: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FormButton(
                              backgroundColor: context.cardBg,
                              foregroundColor: context.textPrimary,
                              onPressed: () {},
                              text: AppLocalizations.of(context)!.commonSave,
                              icon: Icons.group_outlined,
                              buttonIconAlignment: .left,
                              iconSize: 20,
                            ),
                          ),
                        ],
                      )
                    else
                      FormButton(
                        backgroundColor: context.cardBg,
                        foregroundColor: context.textPrimary,
                        onPressed: () {},
                        text: AppLocalizations.of(context)!.historySubmitComplain,
                        svgIcon: 'assets/img/complaint.svg',
                        buttonIconAlignment: .left,
                        iconSize: 20,
                      ),
                    const SizedBox(height: Spacing.xl),
                    FormButton(
                      onPressed: () {
                        AppRouter.router.popUntilNamedRoutes([
                          DashboardPage.route.path,
                          ServicePage.route.path,
                          HistoryPage.route.path,
                        ]);
                      },
                      text: AppLocalizations.of(context)!.commonBackToHome,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    switch (receipt.status) {
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
              AppLocalizations.of(context)!.historyTransactionSuccessful,
              style: context.display2,
            ),
            Text(
              AppLocalizations.of(context)!.historyTransactionCompleteSubtitle,
              style: context.smallDetails.copyWith(
                color: context.textPrimary,
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
              AppLocalizations.of(context)!.historyTransactionFailed,
              style: context.display2.copyWith(
                color: AppColors.danger,
              ),
            ),
          ],
        );
    }

    return Text(
      AppLocalizations.of(context)!.historyTransactionReceipt,
      style: context.display2,
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
                  ? context.header4.copyWith(
                      color: context.textPrimary,
                    )
                  : context.caption.copyWith(
                      color: context.textSecondary,
                    ),
            ),
          ),
          const SizedBox(width: Spacing.xl),
          Expanded(
            child: Text(
              value,
              textAlign: .right,
              style: context.header4.copyWith(
                color: context.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
