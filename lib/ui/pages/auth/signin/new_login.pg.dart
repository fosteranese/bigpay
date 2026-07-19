import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/data/models/new_device_login_data.dart';
import 'package:bigpay/models/actions/login/login_action.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/button.dart';
import 'package:bigpay/ui/components/forms/input.dart';
import 'package:bigpay/ui/components/forms/password_input.dart';
import 'package:bigpay/ui/components/process_builder.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/pages/auth/forgot_pwd/start_forgot_pwd.pg.dart';
import 'package:bigpay/ui/pages/auth/signin/signin.dart';
import 'package:bigpay/ui/pages/auth/signup/signup.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/ui/theme/assets/app_images.dart';
import 'package:bigpay/utils/message.util.dart';

class NewLoginPage extends StatefulWidget {
  const NewLoginPage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/auth/new-login',
  );

  @override
  State<NewLoginPage> createState() => _NewLoginPageState();
}

class _NewLoginPageState extends State<NewLoginPage> with RouteAware {
  final _phoneNumberController = TextEditingController();
  final _phoneNumberFocusNode = FocusNode();
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();

  ExecuteProcessEvent? mainEvent;

  @override
  void initState() {
    _phoneNumberController.text = SignIn.phoneNumber;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      appRouteObserver.subscribe(this, route);
    }
  }

  /// Revealed again after a pushed route (e.g. the forgot-password flow) pops.
  /// initState already ran on the first build, so refresh the phone field from
  /// the latest [SignIn.phoneNumber] here.
  @override
  void didPopNext() {
    _phoneNumberController.text = SignIn.phoneNumber;
  }

  @override
  dispose() {
    appRouteObserver.unsubscribe(this);
    _phoneNumberController.dispose();
    _passwordController.dispose();

    _phoneNumberFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProcessListener<NewDeviceLoginData>(
      event: () => mainEvent,
      listener: (context, snapshot) {
        if (snapshot.isLoading) {
          MessageUtil.displayLoading(context);
          return;
        } else {
          MessageUtil.close(context);
        }

        if (snapshot.hasData) {
          SignIn.phoneNumber = _phoneNumberController.text.trim();
          SignIn.password = _passwordController.text.trim();
          SignIn.newDeviceLoginData = snapshot.data!;
          AppRouter.router.push(
            SecurePhraseLoginPage.route.path,
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
        title: 'Sign In',
        titleStyle: AppTypography.display1,
        subtitleWidget: Row(
          children: [
            Text(
              'Don’t have an account?',
              style: AppTypography.smallDetails,
            ),
            TextButton(
              style: TextButton.styleFrom(
                tapTargetSize: .shrinkWrap,
              ),
              onPressed: () {
                AppRouter.router.push(
                  StartSignUpPage.route.path,
                );
              },
              child: Text(
                'Sign up',
                style: AppTypography.buttons.copyWith(
                  color: AppColors.secondary,
                ),
              ),
            ),
          ],
        ),
        bottomNav: FormButton(
          onPressed: _onSave,
          text: 'Sign In',
        ),
        child: Form(
          child: Column(
            mainAxisSize: .min,
            mainAxisAlignment: .start,
            crossAxisAlignment: .center,
            children: [
              FormInput(
                label: 'Phone Number',
                keyboardType: .phone,
                focusNode: _phoneNumberFocusNode,
                controller: _phoneNumberController,
                next: (_) {
                  _passwordFocusNode.requestFocus();
                },
              ),

              SizedBox(height: 15),
              FormPasswordInput(
                label: 'Password',
                placeholder: 'Password',
                controller: _passwordController,
                focusNode: _passwordFocusNode,
              ),
              Row(
                mainAxisSize: .max,
                mainAxisAlignment: .spaceBetween,
                crossAxisAlignment: .start,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(padding: .zero),
                    onPressed: () {},
                    child: Row(
                      mainAxisSize: .min,
                      mainAxisAlignment: .start,
                      crossAxisAlignment: .center,
                      children: [
                        SvgPicture.asset(SvgImages.biometric),
                        SizedBox(width: 5),
                        Text(
                          'Biometric Login',
                          style: AppTypography.smallDetails.copyWith(
                            color: AppColors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(padding: .zero),
                    onPressed: () {
                      AppRouter.router.push(
                        StartForgotPasswordPage.route.path,
                      );
                    },
                    child: Text(
                      'Forgot Password ?',
                      style: AppTypography.smallDetails.copyWith(
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSave() {
    FocusScope.of(context).unfocus();

    mainEvent = context.dispatchProcess(
      NewLoginAction(
        payload: NewLoginActionPayload(
          phoneNumber: _phoneNumberController.text,
          password: _passwordController.text,
        ),
      ),
    );
  }
}
