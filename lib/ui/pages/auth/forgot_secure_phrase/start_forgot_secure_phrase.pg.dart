import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:flutter/material.dart';

import 'package:bigpay/ui/components/forms/button.dart';
import 'package:bigpay/ui/components/forms/input.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';

class StartForgotSecurePhrasePage extends StatefulWidget {
  const StartForgotSecurePhrasePage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/auth/start-forgot-secure-phrase',
  );

  @override
  State<StartForgotSecurePhrasePage> createState() =>
      _StartForgotSecurePhrasePageState();
}

class _StartForgotSecurePhrasePageState
    extends State<StartForgotSecurePhrasePage> {
  final _phoneNumberFocusNode = FocusNode();
  final _phoneNumberController = TextEditingController();
  final _canSubmit = ValueNotifier(false);

  @override
  void dispose() {
    _phoneNumberFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Forgot Secure Phrase',
      titleStyle: AppTypography.display1,
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
              next: (_) {},
              onChanged: _onChanged,
            ),
          ],
        ),
      ),
    );
  }

  void _onChanged(_) {
    _canSubmit.value = _phoneNumberController.text.isNotEmpty;
  }
}
