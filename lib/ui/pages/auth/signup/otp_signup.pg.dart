import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/data/models/start_sign_up_data/start_sign_up_data.dart';
import 'package:bigpay/models/actions/signup/resend_otp_signup_action.dart';
import 'package:bigpay/models/actions/signup/verify_otp_signup_action.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/button.dart';
import 'package:bigpay/ui/components/forms/otp_input.dart';
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

  final StartSignUpData data;

  static PageRouteDefinition route = PageRouteDefinition(
    path: '/auth/otp-signup',
  );

  @override
  State<OtpSignUpPage> createState() => _OtpSignUpPageState();
}

class _OtpSignUpPageState extends State<OtpSignUpPage> {
  final _otp = ValueNotifier('');
  late StartSignUpData _data = widget.data;
  final _id = Uuid().v4();
  ExecuteProcessEvent? mainEvent;
  ExecuteProcessEvent? resentOtpEvent;

  @override
  void dispose() {
    _otp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ProcessBloc, ProcessState>(
          listenWhen: (previous, current) => current.event == resentOtpEvent,
          listener: (context, state) {
            if (state is ExecutingProcess) {
              MessageUtil.displayLoading(context);
              return;
            } else {
              MessageUtil.close(context);
            }

            if (state is ProcessExecuted) {
              _data = state.result.data as StartSignUpData;
              return;
            }

            if (state is ExecuteProcessError) {
              MessageUtil.displayErrorDialog(
                context,
                message: state.error.message,
              );
              return;
            }
          },
        ),
        BlocListener<ProcessBloc, ProcessState>(
          listenWhen: (previous, current) => current.event == mainEvent,
          listener: (context, state) {
            if (state is ExecutingProcess) {
              MessageUtil.displayLoading(context);
              return;
            } else {
              MessageUtil.close(context);
            }

            if (state is ProcessExecuted) {
              SignUp.registrationId = state.result.data as String;
              AppRouter.router.push(
                CreatePasswordSignUpPage.route.path,
              );

              return;
            }

            if (state is ExecuteProcessError) {
              MessageUtil.displayErrorDialog(
                context,
                message: state.error.message,
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
              _data.otpData?.message ?? '',
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

    resentOtpEvent = ExecuteProcessEvent(
      id: _id,
      action: ResendOtpSignUpAction(
        payload: ResendOtpSignUpActionPayload(
          otpId: _data.otpData?.otpId ?? '',
        ),
      ),
    );

    context.read<ProcessBloc>().add(resentOtpEvent!);
  }

  void _onVerify() {
    FocusScope.of(context).unfocus();

    mainEvent = ExecuteProcessEvent(
      id: _id,
      action: VerifyOtpSignUpAction(
        payload: VerifyOtpSignUpActionPayload(
          otpId: _data.otpData?.otpId ?? '',
          otpValue: _otp.value,
        ),
      ),
    );

    context.read<ProcessBloc>().add(mainEvent!);
  }
}
