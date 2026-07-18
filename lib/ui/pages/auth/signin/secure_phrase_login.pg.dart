import 'package:bigpay/data/models/verify_user_data/verify_user_data.dart';
import 'package:bigpay/ui/pages/auth/signin/otp_login.pg.dart';
import 'package:bigpay/utils/message.util.dart';
import 'package:flutter/material.dart';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/models/actions/login/verify_secure_phrase_login_action.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/button.dart';
import 'package:bigpay/ui/components/forms/input.dart';
import 'package:bigpay/ui/components/process_builder.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/pages/auth/signin/signin.dart';
import 'package:bigpay/ui/theme/app_typography.dart';

class SecurePhraseLoginPage extends StatefulWidget {
  const SecurePhraseLoginPage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/auth/secure-phrase-login',
  );

  @override
  State<SecurePhraseLoginPage> createState() => _SecurePhraseLoginPageState();
}

class _SecurePhraseLoginPageState extends State<SecurePhraseLoginPage> {
  ExecuteProcessEvent? mainEvent;

  final _answerFocusNode = FocusNode();
  final _answerController = TextEditingController();

  final _canSubmit = ValueNotifier(false);

  @override
  void dispose() {
    _answerFocusNode.dispose();
    _answerController.dispose();
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
          SignIn.verifyUserData = snapshot.data!;
          AppRouter.router.push(
            OtpLoginPage.route.path,
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
      child: MainLayout(
        title: 'Enter your secure phrase',
        titleStyle: AppTypography.display1,
        subtitle:
            'Customize your private Q&A for faster verification and safer digital payments.',
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
                label: 'Answer to the Question',
                focusNode: _answerFocusNode,
                controller: _answerController,
                onChanged: _onChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onChanged(_) {
    _canSubmit.value = _answerController.text.isNotEmpty;
  }

  void _onContinue() {
    FocusScope.of(context).unfocus();

    mainEvent = context.dispatchProcess(
      VerifySecurePhraseLoginAction(
        payload: VerifySecurePhraseLoginActionPayload(
          requestId: SignIn.newDeviceLoginData?.requestId ?? '',
          securityAnswer: _answerController.text,
        ),
      ),
    );
  }
}
