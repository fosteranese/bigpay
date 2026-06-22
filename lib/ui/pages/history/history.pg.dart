import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:flutter/material.dart';

import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/forms.dart';
import 'package:bigpay/ui/layouts/list.lo.dart';
import 'package:bigpay/ui/pages/wallets/virtual.pg.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/utils/app_modal.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/history',
  );

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return ListLayout(
      appBarColor: AppColors.white,
      appBarBottomColor: 5,
      bodyColor: AppColors.white,
      miniTitle: 'Transactions',
      bottom: PreferredSize(
        preferredSize: Size(double.maxFinite, 70),
        child: Container(
          width: double.maxFinite,
          padding: .only(left: 20, right: 20, bottom: 15),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: FormInput(
                  placeholder: 'Search',
                  controller: TextEditingController(),
                  suffix: Icon(Icons.search),
                ),
              ),
              const SizedBox(width: 5),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.white,
                  fixedSize: Size(48, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: .circular(12),
                    side: .new(
                      color: AppColors.tertiary,
                    ),
                  ),
                ),
                onPressed: _onOpenFilter,
                icon: Icon(Icons.filter_list_outlined),
              ),
            ],
          ),
        ),
      ),

      child: (scrollController) => ListView.builder(
        controller: scrollController,
        itemBuilder: (context, index) {
          return TransactionListItem();
        },
      ),
    );
  }

  void _onOpenFilter() {
    AppModal.showBottomModal(
      context,
      label: 'Filter',
      padding: .all(20),
      actions: [
        TextButton(
          onPressed: () {},
          child: Text(
            'Clear Filter',
            style: AppTypography.formLabels.copyWith(
              decoration: .underline,
            ),
          ),
        ),
      ],
      children: [
        const SizedBox(height: 10),
        FormSelectInput(
          label: 'Sub Category',
          placeholder: 'Search...',
          controller: TextEditingController(),
        ),
        const SizedBox(height: 10),
        FormSelectInput(
          label: 'Sub Category',
          placeholder: 'Search...',
          controller: TextEditingController(),
        ),
        const SizedBox(height: 10),
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
  }
}
