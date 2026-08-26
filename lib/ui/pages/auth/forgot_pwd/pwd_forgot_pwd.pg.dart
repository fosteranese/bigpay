import 'package:flutter/material.dart';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/l10n/flow_steps.dart';
import 'package:bigpay/models/actions/forgot_pwd/complete_forgot_pwd_action.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/button.dart';
import 'package:bigpay/ui/components/forms/password_input.dart';
import 'package:bigpay/ui/components/password_checklist.dart';
import 'package:bigpay/ui/components/process_builder.dart';
import 'package:bigpay/ui/components/step_progress.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/pages/auth/forgot_pwd/forgot_pwd.dart';
import 'package:bigpay/ui/pages/auth/signin/signin.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
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
  final _passwordMismatch = ValueNotifier(false);

  @override
  void dispose() {
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();

    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _canSubmit.dispose();
    _passwordMismatch.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
          title: l10n.authSuccessfulTitle,
          message: l10n.authPasswordResetSuccessMessage,
        );
        return;
      },
      child: MainLayout(
        maxWidth: 480,
        title: l10n.authCreatePasswordTitle,
        titleStyle: context.display1,
        stepIndicator: StepProgress(
          currentStep: 2,
          totalSteps: 3,
          labels: l10n.forgotPwdSteps,
        ),
        bottomSize: 60,
        bottomNav: ValueListenableBuilder(
          valueListenable: _canSubmit,
          builder: (context, value, child) {
            return FormButton(
              enabled: value,
              onPressed: _onContinue,
              text: l10n.authSavePassword,
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
                label: l10n.commonPasswordLabel,
                focusNode: _passwordFocusNode,
                controller: _passwordController,
                next: (_) {
                  _confirmPasswordFocusNode.requestFocus();
                },
                onChanged: _onChanged,
              ),
              const SizedBox(height: 15),
              FormPasswordInput(
                label: l10n.commonConfirmPasswordLabel,
                focusNode: _confirmPasswordFocusNode,
                controller: _confirmPasswordController,
                onChanged: _onChanged,
              ),
              ValueListenableBuilder(
                valueListenable: _passwordMismatch,
                builder: (context, mismatch, _) {
                  if (!mismatch) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      l10n.passwordMismatch,
                      style: context.smallDetails.copyWith(
                        color: AppColors.danger,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder(
                valueListenable: _passwordController,
                builder: (context, _, _) {
                  return PasswordChecklist(
                    password: _passwordController.text,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onChanged(_) {
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;
    _passwordMismatch.value = confirm.isNotEmpty && password != confirm;
    _canSubmit.value =
        PasswordChecklist.allPassed(password) &&
        confirm.isNotEmpty &&
        password == confirm;
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
