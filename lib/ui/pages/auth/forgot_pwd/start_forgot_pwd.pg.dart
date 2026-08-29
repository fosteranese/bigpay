import 'package:flutter/material.dart';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/data/models/verify_user_data/verify_user_data.dart';
import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/l10n/flow_steps.dart';
import 'package:bigpay/models/actions/forgot_pwd/start_forgot_pwd_action.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/button.dart';
import 'package:bigpay/ui/components/forms/input.dart';
import 'package:bigpay/ui/components/forms/password_input.dart';
import 'package:bigpay/ui/components/process_builder.dart';
import 'package:bigpay/ui/components/step_progress.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/pages/auth/forgot_pwd/forgot_pwd.dart';
import 'package:bigpay/ui/pages/auth/start_forgot_secure_phrase.pg.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/utils/message.util.dart';
import 'package:bigpay/utils/validator.util.dart';

class StartForgotPasswordPage extends StatefulWidget {
  const StartForgotPasswordPage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/auth/start-forgot-pwd',
  );

  @override
  State<StartForgotPasswordPage> createState() =>
      _StartForgotPasswordPageState();
}

class _StartForgotPasswordPageState extends State<StartForgotPasswordPage> {
  ExecuteProcessEvent? mainEvent;
  final _formKey = GlobalKey<FormState>();
  final _phoneNumberFocusNode = FocusNode();
  final _securePhraseFocusNode = FocusNode();

  final _phoneNumberController = TextEditingController(
    text: ForgotPwd.phoneNumber,
  );
  final _securePhraseController = TextEditingController();

  final _canSubmit = ValueNotifier(false);

  @override
  void dispose() {
    _phoneNumberFocusNode.dispose();
    _securePhraseFocusNode.dispose();

    _phoneNumberController.dispose();
    _securePhraseController.dispose();

    _canSubmit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProcessListener<VerifyUserData>(
      event: () => mainEvent,
      listener: (context, snapshot) {
        if (snapshot.isLoading) {
          MessageUtil.displayLoading(context);
          return;
        } else {
          MessageUtil.close(context);
        }

        if (snapshot.hasData) {
          ForgotPwd.phoneNumber = _phoneNumberController.text.trim();
          ForgotPwd.securePhrase = _securePhraseController.text.trim();
          ForgotPwd.verifyUserData = snapshot.data;
          AppRouter.router.push(
            OtpForgotPasswordPage.route.path,
          );
        }

        if (snapshot.hasError) {
          MessageUtil.displayErrorDialog(
            context,
            message: snapshot.error!.message,
          );
          return;
        }
      },
      child: MainLayout(
        maxWidth: 480,
        title: AppLocalizations.of(context)!.authForgotPasswordTitle,
        titleStyle: context.display1,
        stepIndicator: StepProgress(
          currentStep: 0,
          totalSteps: 3,
          labels: AppLocalizations.of(context)!.forgotPwdSteps,
        ),
        bottomSize: 60,
        bottomNav: ValueListenableBuilder(
          valueListenable: _canSubmit,
          builder: (context, value, child) {
            return FormButton(
              enabled: value,
              onPressed: _onContinue,
              text: AppLocalizations.of(context)!.commonContinue,
            );
          },
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: .min,
            mainAxisAlignment: .start,
            crossAxisAlignment: .center,
            children: [
              FormInput(
                label: AppLocalizations.of(context)!.commonPhoneNumberLabel,
                focusNode: _phoneNumberFocusNode,
                controller: _phoneNumberController,
                validator: Validator.phoneValidator(
                  AppLocalizations.of(context)!.validationPhoneInvalid,
                ),
                next: (_) {
                  _securePhraseFocusNode.requestFocus();
                },
                onChanged: _onChanged,
              ),
              const SizedBox(height: Spacing.lg),
              FormPasswordInput(
                label: AppLocalizations.of(context)!.authAnswerToSecurePhraseLabel,
                focusNode: _securePhraseFocusNode,
                controller: _securePhraseController,
                validator: Validator.requiredField(
                  AppLocalizations.of(context)!.validationAnswerRequired,
                ),
                onChanged: _onChanged,
              ),
              Align(
                alignment: .topCenter,
                child: TextButton(
                  onPressed: () {
                    AppRouter.router.push(
                      StartForgotSecurePhrasePage.route.path,
                    );
                  },
                  child: Text(
                    AppLocalizations.of(context)!.authForgotSecretAnswer,
                    style: context.smallDetails.copyWith(
                      color: context.textPrimary,
                      decoration: .underline,
                    ),
                    textAlign: .center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onChanged(_) {
    _canSubmit.value =
        _phoneNumberController.text.isNotEmpty &&
        _securePhraseController.text.isNotEmpty;
  }

  void _onContinue() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    mainEvent = context.dispatchProcess(
      StartForgotPwdAction(
        payload: StartForgotPwdActionPayload(
          phoneNumber: _phoneNumberController.text.trim(),
          securityAnswer: _securePhraseController.text,
        ),
      ),
    );
  }
}
