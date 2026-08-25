import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/forms.dart';
import 'package:bigpay/ui/components/step_progress.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/pages/kyc/contact-info-kyc.pg.dart';
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
      stepIndicator: StepProgress(
        currentStep: 1,
        totalSteps: 3,
        labels: ['ID', 'Selfie', 'Contact'],
      ),
      bottom: PreferredSize(
        preferredSize: Size.zero,
        child: SizedBox.shrink(),
      ),
      bottomNav: FormButton(
        onPressed: () {
          AppRouter.router.push(ContactInfoKycPage.route.path);
        },
        text: l10n.commonContinue,
      ),
      child: Column(
        mainAxisSize: .min,
        mainAxisAlignment: .start,
        crossAxisAlignment: .center,
        children: [
          SvgPicture.asset(SvgImages.selfie),
          const SizedBox(height: Spacing.xl),
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 285,
            ),
            child: Text(
              l10n.kycTakeSelfieTitle,
              textAlign: .center,
              style: context.display2,
            ),
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 285,
            ),
            child: Text(
              l10n.kycSelfieMatchSubtitle,
              textAlign: .center,
              style: context.smallDetails,
            ),
          ),
          const SizedBox(height: Spacing.xl),
          InfoItem(
            icon: 'assets/img/identify.svg',
            title: l10n.kycIdentityVerificationTitle,
            subtitle: l10n.kycScanCardSubtitle,
          ),
          const SizedBox(height: 10),
          InfoItem(
            icon: 'assets/img/encrypted.svg',
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
