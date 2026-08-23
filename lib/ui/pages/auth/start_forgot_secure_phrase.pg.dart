import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/models/actions/forgot_secure_phrase_action.dart';
import 'package:bigpay/ui/components/process_builder.dart';
import 'package:bigpay/ui/pages/auth/forgot_pwd/forgot_pwd.dart';
import 'package:bigpay/utils/message.util.dart';
import 'package:flutter/material.dart';

import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/button.dart';
import 'package:bigpay/ui/components/forms/input.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StartForgotSecurePhrasePage extends StatefulWidget {
  const StartForgotSecurePhrasePage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/auth/start-forgot-secure-phrase',
  );

  @override
  State<StartForgotSecurePhrasePage> createState() =>
      _StartForgotSecurePhrasePageState();
}

class _StartForgotSecurePhrasePageState
    extends State<StartForgotSecurePhrasePage> {
  ExecuteProcessEvent? mainEvent;
  final _phoneNumberFocusNode = FocusNode();
  final _phoneNumberController = TextEditingController(
    text: ForgotPwd.phoneNumber,
  );
  final _emailFocusNode = FocusNode();
  final _emailController = TextEditingController();

  final _canSubmit = ValueNotifier(false);

  @override
  void dispose() {
    _phoneNumberFocusNode.dispose();
    _phoneNumberController.dispose();

    _emailFocusNode.dispose();
    _emailController.dispose();

    _canSubmit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProcessBloc, ProcessState>(
      listenWhen: (previous, current) => current.event == mainEvent,
      listener: (context, state) {
        if (state is ExecutingProcess) {
          MessageUtil.displayLoading(context);
          return;
        } else {
          MessageUtil.close(context);
        }

        if (state is ProcessExecuted) {
          AppRouter.router.popUntilNamed(StartForgotPasswordPage.route.name);
          MessageUtil.displaySuccessFullDialog(
            context,
            message: state.result.message,
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
      child: MainLayout(
        maxWidth: 480,
        title: 'Forgot Secure Phrase',
        titleStyle: AppTypography.display1,
        bottomSize: 60,
        bottomNav: ValueListenableBuilder(
          valueListenable: _canSubmit,
          builder: (context, value, child) {
            return FormButton(
              enabled: value,
              onPressed: _onContinue,
              text: 'Continue',
            );
          },
        ),
        child: Form(
          child: Column(
            mainAxisSize: .min,
            mainAxisAlignment: .start,
            crossAxisAlignment: .center,
            children: [
              FormInput(
                label: 'Phone Number',
                focusNode: _phoneNumberFocusNode,
                controller: _phoneNumberController,
                next: (_) {
                  _emailFocusNode.requestFocus();
                },
                onChanged: _onChanged,
                textInputAction: .next,
              ),
              const SizedBox(height: 15),
              FormInput(
                label: 'Email Address',
                focusNode: _emailFocusNode,
                controller: _emailController,
                next: (_) {
                  FocusScope.of(context).unfocus();
                },
                onChanged: _onChanged,
                textInputAction: .done,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onChanged(_) {
    _canSubmit.value =
        _phoneNumberController.text.isNotEmpty ||
        _emailController.text.isNotEmpty;
  }

  void _onContinue() {
    FocusScope.of(context).unfocus();

    mainEvent = context.dispatchProcess(
      ForgotSecurePhraseAction(
        payload: ForgotSecurePhraseActionPayload(
          phoneNumber: _phoneNumberController.text.trim(),
          email: _emailController.text.trim(),
        ),
      ),
    );
  }
}
