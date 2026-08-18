import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/forms.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';

class PinAuthenticator extends StatefulWidget {
  const PinAuthenticator({
    super.key,
    required this.data,
    required this.onSuccess,
    this.allowBiometric = false,
    required this.end,
  });

  static PageRouteDefinition route = PageRouteDefinition(
    path: '/pin-auth',
  );
  final Map<String, dynamic> data;
  final void Function(String) onSuccess;
  final bool allowBiometric;
  final void Function() end;

  @override
  State<PinAuthenticator> createState() => _PinAuthenticatorState();
}

class _PinAuthenticatorState extends State<PinAuthenticator> {
  final _otp = ValueNotifier('');

  @override
  void dispose() {
    _otp.dispose();
    super.dispose();
  }

  int get _length {
    return widget.data['fieldLength'];
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
            widget.data['tooltip'] ?? 'Enter Security PIN',
            textAlign: .center,
            style: AppTypography.display1.copyWith(
              color: context.textPrimary,
            ),
          ),
          Text(
            widget.data['description'] ??
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
                  onPressed: () {
                    widget.onSuccess(_otp.value);
                  },
                  enabled: value.length == _length,
                  text: 'Continue',
                );
              },
            ),
          ),
          if (widget.allowBiometric) const SizedBox(width: 10),
          if (widget.allowBiometric)
            IconButton(
              style: IconButton.styleFrom(
                side: BorderSide(
                  color: AppColors.secondary,
                ),
                fixedSize: Size(48, 48),
              ),
              onPressed: () {
                widget.onSuccess(_otp.value);
              },
              icon: SvgPicture.asset(
                'assets/img/biometric.svg',
                colorFilter: .mode(context.textPrimary, .srcIn),
              ),
            ),
        ],
      ),
      child: Form(
        child: Column(
          children: [
            FormPinInput(
              count: _length,
              autoFocus: true,
              onChanged: (value) {
                _otp.value = value;
              },
              onCompleted: (value) {
                _otp.value = value;
                widget.onSuccess(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}
