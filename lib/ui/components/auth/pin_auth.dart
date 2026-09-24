import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/forms.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/utils/biometric.util.dart';

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
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    if (widget.allowBiometric) {
      BiometricUtil.isTransactionEnabled.then((enabled) {
        if (mounted) setState(() => _biometricEnabled = enabled);
      });
    }
  }

  @override
  void dispose() {
    _otp.dispose();
    super.dispose();
  }

  int get _length {
    return widget.data['fieldLength'];
  }

  Future<void> _authenticateWithBiometric() async {
    final l10n = AppLocalizations.of(context)!;
    final result = await BiometricUtil.authenticate(
      l10n.authBiometricTransactionReason,
    );
    if (result != BiometricResult.success) return;

    final pin = await BiometricUtil.readPin();
    if (!mounted || pin == null || pin.isEmpty) return;

    widget.end();
    widget.onSuccess(pin);
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
            widget.data['tooltip'] ?? l10n.securityEnterPinTooltip,
            textAlign: .center,
            style: context.display1.copyWith(
              color: context.textPrimary,
            ),
          ),
          Text(
            widget.data['description'] ?? l10n.pinAuthDefaultDescription,
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
          if (_biometricEnabled) const SizedBox(width: 10),
          if (_biometricEnabled)
            IconButton(
              style: IconButton.styleFrom(
                side: BorderSide(
                  color: context.accentGreen,
                ),
                fixedSize: Size(48, 48),
              ),
              onPressed: _authenticateWithBiometric,
              icon: SvgPicture.asset(
                'assets/img/biometric.svg',
                colorFilter: .mode(context.textPrimary, .srcIn),
              ),
            ),
        ],
      ),
      child: Center(
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
                  widget.end();
                  widget.onSuccess(value);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
