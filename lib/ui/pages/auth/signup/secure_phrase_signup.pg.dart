import 'package:bigpay/utils/app_state.util.dart';
import 'package:flutter/material.dart';

import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/button.dart';
import 'package:bigpay/ui/components/forms/input.dart';
import 'package:bigpay/ui/components/forms/select_input.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/pages/auth/signup/signup.dart';
import 'package:bigpay/ui/theme/app_typography.dart';

class CreateSecurePhrasePage extends StatefulWidget {
  const CreateSecurePhrasePage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/auth/create-secure-phrase-signup',
  );

  @override
  State<CreateSecurePhrasePage> createState() => _CreateSecurePhrasePageState();
}

class _CreateSecurePhrasePageState extends State<CreateSecurePhrasePage> {
  final _answerFocusNode = FocusNode();
  final _questionFocusNode = FocusNode();

  final _answerController = TextEditingController();
  final _questionController = TextEditingController();

  final _canSubmit = ValueNotifier(false);

  @override
  void dispose() {
    _answerFocusNode.dispose();
    _questionFocusNode.dispose();
    _answerController.dispose();
    _questionController.dispose();
    _canSubmit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      maxWidth: 480,
      title: 'Create a secure phrase',
      titleStyle: AppTypography.display1,
      subtitle:
          'Customize your private Q&A for faster verification and safer digital payments.',
      bottomNav: ValueListenableBuilder(
        valueListenable: _canSubmit,
        builder: (context, value, child) {
          return FormButton(
            enabled: value,
            onPressed: _continue,
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
            FormSelectInput(
              label: 'Choose a Question',
              placeholder: 'Select...',
              focusNode: _questionFocusNode,
              controller: _questionController,
              next: (_) {
                _questionFocusNode.requestFocus();
              },
              onChanged: _onChanged,
              options:
                  AppState.data?.secretQuestions?.map((item) {
                    return FormSelectOption(
                      id: item.questionId ?? '',
                      label: item.title ?? '',
                    );
                  }).toList() ??
                  [],
            ),
            const SizedBox(height: 15),
            FormInput(
              label: 'Answer to the Question',
              focusNode: _answerFocusNode,
              controller: _answerController,
              onChanged: _onChanged,
            ),
          ],
        ),
      ),
    );
  }

  void _onChanged(_) {
    _canSubmit.value =
        _answerController.text.isNotEmpty &&
        _questionController.text.isNotEmpty;
  }

  void _continue() {
    FocusScope.of(context).unfocus();

    SignUp.secretQuestion = _questionController.text.trim();
    SignUp.secretAnswer = _answerController.text.trim();

    AppRouter.router.push(PinSignUpPage.route.path);
  }
}
