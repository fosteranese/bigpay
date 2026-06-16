import 'package:flutter/material.dart';

import 'package:bigpay/ui/components/forms/button.dart';
import 'package:bigpay/ui/components/forms/otp_input.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';

class OtpSignUpPage extends StatefulWidget {
  const OtpSignUpPage({super.key});
  static String routeName = '/auth/otp-signup';

  @override
  State<OtpSignUpPage> createState() => _OtpSignUpPageState();
}

class _OtpSignUpPageState extends State<OtpSignUpPage> {
  final _otp = ValueNotifier('');

  @override
  void dispose() {
    _otp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      subtitleWidget: Column(
        mainAxisSize: .min,
        mainAxisAlignment: .center,
        crossAxisAlignment: .center,
        children: [
          Text(
            'Enter OTP',
            textAlign: .center,
            style: AppTypography.display1.copyWith(
              color: AppColors.black,
            ),
          ),
          Text(
            'Enter the 6-digit code sent to +233********219',
            textAlign: .center,
            style: AppTypography.p1,
          ),
        ],
      ),
      bottomNav: ValueListenableBuilder(
        valueListenable: _otp,
        builder: (context, value, child) {
          return FormButton(
            onPressed: () {},
            enabled: value.length == 6,
            text: 'Continue',
          );
        },
      ),
      child: Form(
        child: Column(
          children: [
            FormOtpInput(
              count: 6,
              enableAutofill: true,
              onChanged: (value) {
                _otp.value = value;
              },
              onCompleted: (value) {
                _otp.value = value;
              },
              onResend: () {},
            ),
          ],
        ),
      ),
    );
  }
}
