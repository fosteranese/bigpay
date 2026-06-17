import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

import 'package:bigpay/ui/components/forms/button.dart';
import 'package:bigpay/ui/components/forms/input.dart';
import 'package:bigpay/ui/components/forms/password_input.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/theme/app_typography.dart';

class StartForgotPasswordPage extends StatefulWidget {
  const StartForgotPasswordPage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(path: '/auth/start-forgot-pwd');

  @override
  State<StartForgotPasswordPage> createState() =>
      _StartForgotPasswordPageState();
}

class _StartForgotPasswordPageState extends State<StartForgotPasswordPage> {
  final _phoneNumberFocusNode = FocusNode();
  final _securePhraseFocusNode = FocusNode();

  final _phoneNumberController = TextEditingController();
  final _securePhraseController = TextEditingController();

  final _canSubmit = ValueNotifier(false);

  @override
  void dispose() {
    _phoneNumberFocusNode.dispose();
    _securePhraseFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Forgot Password',
      bottomSize: 60,
      bottomNav: ValueListenableBuilder(
        valueListenable: _canSubmit,
        builder: (context, value, child) {
          return FormButton(
            enabled: value,
            onPressed: () {},
            text: 'Continue',
          );
        },
      ),
      child: Form(
        child: Column(
          mainAxisSize: .min,
          mainAxisAlignment: .start,
          crossAxisAlignment: .center,
          children: [
            FormInput(
              label: 'Phone Number',
              focusNode: _phoneNumberFocusNode,
              controller: _phoneNumberController,
              next: (_) {
                _securePhraseFocusNode.requestFocus();
              },
              onChanged: _onChanged,
            ),
            const SizedBox(height: 15),
            FormPasswordInput(
              label: 'Answer to Secure Phrase',
              focusNode: _securePhraseFocusNode,
              controller: _securePhraseController,
              onChanged: _onChanged,
            ),
            Align(
              alignment: .topCenter,
              child: TextButton(
                onPressed: () {},
                child: Text(
                  'Forgot Secret Answer?',
                  style: AppTypography.smallDetails.copyWith(
                    color: AppColors.black,
                    decoration: .underline,
                  ),
                  textAlign: .center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onChanged(_) {
    _canSubmit.value =
        _phoneNumberController.text.isNotEmpty &&
        _securePhraseController.text.isNotEmpty;
  }
}
