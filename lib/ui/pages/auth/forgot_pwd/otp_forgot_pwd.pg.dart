import 'package:flutter/material.dart';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/data/models/response/response.md.dart';
import 'package:bigpay/data/models/verify_user_data/verify_user_data.dart';
import 'package:bigpay/models/actions/forgot_pwd/start_forgot_pwd_action.dart';
import 'package:bigpay/models/actions/forgot_pwd/verify_otp_forgot_pwd_action.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/button.dart';
import 'package:bigpay/ui/components/forms/otp_input.dart';
import 'package:bigpay/ui/components/process_builder.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/pages/auth/forgot_pwd/forgot_pwd.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/utils/message.util.dart';

class OtpForgotPasswordPage extends StatefulWidget {
  const OtpForgotPasswordPage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/auth/otp-forgot-pwd',
  );

  @override
  State<OtpForgotPasswordPage> createState() => _OtpForgotPasswordPageState();
}

class _OtpForgotPasswordPageState extends State<OtpForgotPasswordPage> {
  final _otp = ValueNotifier('');
  final _error = ValueNotifier<DataError?>(null);
  ExecuteProcessEvent? mainEvent;
  ExecuteProcessEvent? resentOtpEvent;

  @override
  void dispose() {
    _otp.dispose();
    _error.dispose();
    super.dispose();
  }

  int get _length {
    return (ForgotPwd.verifyUserData?.otpData?.length ?? 6);
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
              ForgotPwd.verifyUserData = snapshot.data!;
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
              ForgotPwd.requestId = snapshot.data ?? '';
              AppRouter.router.push(
                CreatePwdForgotPwdPage.route.path,
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
        ),
      ],
      child: MainLayout(
        subtitleWidget: Column(
          mainAxisSize: .min,
          mainAxisAlignment: .center,
          crossAxisAlignment: .center,
          children: [
            Text(
              'Enter OTP',
              textAlign: .center,
              style: AppTypography.display1.copyWith(
                color: AppColors.black,
              ),
            ),
            Text(
              ForgotPwd.verifyUserData?.otpData?.message ?? '',
              textAlign: .center,
              style: AppTypography.p1,
            ),
          ],
        ),
        bottomNav: ValueListenableBuilder(
          valueListenable: _otp,
          builder: (context, value, child) {
            return FormButton(
              onPressed: _onVerify,
              enabled: value.length == 6,
              text: 'Continue',
            );
          },
        ),
        child: Form(
          child: Column(
            children: [
              ValueListenableBuilder(
                valueListenable: _error,
                builder: (context, error, child) {
                  return FormOtpInput(
                    error: error?.message,
                    count: _length,
                    enableAutofill: true,
                    onChanged: (otp) {
                      _otp.value = otp;
                      if (otp.length < _length && _error.value != null) {
                        _error.value = null;
                      }
                    },
                    onCompleted: (value) {
                      _otp.value = value;
                      _onVerify();
                    },
                    onResend: _resentOtp,
                  );
                },
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
      StartForgotPwdAction(
        payload: StartForgotPwdActionPayload(
          phoneNumber: ForgotPwd.phoneNumber,
          securityAnswer: ForgotPwd.securePhrase,
        ),
      ),
    );
  }

  void _onVerify() {
    FocusScope.of(context).unfocus();

    mainEvent = context.dispatchProcess(
      VerifyOtpForgotPwdAction(
        payload: VerifyOtpForgotPwdActionPayload(
          otpId: ForgotPwd.verifyUserData?.otpData?.otpId ?? '',
          otpValue: _otp.value,
        ),
      ),
    );
  }
}
