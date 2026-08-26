import 'package:bigpay/models/actions/auth_action.dart';
import 'package:flutter/material.dart';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/data/models/auth_data/auth_data.dart';
import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/l10n/flow_steps.dart';
import 'package:bigpay/models/actions/signup/complete_signup_action.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/button.dart';
import 'package:bigpay/ui/components/forms/pin_unified_input.dart';
import 'package:bigpay/ui/components/process_builder.dart';
import 'package:bigpay/ui/components/step_progress.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/pages/auth/signup/signup.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/ui/theme/assets/app_images.dart';
import 'package:bigpay/utils/message.util.dart';

class PinSignUpPage extends StatefulWidget {
  const PinSignUpPage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/auth/create-pin-signup',
  );

  @override
  State<PinSignUpPage> createState() => _PinSignUpPageState();
}

class _PinSignUpPageState extends State<PinSignUpPage> {
  ExecuteProcessEvent? mainEvent;

  final _formKey = GlobalKey<FormState>();
  final _pinFocusNode = FocusNode();
  final _confirmPinFocusNode = FocusNode();

  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();

  final _canSubmit = ValueNotifier(false);

  @override
  void dispose() {
    _pinFocusNode.dispose();
    _confirmPinFocusNode.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    _canSubmit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ProcessListener<AuthData>(
      event: () => mainEvent,
      listener: (context, snapshot) {
        if (snapshot.isLoading) {
          MessageUtil.displayLoading(context);
          return;
        } else {
          MessageUtil.close(context);
        }

        if (snapshot.hasData) {
          AuthAction.event = context.dispatchProcess(
            AuthAction(
              payload: AuthActionPayload(
                dataResponse: snapshot.response!,
              ),
            ),
          );
          MessageUtil.displaySuccessFullDialog(
            context,
            successIcon: CircleAvatar(
              radius: 70,
              backgroundColor: context.avatarBg,
              backgroundImage: AssetImage(JpgImages.avatar),
            ),
            title: l10n.authWelcomeAboardTitle,
            message: snapshot.message ?? '',
            btnText: l10n.authGetStarted,
            onOk: () {},
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
        maxWidth: 480,
        title: l10n.authSetSecurityPinTitle,
        titleStyle: context.display1,
        stepIndicator: StepProgress(
          currentStep: 4,
          totalSteps: 5,
          labels: l10n.signupSteps,
        ),
        subtitleWidget: Column(
          mainAxisSize: .min,
          children: [
            Text(
              l10n.authSetPinSubtitle,
              style: context.smallDetails,
            ),
          ],
        ),
        bottomNav: ValueListenableBuilder(
          valueListenable: _canSubmit,
          builder: (context, value, child) {
            return FormButton(
              enabled: value,
              onPressed: _onSave,
              text: l10n.commonSave,
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
              FormPinUnifiedInput(
                label: l10n.authEnterPin,
                length: 6,
                focusNode: _pinFocusNode,
                controller: _pinController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.validationPinRequired;
                  }
                  return null;
                },
                next: (_) {
                  _confirmPinFocusNode.requestFocus();
                },
                onChanged: _onChanged,
              ),
              const SizedBox(height: Spacing.lg),
              FormPinUnifiedInput(
                label: l10n.authConfirmPin,
                length: 6,
                focusNode: _confirmPinFocusNode,
                controller: _confirmPinController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.validationPinRequired;
                  }
                  if (value != _pinController.text) {
                    return l10n.validationPinMismatch;
                  }
                  return null;
                },
                onChanged: _onChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onChanged(_) {
    _canSubmit.value =
        _pinController.text.isNotEmpty && _confirmPinController.text.isNotEmpty;
  }

  void _onSave() {
    FocusScope.of(context).unfocus();

    mainEvent = context.dispatchProcess(
      CompleteSignUpAction(
        payload: CompleteSignUpActionPayload(
          password: SignUp.password,
          pin: _pinController.text.trim(),
          registrationId: SignUp.registrationId,
          secretAnswer: SignUp.secretAnswer,
          secretQuestion: SignUp.secretQuestion,
        ),
      ),
    );
  }
}
