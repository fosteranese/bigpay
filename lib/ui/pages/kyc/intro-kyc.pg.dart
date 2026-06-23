import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:flutter/material.dart';

import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/forms.dart';
import 'package:flutter_svg/flutter_svg.dart';

class IntroKycPage extends StatefulWidget {
  const IntroKycPage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/intro-kyc',
  );

  @override
  State<IntroKycPage> createState() => _IntroKycPageState();
}

class _IntroKycPageState extends State<IntroKycPage> {
  @override
  Widget build(BuildContext context) {
    return MainLayout(
      subtitleWidget: Column(
        children: [
          Text(
            'Let’s get you verified',
            textAlign: .center,
            style: AppTypography.display1.copyWith(
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Confirm your Ghana Card details now for a safer, faster experience.',
            textAlign: .center,
            style: AppTypography.smallDetails,
          ),
        ],
      ),
      bottomNav: FormButton(
        onPressed: () {},
        text: 'Continue',
      ),
      builder: (_) => SliverFillRemaining(
        fillOverscroll: true,
        hasScrollBody: false,
        child: SvgPicture.asset('assets/img/ghana-card.svg'),
      ),
    );
  }
}
