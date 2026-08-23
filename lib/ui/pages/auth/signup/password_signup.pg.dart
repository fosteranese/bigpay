import 'package:flutter/material.dart';

import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/button.dart';
import 'package:bigpay/ui/components/forms/password_input.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/pages/auth/signup/signup.dart';
import 'package:bigpay/ui/theme/app_typography.dart';

class CreatePasswordSignUpPage extends StatefulWidget {
  const CreatePasswordSignUpPage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/auth/create-password-signup',
  );

  @override
  State<CreatePasswordSignUpPage> createState() =>
      _CreatePasswordSignUpPageState();
}

class _CreatePasswordSignUpPageState extends State<CreatePasswordSignUpPage> {
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _canSubmit = ValueNotifier(false);

  @override
  void dispose() {
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _canSubmit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      maxWidth: 480,
      title: 'Create Password',
      titleStyle: AppTypography.display1,
      bottomSize: 60,
      bottomNav: ValueListenableBuilder(
        valueListenable: _canSubmit,
        builder: (context, value, child) {
          return FormButton(
            enabled: value,
            onPressed: _continue,
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
              next: (value) {
                _continue();
              },
            ),
            const SizedBox(height: 25),
            Text(
              'Password must be at least 6 characters and include letters, numbers, and special characters (e.g. !\$@%).',
              style: context.caption,
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

  void _continue() {
    FocusScope.of(context).unfocus();
    SignUp.password = _passwordController.text;

    AppRouter.router.push(CreateSecurePhrasePage.route.path);
  }
}
