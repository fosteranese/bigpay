import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/pages/kyc/start-kyc.pg.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:flutter/material.dart';

import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/forms.dart';
import 'package:bigpay/ui/theme/assets/app_images.dart';
import 'package:flutter_svg/flutter_svg.dart';

class IntroKycPage extends StatefulWidget {
  const IntroKycPage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/kyc',
  );

  @override
  State<IntroKycPage> createState() => _IntroKycPageState();
}

class _IntroKycPageState extends State<IntroKycPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return MainLayout(
      subtitleWidget: Column(
        children: [
          Text(
            l10n.kycIntroTitle,
            textAlign: .center,
            style: context.display1.copyWith(
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.kycIntroSubtitle,
            textAlign: .center,
            style: context.smallDetails,
          ),
        ],
      ),
      bottomNav: FormButton(
        onPressed: () {
          AppRouter.router.push(StartKycPage.route.path);
        },
        text: l10n.commonContinue,
      ),
      builder: (_) => SliverFillRemaining(
        fillOverscroll: true,
        hasScrollBody: false,
        child: SvgPicture.asset(SvgImages.ghanaCard),
      ),
    );
  }
}
