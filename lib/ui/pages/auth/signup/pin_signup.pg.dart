import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/models/actions/signup/complete_signup_action.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/pages/auth/signup/signup.dart';
import 'package:bigpay/ui/pages/dashboard.pg.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/ui/theme/assets/app_images.dart';
import 'package:bigpay/utils/message.util.dart';
import 'package:flutter/material.dart';

import 'package:bigpay/ui/components/forms/button.dart';
import 'package:bigpay/ui/components/forms/pin_unified_input.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

class PinSignUpPage extends StatefulWidget {
  const PinSignUpPage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/auth/create-pin-signup',
  );

  @override
  State<PinSignUpPage> createState() => _PinSignUpPageState();
}

class _PinSignUpPageState extends State<PinSignUpPage> {
  final _id = Uuid().v4();
  ExecuteProcessEvent? mainEvent;

  final _pinFocusNode = FocusNode();
  final _confirmPinFocusNode = FocusNode();

  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();

  final _canSubmit = ValueNotifier(false);

  @override
  void dispose() {
    _pinFocusNode.dispose();
    _confirmPinFocusNode.dispose();
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
          MessageUtil.displaySuccessFullDialog(
            context,
            successIcon: CircleAvatar(
              radius: 70,
              backgroundColor: AppColors.tintShade3,
              backgroundImage: AssetImage(JpgImages.avatar),
            ),
            title: 'Welcome aboard!',
            message: state.result.message,
            btnText: 'Get Started',
            onOk: () {
              AppRouter.router.go(DashboardPage.route.path);
            },
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
        title: 'Set Security PIN',
        titleStyle: AppTypography.display1,
        subtitle:
            'Set a 6-digit code to authorize payments and keep your wallet secure.',
        bottomNav: ValueListenableBuilder(
          valueListenable: _canSubmit,
          builder: (context, value, child) {
            return FormButton(
              enabled: value,
              onPressed: _onSave,
              text: 'Save',
            );
          },
        ),
        child: Form(
          child: Column(
            mainAxisSize: .min,
            mainAxisAlignment: .start,
            crossAxisAlignment: .center,
            children: [
              FormPinUnifiedInput(
                label: 'Enter 6-digit PIN',
                length: 6,
                focusNode: _pinFocusNode,
                controller: _pinController,
                next: (_) {
                  _confirmPinFocusNode.requestFocus();
                },
                onChanged: _onChanged,
              ),
              const SizedBox(height: 15),
              FormPinUnifiedInput(
                label: 'Confirm PIN',
                length: 6,
                focusNode: _confirmPinFocusNode,
                controller: _confirmPinController,
                onChanged: _onChanged,
                // next: (_) => _onSave(),
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

    mainEvent = ExecuteProcessEvent(
      id: _id,
      action: CompleteSignUpAction(
        payload: CompleteSignUpActionPayload(
          password: SignUp.password,
          pin: _pinController.text.trim(),
          registrationId: SignUp.registrationId,
          secretAnswer: SignUp.secretAnswer,
          secretQuestion: SignUp.secretQuestion,
        ),
      ),
    );

    context.read<ProcessBloc>().add(mainEvent!);
  }
}
