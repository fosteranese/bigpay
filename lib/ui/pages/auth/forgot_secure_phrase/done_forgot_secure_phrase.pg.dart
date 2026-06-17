import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/theme/assets/app_images.dart';
import 'package:flutter/material.dart';

import 'package:bigpay/ui/components/forms/button.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DoneForgotSecurePhrasePage extends StatelessWidget {
  const DoneForgotSecurePhrasePage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(path: '/auth/done-forgot-secure-phrase');

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      showBackBtn: false,
      background: Align(
        alignment: .bottomCenter,
        child: SvgPicture.asset(SvgImages.splashBgIcon),
      ),
      bottomNav: FormButton(
        onPressed: () {},
        text: 'Log In',
      ),
      child: Column(
        mainAxisSize: .max,
        crossAxisAlignment: .center,
        children: [
          Icon(
            Icons.check,
            size: 50,
            color: AppColors.secondary,
          ),
          const SizedBox(height: 20),
          Text(
            'Phone Number Verified!',
            style: AppTypography.display2.copyWith(
              color: AppColors.secondary,
            ),
            textAlign: .center,
          ),
          const SizedBox(height: 10),
          Text(
            'Your secret question has been sent to your phone number (+233********219) and email address t*****09@gmail.com',
            style: AppTypography.smallDetails.copyWith(
              color: AppColors.black,
            ),
            textAlign: .center,
          ),
        ],
      ),
    );
  }
}
