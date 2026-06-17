import 'package:bigpay/ui/components/forms/button.dart';
import 'package:bigpay/ui/components/forms/input.dart';
import 'package:bigpay/ui/components/forms/password_input.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/theme/assets/app_images.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NewLoginPage extends StatefulWidget {
  const NewLoginPage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(path: '/auth/new-login');

  @override
  State<NewLoginPage> createState() => _NewLoginPageState();
}

class _NewLoginPageState extends State<NewLoginPage> {
  final _phoneNumberFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Sign In',
      subtitleWidget: Row(
        children: [
          Text(
            'Don’t have an account?',
            style: AppTypography.smallDetails,
          ),
          TextButton(
            style: TextButton.styleFrom(
              tapTargetSize: .shrinkWrap,
            ),
            onPressed: () {},
            child: Text(
              'Sign up',
              style: AppTypography.buttons.copyWith(
                color: AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
      bottomNav: FormButton(onPressed: () {}, text: 'Sign In'),
      child: Form(
        child: Column(
          mainAxisSize: .min,
          mainAxisAlignment: .start,
          crossAxisAlignment: .center,
          children: [
            FormInput(
              label: 'Phone Number',
              keyboardType: .phone,
              focusNode: _phoneNumberFocusNode,
              controller: TextEditingController(),
              next: (_) {
                _passwordFocusNode.requestFocus();
              },
            ),

            SizedBox(height: 15),
            FormPasswordInput(
              label: 'Password',
              placeholder: 'Password',
              controller: TextEditingController(),
              focusNode: _passwordFocusNode,
            ),
            Row(
              mainAxisSize: .max,
              mainAxisAlignment: .spaceBetween,
              crossAxisAlignment: .start,
              children: [
                TextButton(
                  style: TextButton.styleFrom(padding: .zero),
                  onPressed: () {},
                  child: Row(
                    mainAxisSize: .min,
                    mainAxisAlignment: .start,
                    crossAxisAlignment: .center,
                    children: [
                      SvgPicture.asset(SvgImages.biometric),
                      SizedBox(width: 5),
                      Text(
                        'Biometric Login',
                        style: AppTypography.smallDetails.copyWith(
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(padding: .zero),
                  onPressed: () {},
                  child: Text(
                    'Forgot Password ?',
                    style: AppTypography.smallDetails.copyWith(
                      color: AppColors.black,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
