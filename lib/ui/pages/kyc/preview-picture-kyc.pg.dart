import 'package:bigpay/ui/components/forms/outline_button.dart';
import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';

import 'package:flutter/material.dart';

import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/forms.dart';

class PicturePreviewKycPage extends StatefulWidget {
  const PicturePreviewKycPage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/kyc/picture-preview',
  );

  @override
  State<PicturePreviewKycPage> createState() => _PicturePreviewKycPageState();
}

class _PicturePreviewKycPageState extends State<PicturePreviewKycPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return MainLayout(
      titleStyle: context.display2,
      bottomSize: 0,
      bottomNav: Column(
        mainAxisSize: .min,
        mainAxisAlignment: .start,
        crossAxisAlignment: .center,
        children: [
          FormButton(
            onPressed: () {},
            text: l10n.kycVerifyPhoto,
          ),
          const SizedBox(height: 10),
          FormOutlineButton(
            onPressed: () {},
            text: l10n.kycRetakePicture,
          ),
        ],
      ),
      child: Form(
        child: Column(
          mainAxisSize: .min,
          mainAxisAlignment: .start,
          crossAxisAlignment: .center,
          children: [
            ConstrainedBox(
              constraints: .new(
                maxWidth: 300,
              ),
              child: Column(
                mainAxisSize: .min,
                mainAxisAlignment: .start,
                crossAxisAlignment: .center,
                children: [
                  Container(
                    padding: const .all(5),
                    decoration: BoxDecoration(
                      borderRadius: .circular(100),
                      border: .all(
                        color: context.accentGreen,
                        width: 1,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 70.5,
                      backgroundColor: AppColors.tintShade1,
                      child: const Icon(
                        Icons.person,
                        size: 100,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.kycReviewPhotoTitle,
                    textAlign: .center,
                    style: context.display2,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.kycReviewPhotoSubtitle,
                    textAlign: .center,
                    style: context.p1.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            CheckListItem(
              title: l10n.kycFaceClearlyVisible,
              subtitle: l10n.kycNoObstructions,
            ),
            CheckListItem(
              title: l10n.kycWellLit,
              subtitle: l10n.kycEvenLighting,
            ),
            CheckListItem(
              isChecked: false,
              title: l10n.kycSlightBlur,
              subtitle: l10n.kycRetakeIfUnclear,
            ),
          ],
        ),
      ),
    );
  }
}

class CheckListItem extends StatelessWidget {
  const CheckListItem({
    super.key,
    required this.title,
    required this.subtitle,
    this.isChecked = true,
  });

  final String title;
  final String subtitle;
  final bool isChecked;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: isChecked
          ? CircleAvatar(
              radius: 18,
              backgroundColor: context.avatarBg,
              child: const Icon(
                Icons.check,
                size: 20,
                color: AppColors.tertiaryBrand,
              ),
            )
          : CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.pending,
              child: const Icon(
                Icons.warning_amber_rounded,
                size: 20,
                color: AppColors.white,
              ),
            ),
      title: Text(
        title,
        style: context.header3,
      ),
      subtitle: Text(
        subtitle,
        style: context.caption,
      ),
    );
  }
}
