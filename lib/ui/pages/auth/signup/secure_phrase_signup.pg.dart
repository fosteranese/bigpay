import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:flutter/material.dart';

import 'package:bigpay/ui/components/forms/button.dart';
import 'package:bigpay/ui/components/forms/input.dart';
import 'package:bigpay/ui/components/forms/select_input.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';

class CreateSecurePhrasePage extends StatefulWidget {
  const CreateSecurePhrasePage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/auth/create-secure-phrase-signup',
  );

  @override
  State<CreateSecurePhrasePage> createState() => _CreateSecurePhrasePageState();
}

class _CreateSecurePhrasePageState extends State<CreateSecurePhrasePage> {
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _canSubmit = ValueNotifier(false);

  @override
  void dispose() {
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Create a secure phrase',
      titleStyle: AppTypography.display1,
      subtitle:
          'Customize your private Q&A for faster verification and safer digital payments.',
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
            FormSelectInput(
              label: 'Choose a Question',
              placeholder: 'Select...',
              focusNode: _passwordFocusNode,
              controller: _passwordController,
              next: (_) {
                _confirmPasswordFocusNode.requestFocus();
              },
              onChanged: _onChanged,
              options: [
                FormSelectOption(
                  id: 'id',
                  label: 'label',
                ),
              ],
            ),
            const SizedBox(height: 15),
            FormInput(
              label: 'Answer to the Question',
              focusNode: _confirmPasswordFocusNode,
              controller: _confirmPasswordController,
              onChanged: _onChanged,
            ),
          ],
        ),
      ),
    );
  }

  void _onChanged(_) {
    _canSubmit.value =
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty;
  }
}
