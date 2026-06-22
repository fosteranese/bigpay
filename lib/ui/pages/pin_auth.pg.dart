import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/forms.dart';
import 'package:flutter/material.dart';

import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PinAuthPage extends StatefulWidget {
  const PinAuthPage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/pin-auth',
  );

  @override
  State<PinAuthPage> createState() => _PinAuthPageState();
}

class _PinAuthPageState extends State<PinAuthPage> {
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
            'Enter Security PIN',
            textAlign: .center,
            style: AppTypography.display1.copyWith(
              color: AppColors.black,
            ),
          ),
          Text(
            'Please provide your 6-digit PIN to authorize this action and keep your account secure.',
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
          const SizedBox(width: 10),
          IconButton(
            style: IconButton.styleFrom(
              side: BorderSide(
                color: AppColors.secondary,
              ),
              fixedSize: Size(48, 48),
            ),
            onPressed: () {},
            icon: SvgPicture.asset(
              'assets/img/biometric.svg',
              colorFilter: .mode(AppColors.black, .srcIn),
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
