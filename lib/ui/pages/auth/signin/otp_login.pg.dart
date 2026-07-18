import 'package:bigpay/data/models/response/response.md.dart';
import 'package:bigpay/models/auth_data.dart';
import 'package:bigpay/ui/pages/dashboard.pg.dart';
import 'package:bigpay/utils/app_state.util.dart';
import 'package:flutter/material.dart';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/data/models/verify_user_data/verify_user_data.dart';
import 'package:bigpay/models/actions/login/verify_otp_login_action.dart';
import 'package:bigpay/models/actions/signup/resend_otp_signup_action.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/button.dart';
import 'package:bigpay/ui/components/forms/otp_input.dart';
import 'package:bigpay/ui/components/process_builder.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/pages/auth/signin/signin.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/utils/message.util.dart';

class OtpLoginPage extends StatefulWidget {
  const OtpLoginPage({
    super.key,
  });

  static PageRouteDefinition route = PageRouteDefinition(
    path: '/auth/otp-login',
  );

  @override
  State<OtpLoginPage> createState() => _OtpLoginPageState();
}

class _OtpLoginPageState extends State<OtpLoginPage> {
  final _otp = ValueNotifier('');
  final _error = ValueNotifier<DataError?>(null);
  ExecuteProcessEvent? mainEvent;
  ExecuteProcessEvent? resentOtpEvent;

  @override
  void dispose() {
    _otp.dispose();
    super.dispose();
  }

  int get _length {
    return (SignIn.verifyUserData?.otpData?.length ?? 6);
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
              SignIn.verifyUserData = snapshot.data!;
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
        ProcessListenerConfig<AuthData>(
          event: () => mainEvent,
          listener: (context, snapshot) {
            if (snapshot.isLoading) {
              MessageUtil.displayLoading(context);
              return;
            } else {
              MessageUtil.close(context);
            }

            if (snapshot.hasData) {
              AppState.currentUser = snapshot.data!;
              AppRouter.router.push(
                DashboardPage.route.path,
              );

              return;
            }

            if (snapshot.hasError) {
              _error.value = snapshot.error;
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
              SignIn.verifyUserData?.otpData?.message ?? '',
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
              enabled: value.length == _length,
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
      ResendOtpSignUpAction(
        payload: ResendOtpSignUpActionPayload(
          otpId: SignIn.verifyUserData?.otpData?.otpId ?? '',
        ),
      ),
    );
  }

  void _onVerify() {
    FocusScope.of(context).unfocus();

    mainEvent = context.dispatchProcess(
      VerifyOtpLoginAction(
        payload: VerifyOtpLoginActionPayload(
          otpId: SignIn.verifyUserData?.otpData?.otpId ?? '',
          otpValue: _otp.value,
        ),
      ),
    );
  }
}
