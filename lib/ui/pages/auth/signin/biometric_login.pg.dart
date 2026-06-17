import 'package:bigpay/ui/components/forms/button.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/ui/theme/assets/app_images.dart';
import 'package:flutter/material.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BiometricLoginPage extends StatefulWidget {
  const BiometricLoginPage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(path: '/auth/biometric-login');

  @override
  State<BiometricLoginPage> createState() => _BiometricLoginPageState();
}

class _BiometricLoginPageState extends State<BiometricLoginPage> {
  @override
  Widget build(BuildContext context) {
    return MainLayout(
      subtitleWidget: Align(
        alignment: .center,
        child: SvgPicture.asset(
          SvgImages.icon,
          height: 50,
        ),
      ),
      bottomNav: Column(
        mainAxisSize: .min,
        children: [
          FormButton(onPressed: () {}, text: 'Unlock with Biometrics'),
          SizedBox(height: 10),
          TextButton(
            onPressed: () {},
            child: Text(
              'Login with Password',
              style: AppTypography.buttons.copyWith(
                fontSize: 14,
                color: AppColors.black,
                decoration: .underline,
              ),
            ),
          ),
        ],
      ),
      child: Center(
        child: IconButton(
          onPressed: () {},
          icon: SvgPicture.asset(
            SvgImages.biometric,
            width: 104,
          ),
        ),
      ),
    );
  }
}
