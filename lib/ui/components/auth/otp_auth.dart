import 'package:flutter/material.dart';

import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/forms.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';

class OtpAuthenticator extends StatefulWidget {
  const OtpAuthenticator({
    super.key,
    required this.onSuccess,
    this.allowBiometric = false,
    required this.end,
  });
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/otp-auth',
  );
  final void Function(String) onSuccess;
  final bool allowBiometric;
  final void Function() end;

  @override
  State<OtpAuthenticator> createState() => _OtpAuthenticatorState();
}

class _OtpAuthenticatorState extends State<OtpAuthenticator> {
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
            'Please provide your 6-digit shortcode send to your phone number to authorize this transaction',
            textAlign: .center,
            style: AppTypography.caption,
          ),
        ],
      ),
      bottomNav: Row(
        children: [
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: _otp,
              builder: (context, value, child) {
                return FormButton(
                  onPressed: () {},
                  enabled: value.length == 6,
                  text: 'Continue',
                );
              },
            ),
          ),
        ],
      ),
      child: Form(
        child: Column(
          children: [
            FormPinInput(
              count: 4,
              autoFocus: true,
              onChanged: (value) {
                _otp.value = value;
              },
              onCompleted: (value) {
                _otp.value = value;
              },
            ),
          ],
        ),
      ),
    );
  }
}
