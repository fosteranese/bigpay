import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/input.dart';
import 'package:bigpay/ui/components/forms/radio_button.dart';
import 'package:flutter/material.dart';

import 'package:bigpay/ui/components/forms/button.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AddCardPage extends StatefulWidget {
  const AddCardPage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/wallets/add-card',
  );

  @override
  State<AddCardPage> createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  @override
  Widget build(BuildContext context) {
    return MainLayout(
      miniTitle: 'Add Card',
      bottomSize: 98 + 61 + 56,
      subtitleWidget: Container(
        padding: .symmetric(horizontal: 28, vertical: 19),
        height: 189,
        width: double.maxFinite,
        decoration: BoxDecoration(
          borderRadius: .circular(14),
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.tint,
            ],
            begin: .topLeft,
            end: .bottomRight,
            stops: [
              0.4558, // 45.58%
              1.1780, // 117.8% (Values > 1.0 extend the gradient smoothly off-screen)
            ],
          ),
          image: DecorationImage(
            image: AssetImage('assets/img/card-bg.png'),
            fit: .contain,
            opacity: 0.05,
            alignment: .center,
            repeat: .noRepeat,
            filterQuality: .high,
          ),
        ),

        child: Column(
          mainAxisSize: .max,
          crossAxisAlignment: .start,
          children: [
            Row(
              mainAxisSize: .max,
              mainAxisAlignment: .spaceBetween,
              children: [
                Text(
                  'DEBIT',
                  style: AppTypography.caption.copyWith(
                    fontSize: 15,
                    color: AppColors.white,
                  ),
                ),
                SvgPicture.asset(
                  'assets/img/bigpay-icon.svg',
                  width: 23,
                  colorFilter: .mode(AppColors.white, .srcIn),
                ),
              ],
            ),
            const Spacer(),
            Column(
              mainAxisSize: .min,
              crossAxisAlignment: .start,
              children: [
                Text(
                  '****    ****    ****    6525',
                  textAlign: .left,
                  style: AppTypography.header1.copyWith(
                    color: AppColors.white,
                  ),
                ),

                Row(
                  mainAxisSize: .min,
                  mainAxisAlignment: .start,
                  crossAxisAlignment: .end,
                  children: [
                    Text(
                      'VALID\nTHRU   ',
                      style: AppTypography.small.copyWith(
                        fontSize: 6,
                        color: Color(0xffD7D7D7),
                      ),
                    ),
                    Text(
                      '__/__',
                      style: AppTypography.small.copyWith(
                        fontSize: 14.91,
                        color: Color(0xffD7D7D7),
                        textBaseline: .alphabetic,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisSize: .max,
              mainAxisAlignment: .spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'TOM DOCKERY ADJEI MENSAH',
                    overflow: .ellipsis,
                    style: AppTypography.caption.copyWith(
                      color: Color(0xffD7D7D7),
                    ),
                  ),
                ),
                SvgPicture.asset('assets/img/visa.svg'),
              ],
            ),
          ],
        ),
      ),

      bottomNav: FormButton(
        onPressed: () {},
        enabled: false,
        text: 'Save',
      ),
      child: Column(
        children: [
          FormInput(
            controller: TextEditingController(),
            label: 'Card Holder Name',
          ),
          const SizedBox(height: 10),
          FormInput(
            controller: TextEditingController(),
            label: 'Card Number',
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: FormInput(
                  controller: TextEditingController(),
                  label: 'CVV',
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: FormInput(
                  controller: TextEditingController(),
                  label: 'Expiry Date',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class WalletListItem extends StatelessWidget {
  const WalletListItem({
    super.key,
    required this.id,
  });
  final String id;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const .only(
        bottom: 10,
      ),
      decoration: BoxDecoration(
        borderRadius: .circular(10),
        border: .all(
          color: AppColors.tertiary,
        ),
      ),
      child: Dismissible(
        key: ValueKey(id),
        direction: DismissDirection.endToStart,
        dismissThresholds: const {
          DismissDirection.endToStart: 1,
        },
        background: Container(
          padding: .all(20),
          alignment: .centerLeft,
          decoration: BoxDecoration(
            color: AppColors.danger,
            borderRadius: .circular(10),
            border: .all(
              color: AppColors.tertiary,
            ),
          ),
          child: SvgPicture.asset('assets/img/trash.svg'),
        ),
        secondaryBackground: Container(
          padding: .all(20),
          alignment: .centerRight,
          decoration: BoxDecoration(
            color: AppColors.danger,
            borderRadius: .circular(10),
            border: .all(
              color: AppColors.tertiary,
            ),
          ),
          child: SvgPicture.asset('assets/img/trash.svg'),
        ),

        child: ListTile(
          contentPadding: .symmetric(horizontal: 15),
          leading: SvgPicture.asset('assets/img/bigpay-icon.svg'),
          title: Text(
            'BigPay Virtual Wallet',
            style: AppTypography.caption.copyWith(
              color: AppColors.black,
            ),
          ),
          subtitle: Text(
            'Balance - GHS 20,000.00',
            style: AppTypography.caption,
          ),
          trailing: FormRadioButton(selected: false),
        ),
      ),
    );
  }
}
