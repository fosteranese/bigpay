import 'package:bigpay/ui/components/forms/button.dart';
import 'package:bigpay/ui/components/forms/password_input.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:flutter/material.dart';

class CreatePwdForgotPwdPage extends StatefulWidget {
  const CreatePwdForgotPwdPage({super.key});
  static String routeName = '/auth/create-pwd-forgot-pwd';

  @override
  State<CreatePwdForgotPwdPage> createState() => _CreatePwdForgotPwdPageState();
}

class _CreatePwdForgotPwdPageState extends State<CreatePwdForgotPwdPage> {
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
      title: 'Create Password',
      bottomSize: 60,
      bottomNav: ValueListenableBuilder(
        valueListenable: _canSubmit,
        builder: (context, value, child) {
          return FormButton(
            enabled: value,
            onPressed: () {},
            text: 'Save Password',
          );
        },
      ),
      child: Form(
        child: Column(
          mainAxisSize: .min,
          mainAxisAlignment: .start,
          crossAxisAlignment: .center,
          children: [
            FormPasswordInput(
              label: 'Password',
              focusNode: _passwordFocusNode,
              controller: _passwordController,
              next: (_) {
                _confirmPasswordFocusNode.requestFocus();
              },
              onChanged: _onChanged,
            ),
            const SizedBox(height: 15),
            FormPasswordInput(
              label: 'Confirm Password',
              focusNode: _confirmPasswordFocusNode,
              controller: _confirmPasswordController,
              onChanged: _onChanged,
            ),
            const SizedBox(height: 25),
            Text(
              'Password must be at least 6 characters and include letters, numbers, and special characters (e.g. !\$@%).',
              style: AppTypography.caption,
              textAlign: .center,
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
