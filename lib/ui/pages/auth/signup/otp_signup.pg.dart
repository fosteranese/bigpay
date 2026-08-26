import 'package:flutter/material.dart';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/data/models/verify_user_data/verify_user_data.dart';
import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/l10n/flow_steps.dart';
import 'package:bigpay/models/actions/signup/resend_otp_signup_action.dart';
import 'package:bigpay/models/actions/signup/verify_otp_signup_action.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/button.dart';
import 'package:bigpay/ui/components/forms/otp_input.dart';
import 'package:bigpay/ui/components/process_builder.dart';
import 'package:bigpay/ui/components/step_progress.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/pages/auth/signup/signup.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/utils/message.util.dart';

class OtpSignUpPage extends StatefulWidget {
  const OtpSignUpPage({
    super.key,
    required this.data,
  });

  final VerifyUserData data;

  static PageRouteDefinition route = PageRouteDefinition(
    path: '/auth/otp-signup',
  );

  @override
  State<OtpSignUpPage> createState() => _OtpSignUpPageState();
}

class _OtpSignUpPageState extends State<OtpSignUpPage> {
  final _otp = ValueNotifier('');
  late VerifyUserData _data = widget.data;
  ExecuteProcessEvent? mainEvent;
  ExecuteProcessEvent? resentOtpEvent;

  @override
  void dispose() {
    _otp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProcessListener(
      listeners: [
        ProcessListenerConfig<VerifyUserData>(
          event: () => resentOtpEvent,
          listener: (context, snapshot) {
            if (snapshot.isLoading) {
              MessageUtil.displayLoading(context);
              return;
            } else {
              MessageUtil.close(context);
            }

            if (snapshot.hasData) {
              _data = snapshot.data!;
              return;
            }

            if (snapshot.hasError) {
              MessageUtil.displayErrorDialog(
                context,
                message: snapshot.error!.message,
              );
              return;
            }
          },
        ),
        ProcessListenerConfig<String>(
          event: () => mainEvent,
          listener: (context, snapshot) {
            if (snapshot.isLoading) {
              MessageUtil.displayLoading(context);
              return;
            } else {
              MessageUtil.close(context);
            }

            if (snapshot.hasData) {
              SignUp.registrationId = snapshot.data!;
              // pushReplacement, not push — once the OTP is verified it's
              // consumed; leaving it in the back-stack would let the user
              // navigate back to a stale, already-used OTP screen.
              AppRouter.router.pushReplacement(
                CreatePasswordSignUpPage.route.path,
              );

              return;
            }

            if (snapshot.hasError) {
              MessageUtil.displayErrorDialog(
                context,
                message: snapshot.error!.message,
              );
              return;
            }
          },
        ),
      ],
      child: MainLayout(
        maxWidth: 480,
        stepIndicator: StepProgress(
          currentStep: 1,
          totalSteps: 5,
          labels: AppLocalizations.of(context)!.signupSteps,
        ),
        subtitleWidget: Column(
          mainAxisSize: .min,
          children: [
            Column(
              mainAxisSize: .min,
              mainAxisAlignment: .center,
              crossAxisAlignment: .center,
              children: [
                Text(
                  AppLocalizations.of(context)!.authEnterOtp,
                  textAlign: .center,
                  style: context.display1.copyWith(
                    color: context.textPrimary,
                  ),
                ),
                Text(
                  _data.otpData?.message ?? '',
                  textAlign: .center,
                  style: context.p1,
                ),
              ],
            ),
          ],
        ),
        bottomNav: ValueListenableBuilder(
          valueListenable: _otp,
          builder: (context, value, child) {
            return FormButton(
              onPressed: _onVerify,
              enabled: value.length == 6,
              text: AppLocalizations.of(context)!.commonContinue,
            );
          },
        ),
        child: Form(
          child: Column(
            children: [
              FormOtpInput(
                count: _data.otpData?.length ?? 6,
                enableAutofill: true,
                onChanged: (value) {
                  _otp.value = value;
                },
                onCompleted: (value) {
                  _otp.value = value;
                  _onVerify();
                },
                onResend: _resentOtp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _resentOtp() {
    FocusScope.of(context).unfocus();

    resentOtpEvent = context.dispatchProcess(
      ResendOtpSignUpAction(
        payload: ResendOtpSignUpActionPayload(
          otpId: _data.otpData?.otpId ?? '',
        ),
      ),
    );
  }

  void _onVerify() {
    FocusScope.of(context).unfocus();

    mainEvent = context.dispatchProcess(
      VerifyOtpSignUpAction(
        payload: VerifyOtpSignUpActionPayload(
          otpId: _data.otpData?.otpId ?? '',
          otpValue: _otp.value,
        ),
      ),
    );
  }
}
