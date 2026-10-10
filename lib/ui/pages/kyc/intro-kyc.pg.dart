import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/pages/kyc/start-kyc.pg.dart';
import 'package:bigpay/ui/pages/kyc/kyc_hero.dart';
import 'package:bigpay/ui/theme/responsive.dart';
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
    // Candybar: the card art is drawn at phone width, so it bleeds edge to
    // edge. Body gutter drops to 0 and the docked CTA re-adds its own.
    final edgeToEdge = context.isCompact;
    return MainLayout(
      bodyHorizontalPadding: edgeToEdge ? 0 : null,
      subtitleWidget: KycHero(
        title: l10n.kycIntroTitle,
        subtitle: l10n.kycIntroSubtitle,
      ),
      bottomNav: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: edgeToEdge ? context.gutter : 0,
        ),
        child: FormButton(
          onPressed: () {
            AppRouter.router.push(StartKycPage.route.path);
          },
          text: l10n.commonContinue,
        ),
      ),
      child: Column(
        mainAxisSize: .min,
        children: [
          if (edgeToEdge)
            // AspectRatio (the artwork's own 375x447), not a FittedBox: it
            // knows its height from the width before the SVG has loaded, so
            // the page's SliverFillRemaining sizes the column correctly.
            AspectRatio(
              aspectRatio: 375 / 447,
              child: SvgPicture.asset(
                SvgImages.ghanaCard,
                fit: BoxFit.fitWidth,
              ),
            )
          else
            Flexible(
              child: AspectRatio(
                aspectRatio: 1.4,
                child: FittedBox(
                  child: SvgPicture.asset(SvgImages.ghanaCard),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
