import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/data/models/start_sign_up_data/start_sign_up_data.dart';
import 'package:bigpay/models/actions/signup/start_signup_action.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/button.dart';
import 'package:bigpay/ui/components/forms/input.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/pages/auth/signin/signin.dart';
import 'package:bigpay/ui/pages/auth/signup/signup.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/utils/message.util.dart';

class StartSignUpPage extends StatefulWidget {
  const StartSignUpPage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/auth/start-signup',
  );

  @override
  State<StartSignUpPage> createState() => _StartSignUpPageState();
}

class _StartSignUpPageState extends State<StartSignUpPage> {
  final _phoneNumberFocusNode = FocusNode();
  final _phoneNumberController = TextEditingController();
  ExecuteProcessEvent? mainEvent;

  late final _id = Uuid().v4();

  @override
  dispose() {
    _phoneNumberFocusNode.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Sign Up',
      titleStyle: AppTypography.display1,
      subtitleWidget: Row(
        children: [
          Text(
            'Already have an account?',
            style: AppTypography.smallDetails,
          ),
          TextButton(
            style: TextButton.styleFrom(
              tapTargetSize: .shrinkWrap,
            ),
            onPressed: () {
              AppRouter.router.push(
                NewLoginPage.route.path,
              );
            },
            child: Text(
              'Sign in',
              style: AppTypography.buttons.copyWith(
                color: AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
      bottomNav: BlocListener<ProcessBloc, ProcessState>(
        listenWhen: (previous, current) => current.event == mainEvent,
        listener: (context, state) {
          if (state is ExecutingProcess) {
            MessageUtil.displayLoading(context);
            return;
          } else {
            MessageUtil.close(context);
          }

          if (state is ProcessExecuted) {
            AppRouter.router.push(
              OtpSignUpPage.route.path,
              extra: state.result.data as StartSignUpData,
            );
          }

          if (state is ExecuteProcessError) {
            MessageUtil.displayErrorDialog(
              context,
              message: state.error.message,
            );
            return;
          }
        },
        child: Column(
          mainAxisSize: .min,
          mainAxisAlignment: .end,
          crossAxisAlignment: .center,
          children: [
            Wrap(
              alignment: .center,
              direction: .horizontal,
              runAlignment: .start,
              children: [
                Text(
                  'By clicking on continue, you accept our ',
                  style: AppTypography.smallDetails,
                ),
                InkWell(
                  onTap: () {},
                  child: Text(
                    'Terms of Use',
                    style: AppTypography.smallDetailsMedium.copyWith(
                      decoration: .underline,
                    ),
                  ),
                ),
                Text(
                  ' and ',
                  style: AppTypography.smallDetails,
                ),
                InkWell(
                  onTap: () {},
                  child: Text(
                    'Privacy Policy',
                    style: AppTypography.smallDetailsMedium.copyWith(
                      decoration: .underline,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            FormButton(
              onPressed: _continue,
              text: 'Continue',
            ),
          ],
        ),
      ),
      child: Form(
        child: Column(
          children: [
            FormInput(
              label: 'Phone Number',
              keyboardType: .phone,
              focusNode: _phoneNumberFocusNode,
              controller: _phoneNumberController,
              next: (_) {
                _continue();
              },
              textInputAction: .done,
            ),
          ],
        ),
      ),
    );
  }

  void _continue() {
    FocusScope.of(context).unfocus();

    final phone = _phoneNumberController.text.trim();
    if (phone.isEmpty) return;

    mainEvent = ExecuteProcessEvent(
      id: _id,
      action: StartSignUpAction(
        payload: StartSignUpActionPayload(
          phoneNumber: phone,
        ),
      ),
    );

    context.read<ProcessBloc>().add(mainEvent!);
  }
}
