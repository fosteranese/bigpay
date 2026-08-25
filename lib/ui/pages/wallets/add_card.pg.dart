import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/input.dart';
import 'package:bigpay/ui/components/forms/radio_button.dart';
import 'package:flutter/material.dart';

import 'package:bigpay/ui/components/forms/button.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/assets/app_images.dart';
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
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _cvvController = TextEditingController();
  final _expiryController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _cvvController.dispose();
    _expiryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return MainLayout(
      miniTitle: l10n.walletsAddCardTitle,
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
                  l10n.walletsDebitLabel,
                  style: context.caption.copyWith(
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
                  style: context.header1.copyWith(
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
                      style: context.small.copyWith(
                        fontSize: 6,
                        color: AppColors.cardOverlay,
                      ),
                    ),
                    Text(
                      '__/__',
                      style: context.small.copyWith(
                        fontSize: 15,
                        color: AppColors.cardOverlay,
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
                    style: context.caption.copyWith(
                      color: AppColors.cardOverlay,
                    ),
                  ),
                ),
                SvgPicture.asset(SvgImages.visa),
              ],
            ),
          ],
        ),
      ),

      bottomNav: FormButton(
        onPressed: () {},
        enabled: false,
        text: l10n.commonSave,
      ),
      child: Column(
        children: [
          FormInput(
            controller: _nameController,
            label: l10n.walletsCardHolderNameLabel,
          ),
          const SizedBox(height: 10),
          FormInput(
            controller: _numberController,
            label: l10n.walletsCardNumberLabel,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: FormInput(
                  controller: _cvvController,
                  label: l10n.walletsCvvLabel,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: FormInput(
                  controller: _expiryController,
                  label: l10n.walletsExpiryDateLabel,
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
          color: context.border,
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
              color: context.border,
            ),
          ),
          child: SvgPicture.asset(SvgImages.trash),
        ),
        secondaryBackground: Container(
          padding: .all(20),
          alignment: .centerRight,
          decoration: BoxDecoration(
            color: AppColors.danger,
            borderRadius: .circular(10),
            border: .all(
              color: context.border,
            ),
          ),
          child: SvgPicture.asset(SvgImages.trash),
        ),

        child: ListTile(
          contentPadding: .symmetric(horizontal: 15),
          leading: SvgPicture.asset(SvgImages.bigpayIcon),
          title: Text(
            AppLocalizations.of(context)!.walletsBigPayVirtualWalletDemo,
            style: context.caption.copyWith(
              color: context.textPrimary,
            ),
          ),
          subtitle: Text(
            AppLocalizations.of(context)!.walletsBalanceDemo,
            style: context.caption,
          ),
          trailing: FormRadioButton(selected: false),
        ),
      ),
    );
  }
}
