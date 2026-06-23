import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:flutter/material.dart';

import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/forms.dart';
import 'package:flutter_svg/flutter_svg.dart';

class InfoKycPage extends StatefulWidget {
  const InfoKycPage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/info-kyc',
  );

  @override
  State<InfoKycPage> createState() => _InfoKycPageState();
}

class _InfoKycPageState extends State<InfoKycPage> {
  @override
  Widget build(BuildContext context) {
    return MainLayout(
      bottom: PreferredSize(
        preferredSize: Size.zero,
        child: SizedBox.shrink(),
      ),
      bottomNav: FormButton(
        onPressed: () {},
        text: 'Continue',
      ),
      child: Column(
        mainAxisSize: .min,
        mainAxisAlignment: .start,
        crossAxisAlignment: .center,
        children: [
          SvgPicture.asset('assets/img/selfie.svg'),
          const SizedBox(height: 20),
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 285,
            ),
            child: Text(
              'Take a Quick Selfie',
              textAlign: .center,
              style: AppTypography.display2,
            ),
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 285,
            ),
            child: Text(
              'We will match your photo against the National Identification Authority (NIA) database to verify it\'s really you',
              textAlign: .center,
              style: AppTypography.smallDetails,
            ),
          ),
          const SizedBox(height: 20),
          InfoItem(
            icon: 'assets/img/identify.svg',
            title: 'Identity verification',
            subtitle: 'Scan your Ghana Card front & back',
          ),
          const SizedBox(height: 10),
          InfoItem(
            icon: 'assets/img/encrypted.svg',
            title: 'Fully encrypted',
            subtitle: 'Your data is encrypted and secure',
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
          color: AppColors.inactiveBorder,
        ),
      ),
      leading: SvgPicture.asset(icon),
      title: Text(
        title,
        style: AppTypography.header3,
      ),
      subtitle: Text(
        subtitle,
        style: AppTypography.smallDetails,
      ),
    );
  }
}
