import 'package:bigpay/utils/app_state.util.dart';
import 'package:flutter/material.dart';

import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/l10n/flow_steps.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/button.dart';
import 'package:bigpay/ui/components/forms/input.dart';
import 'package:bigpay/ui/components/forms/select_input.dart';
import 'package:bigpay/ui/components/step_progress.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/pages/auth/signup/signup.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/utils/validator.util.dart';

class CreateSecurePhrasePage extends StatefulWidget {
  const CreateSecurePhrasePage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/auth/create-secure-phrase-signup',
  );

  @override
  State<CreateSecurePhrasePage> createState() => _CreateSecurePhrasePageState();
}

class _CreateSecurePhrasePageState extends State<CreateSecurePhrasePage> {
  final _formKey = GlobalKey<FormState>();
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
    final l10n = AppLocalizations.of(context)!;
    return MainLayout(
      maxWidth: 480,
      title: l10n.authCreateSecurePhraseTitle,
      titleStyle: context.display1,
      stepIndicator: StepProgress(
        currentStep: 3,
        totalSteps: 5,
        labels: l10n.signupSteps,
      ),
      subtitleWidget: Column(
        mainAxisSize: .min,
        children: [
          Text(
            l10n.authSecurePhraseSubtitle,
            style: context.smallDetails,
          ),
        ],
      ),
      bottomNav: ValueListenableBuilder(
        valueListenable: _canSubmit,
        builder: (context, value, child) {
          return FormButton(
            enabled: value,
            onPressed: _continue,
            text: l10n.commonContinue,
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
            FormSelectInput(
              label: l10n.authChooseQuestionLabel,
              placeholder: l10n.commonSelectPlaceholder,
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
            const SizedBox(height: Spacing.lg),
            FormInput(
              label: l10n.authAnswerToQuestionLabel,
              focusNode: _answerFocusNode,
              controller: _answerController,
              validator: Validator.requiredField(
                l10n.validationFieldRequired,
              ),
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

    if (!_formKey.currentState!.validate()) return;

    SignUp.secretQuestion = _questionController.text.trim();
    SignUp.secretAnswer = _answerController.text.trim();

    AppRouter.router.push(PinSignUpPage.route.path);
  }
}
