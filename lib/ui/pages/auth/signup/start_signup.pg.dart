import 'package:flutter/material.dart';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/data/models/verify_user_data/verify_user_data.dart';
import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/l10n/flow_steps.dart';
import 'package:bigpay/models/actions/signup/start_signup_action.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/button.dart';
import 'package:bigpay/ui/components/forms/input.dart';
import 'package:bigpay/ui/components/process_builder.dart';
import 'package:bigpay/ui/components/step_progress.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/pages/auth/signin/signin.dart';
import 'package:bigpay/ui/pages/auth/signup/signup.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/utils/message.util.dart';

class StartSignUpPage extends StatefulWidget {
  const StartSignUpPage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/auth/start-signup',
  );

  @override
  State<StartSignUpPage> createState() => _StartSignUpPageState();
}

class _StartSignUpPageState extends State<StartSignUpPage> {
  final _phoneNumberFocusNode = FocusNode();
  final _phoneNumberController = TextEditingController();
  ExecuteProcessEvent? mainEvent;

  @override
  dispose() {
    _phoneNumberFocusNode.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return MainLayout(
      maxWidth: 480,
      title: l10n.authSignUpTitle,
      titleStyle: context.display1,
      stepIndicator: StepProgress(
        currentStep: 0,
        totalSteps: 5,
        labels: l10n.signupSteps,
      ),
      subtitleWidget: Column(
        mainAxisSize: .min,
        children: [
          Row(
            children: [
              Text(
                l10n.authAlreadyHaveAccount,
                style: context.smallDetails,
              ),
              TextButton(
                style: TextButton.styleFrom(
                  tapTargetSize: .shrinkWrap,
                ),
                onPressed: () {
                  AppRouter.router.push(
                    NewLoginPage.route.path,
                  );
                },
                child: Text(
                  AppLocalizations.of(context)!.authSignInLink,
                  style: context.buttons.copyWith(
                    color: context.accentGreen,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNav: ProcessListener<VerifyUserData>(
        event: () => mainEvent,
        listener: (context, snapshot) {
          if (snapshot.isLoading) {
            MessageUtil.displayLoading(context);
            return;
          } else {
            MessageUtil.close(context);
          }

          if (snapshot.hasData) {
            AppRouter.router.push(
              OtpSignUpPage.route.path,
              extra: snapshot.data,
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
        child: Column(
          mainAxisSize: .min,
          mainAxisAlignment: .end,
          crossAxisAlignment: .center,
          children: [
            Wrap(
              alignment: .center,
              direction: .horizontal,
              runAlignment: .start,
              children: [
                Text(
                  l10n.authTermsPrefix,
                  style: context.smallDetails,
                ),
                InkWell(
                  onTap: () {},
                  child: Text(
                    l10n.authTermsOfUse,
                    style: context.smallDetailsMedium.copyWith(
                      decoration: .underline,
                    ),
                  ),
                ),
                Text(
                  l10n.authAnd,
                  style: context.smallDetails,
                ),
                InkWell(
                  onTap: () {},
                  child: Text(
                    l10n.authPrivacyPolicy,
                    style: context.smallDetailsMedium.copyWith(
                      decoration: .underline,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            FormButton(
              onPressed: _continue,
              text: l10n.commonContinue,
            ),
          ],
        ),
      ),
      child: Form(
        child: Column(
          children: [
            FormInput(
              label: l10n.commonPhoneNumberLabel,
              keyboardType: .phone,
              focusNode: _phoneNumberFocusNode,
              controller: _phoneNumberController,
              next: (_) {
                _continue();
              },
              textInputAction: .done,
            ),
          ],
        ),
      ),
    );
  }

  void _continue() {
    FocusScope.of(context).unfocus();

    final phone = _phoneNumberController.text.trim();
    if (phone.isEmpty) return;

    mainEvent = context.dispatchProcess(
      StartSignUpAction(
        payload: StartSignUpActionPayload(
          phoneNumber: phone,
        ),
      ),
    );
  }
}
