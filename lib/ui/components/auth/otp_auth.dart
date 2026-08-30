import 'package:flutter/material.dart';

import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/forms.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';

class OtpAuthenticator extends StatefulWidget {
  const OtpAuthenticator({
    super.key,
    required this.authMode,
    required this.onSuccess,
    this.allowBiometric = false,
    required this.end,
    this.onResendShortCode,
  });
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/otp-auth',
  );
  final Map<String, dynamic> authMode;
  final void Function(String) onSuccess;
  final bool allowBiometric;
  final void Function() end;
  final void Function()? onResendShortCode;

  @override
  State<OtpAuthenticator> createState() => _OtpAuthenticatorState();
}

class _OtpAuthenticatorState extends State<OtpAuthenticator> {
  final _otp = ValueNotifier('');

  Map<String, dynamic> get _data => widget.authMode['data'] ?? {};
  int get _length => _data['fieldLength'] ?? 6;

  @override
  void dispose() {
    _otp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return MainLayout(
      subtitleWidget: Column(
        mainAxisSize: .min,
        mainAxisAlignment: .center,
        crossAxisAlignment: .center,
        children: [
          Text(
            _data['fieldCaption'] ?? l10n.authEnterOtp,
            textAlign: .center,
            style: context.display1.copyWith(
              color: context.textPrimary,
            ),
          ),
          Text(
            _data['description'] ?? l10n.otpAuthDescription,
            textAlign: .center,
            style: context.caption,
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
                    widget.end();
                    widget.onSuccess(_otp.value);
                  },
                  enabled: value.length == _length,
                  text: l10n.commonContinue,
                );
              },
            ),
          ),
        ],
      ),
      child: Form(
        child: Column(
          children: [
            FormOtpInput(
              count: _length,
              autoFocus: true,
              // Not FormPinInput — that's the PIN-entry wrapper and hardcodes
              // enableAutofill: false, which also disables paste (see
              // FormOtpInput's maxLengthEnforcement). This field gets an
              // SMS-delivered code, not a PIN, so it needs both.
              onChanged: (value) {
                _otp.value = value;
              },
              onCompleted: (value) {
                _otp.value = value;
                widget.end();
                widget.onSuccess(value);
              },
              onResend: widget.onResendShortCode,
            ),
          ],
        ),
      ),
    );
  }
}
