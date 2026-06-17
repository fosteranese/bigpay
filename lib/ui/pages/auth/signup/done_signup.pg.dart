import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/theme/assets/app_images.dart';
import 'package:flutter/material.dart';

import 'package:bigpay/ui/components/forms/button.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DoneSignUpPage extends StatefulWidget {
  const DoneSignUpPage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(path: '/auth/done-signup');

  @override
  State<DoneSignUpPage> createState() => _DoneSignUpPageState();
}

class _DoneSignUpPageState extends State<DoneSignUpPage> {
  final _otp = ValueNotifier('');

  @override
  void dispose() {
    _otp.dispose();
    super.dispose();
  }

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
        text: 'Get Started',
      ),
      child: Column(
        mainAxisSize: .max,
        crossAxisAlignment: .center,
        children: [
          CircleAvatar(
            radius: 70,
            backgroundColor: AppColors.tintShade3,
            backgroundImage: AssetImage(JpgImages.avatar),
          ),
          const SizedBox(height: 20),
          Text(
            'Welcome aboard!',
            style: AppTypography.display2,
            textAlign: .center,
          ),
          const SizedBox(height: 10),
          Text(
            'Your account is ready. Welcome to a simpler, faster, and more secure way to manage your digital finances.',
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
