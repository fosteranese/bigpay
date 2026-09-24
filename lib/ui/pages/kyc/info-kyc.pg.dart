import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/forms.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/pages/kyc/camera_permission.dart';
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
  /// Set when Continue was blocked on camera access, so returning from
  /// Settings with access granted carries straight on to the camera.
  bool _awaitingPermission = false;
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _onResume);
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _onResume() async {
    if (!_awaitingPermission) return;
    // Status only — requesting here would loop, since the system prompt
    // itself triggers a resume.
    if (!await Permission.camera.isGranted || !mounted) return;
    _openCamera();
  }

  /// The camera page only opens with camera access already granted.
  Future<void> _continue() async {
    if (await ensureCameraPermission(context)) {
      _openCamera();
    } else {
      _awaitingPermission = true;
    }
  }

  void _openCamera() {
    _awaitingPermission = false;
    AppRouter.router.push(FaceCaptureKycPage.route.path);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return MainLayout(
      bottomSize: 0,
      bottomNav: FormButton(
        onPressed: _continue,
        text: l10n.commonContinue,
      ),
      child: Column(
        mainAxisSize: .min,
        mainAxisAlignment: .start,
        crossAxisAlignment: .center,
        children: [
          KycHero(
            // Explicit height (the asset's own): an SvgPicture reports no
            // intrinsic height until it has loaded, which made the page's
            // SliverFillRemaining size this column short and overflow.
            visual: SvgPicture.asset(SvgImages.selfie, height: 115),
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
    // A plain Row, not a ListTile: ListTile under-reports its intrinsic
    // height for a wrapping subtitle, and this page's SliverFillRemaining
    // sizes the column from intrinsics — so it overflowed on small phones.
    return Container(
      padding: const .symmetric(horizontal: Spacing.lg, vertical: Spacing.md),
      decoration: BoxDecoration(
        borderRadius: .circular(12),
        border: .all(color: context.border),
      ),
      child: Row(
        children: [
          SvgPicture.asset(icon, width: 36, height: 36),
          const SizedBox(width: Spacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(title, style: context.header3),
                const SizedBox(height: 2),
                Text(subtitle, style: context.smallDetails),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
