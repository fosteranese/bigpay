import 'package:flutter/material.dart';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/models/actions/forgot_pwd/complete_forgot_pwd_action.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/button.dart';
import 'package:bigpay/ui/components/forms/password_input.dart';
import 'package:bigpay/ui/components/process_builder.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/pages/auth/forgot_pwd/forgot_pwd.dart';
import 'package:bigpay/ui/pages/auth/signin/signin.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/utils/message.util.dart';

class CreatePwdForgotPwdPage extends StatefulWidget {
  const CreatePwdForgotPwdPage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/auth/create-pwd-forgot-pwd',
  );

  @override
  State<CreatePwdForgotPwdPage> createState() => _CreatePwdForgotPwdPageState();
}

class _CreatePwdForgotPwdPageState extends State<CreatePwdForgotPwdPage> {
  ExecuteProcessEvent? mainEvent;
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
    return ProcessListener<Null>(
      event: () => mainEvent,
      listener: (context, snapshot) {
        if (snapshot.isLoading) {
          MessageUtil.displayLoading(context);
          return;
        } else {
          MessageUtil.close(context);
        }

        if (snapshot.hasError) {
          MessageUtil.displayErrorDialog(
            context,
            message: snapshot.error!.message,
          );
          return;
        }

        SignIn.phoneNumber = ForgotPwd.phoneNumber;
        ForgotPwd.clear();
        AppRouter.router.popUntilNamed(NewLoginPage.route.name);

        MessageUtil.displaySuccessFullDialog(
          context,
          title: 'Successful',
          message:
              'Your password has been reset successfully. You can use your new password to log in now',
        );
        return;
      },
      child: MainLayout(
        maxWidth: 480,
        title: 'Create Password',
        titleStyle: AppTypography.display1,
        bottomSize: 60,
        bottomNav: ValueListenableBuilder(
          valueListenable: _canSubmit,
          builder: (context, value, child) {
            return FormButton(
              enabled: value,
              onPressed: _onContinue,
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
                style: context.caption,
                textAlign: .center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onChanged(_) {
    _canSubmit.value =
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty;
  }

  void _onContinue() {
    FocusScope.of(context).unfocus();

    mainEvent = context.dispatchProcess(
      CompleteForgotPwdAction(
        payload: CompleteForgotPwdActionPayload(
          requestId: ForgotPwd.requestId,
          password: _passwordController.text,
        ),
      ),
    );
  }
}
