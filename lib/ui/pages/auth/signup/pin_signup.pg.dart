import 'package:bigpay/routes/app_router.dart';
import 'package:flutter/material.dart';

import 'package:bigpay/ui/components/forms/button.dart';
import 'package:bigpay/ui/components/forms/pin_unified_input.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';

class PinSignUpPage extends StatefulWidget {
  const PinSignUpPage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(path: '/auth/create-pin-signup');

  @override
  State<PinSignUpPage> createState() => _PinSignUpPageState();
}

class _PinSignUpPageState extends State<PinSignUpPage> {
  final _pinFocusNode = FocusNode();
  final _confirmPinFocusNode = FocusNode();

  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();

  final _canSubmit = ValueNotifier(false);

  @override
  void dispose() {
    _pinFocusNode.dispose();
    _confirmPinFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Set Security PIN',
      subtitle:
          'Set a 6-digit code to authorize payments and keep your wallet secure.',
      bottomNav: ValueListenableBuilder(
        valueListenable: _canSubmit,
        builder: (context, value, child) {
          return FormButton(
            enabled: value,
            onPressed: () {},
            text: 'Save',
          );
        },
      ),
      child: Form(
        child: Column(
          mainAxisSize: .min,
          mainAxisAlignment: .start,
          crossAxisAlignment: .center,
          children: [
            FormPinUnifiedInput(
              label: 'Enter 6-digit PIN',
              length: 6,
              focusNode: _pinFocusNode,
              controller: _pinController,
              next: (_) {
                _confirmPinFocusNode.requestFocus();
              },
              onChanged: _onChanged,
            ),
            const SizedBox(height: 15),
            FormPinUnifiedInput(
              label: 'Confirm PIN',
              length: 6,
              focusNode: _confirmPinFocusNode,
              controller: _confirmPinController,
              onChanged: _onChanged,
            ),
          ],
        ),
      ),
    );
  }

  void _onChanged(_) {
    _canSubmit.value =
        _pinController.text.isNotEmpty && _confirmPinController.text.isNotEmpty;
  }
}
