import 'package:bigpay/ui/components/forms/button.dart';
import 'package:bigpay/ui/components/forms/input.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:flutter/material.dart';

class StartSignUpPage extends StatefulWidget {
  const StartSignUpPage({super.key});
  static String routeName = '/auth/start-signup';

  @override
  State<StartSignUpPage> createState() => _StartSignUpPageState();
}

class _StartSignUpPageState extends State<StartSignUpPage> {
  final _phoneNumberFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Sign Up',
      subtitleWidget: Row(
        children: [
          Text(
            'Already have an account?',
            style: AppTypography.smallDetails,
          ),
          TextButton(
            style: TextButton.styleFrom(
              tapTargetSize: .shrinkWrap,
            ),
            onPressed: () {},
            child: Text(
              'Sign in',
              style: AppTypography.buttons.copyWith(
                color: AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
      bottomNav: Column(
        mainAxisSize: .min,
        mainAxisAlignment: .end,
        crossAxisAlignment: .center,
        children: [
          Wrap(
            alignment: .center,
            direction: .horizontal,
            runAlignment: .start,
            children: [
              Text(
                'By clicking on continue, you accept our ',
                style: AppTypography.smallDetails,
              ),
              InkWell(
                onTap: () {},
                child: Text(
                  'Terms of Use',
                  style: AppTypography.smallDetailsMedium.copyWith(
                    decoration: .underline,
                  ),
                ),
              ),
              Text(
                ' and ',
                style: AppTypography.smallDetails,
              ),
              InkWell(
                onTap: () {},
                child: Text(
                  'Privacy Policy',
                  style: AppTypography.smallDetailsMedium.copyWith(
                    decoration: .underline,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FormButton(onPressed: () {}, text: 'Continue'),
        ],
      ),
      child: Form(
        child: Column(
          children: [
            FormInput(
              label: 'Phone Number',
              keyboardType: .phone,
              focusNode: _phoneNumberFocusNode,
              controller: TextEditingController(),
              next: (_) {
                _phoneNumberFocusNode.unfocus();
              },
            ),
          ],
        ),
      ),
    );
  }
}
