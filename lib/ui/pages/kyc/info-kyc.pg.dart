import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/forms.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/pages/kyc/face-capture-kyc.pg.dart';
import 'package:bigpay/ui/pages/kyc/kyc_hero.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/assets/app_images.dart';
import 'package:bigpay/ui/theme/app_typography.dart';

class InfoKycPage extends StatefulWidget {
  const InfoKycPage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/kyc/info',
  );

  @override
  State<InfoKycPage> createState() => _InfoKycPageState();
}

class _InfoKycPageState extends State<InfoKycPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return MainLayout(
      bottomSize: 0,
      bottomNav: FormButton(
        onPressed: () {
          AppRouter.router.push(FaceCaptureKycPage.route.path);
        },
        text: l10n.commonContinue,
      ),
      child: Column(
        mainAxisSize: .min,
        mainAxisAlignment: .start,
        crossAxisAlignment: .center,
        children: [
          KycHero(
            visual: SvgPicture.asset(SvgImages.selfie),
            title: l10n.kycTakeSelfieTitle,
            subtitle: l10n.kycSelfieMatchSubtitle,
          ),
          const SizedBox(height: Spacing.xl),
          InfoItem(
            icon: SvgImages.identify,
            title: l10n.kycIdentityVerificationTitle,
            subtitle: l10n.kycScanCardSubtitle,
          ),
          const SizedBox(height: Spacing.md),
          InfoItem(
            icon: SvgImages.encrypted,
            title: l10n.kycFullyEncryptedTitle,
            subtitle: l10n.kycDataEncryptedSubtitle,
          ),
        ],
      ),
    );
  }
}

class InfoItem extends StatelessWidget {
  const InfoItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final String icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: .circular(12),
        side: .new(
          color: context.border,
        ),
      ),
      leading: SvgPicture.asset(icon),
      title: Text(
        title,
        style: context.header3,
      ),
      subtitle: Text(
        subtitle,
        // overflow: .ellipsis,
        style: context.smallDetails,
      ),
    );
  }
}
