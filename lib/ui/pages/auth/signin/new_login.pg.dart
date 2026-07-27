import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/constants/status.const.dart';
import 'package:bigpay/data/models/auth_data/auth_data.dart';
import 'package:bigpay/data/models/new_device_login_data.dart';
import 'package:bigpay/models/actions/auth_action.dart';
import 'package:bigpay/models/actions/login/existing_login_action.dart';
import 'package:bigpay/models/actions/login/login_action.dart';
import 'package:bigpay/models/actions/login/verify_otp_login_action.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/button.dart';
import 'package:bigpay/ui/components/forms/input.dart';
import 'package:bigpay/ui/components/forms/password_input.dart';
import 'package:bigpay/ui/components/process_builder.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/pages/auth/forgot_pwd/forgot_pwd.dart';
import 'package:bigpay/ui/pages/auth/signin/signin.dart';
import 'package:bigpay/ui/pages/auth/signup/signup.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/ui/theme/assets/app_images.dart';
import 'package:bigpay/utils/app_state.util.dart';
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

  ExecuteProcessEvent? newLoginEvent;
  ExecuteProcessEvent? existingLoginEvent;

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
    ForgotPwd.clear();
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
    return MultiProcessListener(
      listeners: [
        ProcessListenerConfig<NewDeviceLoginData>(
          event: () => newLoginEvent,
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
        ),
        ProcessListenerConfig<AuthData>(
          event: () => existingLoginEvent,
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
              return;
            }

            if (snapshot.hasError) {
              if (snapshot.error?.code == StatusCodeConstants.newLogin) {
                AppState.store.cache.remove(VerifyOtpLoginAction.path);
                AppState.currentUser = null;
                _passwordController.text = '';
                SignIn.clear();
              }

              MessageUtil.displayErrorDialog(
                context,
                message: snapshot.error!.message,
              );
              return;
            }
          },
        ),
      ],
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
              if (SignIn.phoneNumber.isNotEmpty)
                Row(
                  mainAxisSize: .min,
                  mainAxisAlignment: .spaceBetween,
                  crossAxisAlignment: .center,
                  children: [
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Welcome back, ',
                            ),
                            TextSpan(
                              text: AppState.currentUser?.user?.name ?? '',
                              style: AppTypography.p1Bold,
                            ),
                            TextSpan(
                              text: '. \nEnter your password to continue.',
                            ),
                          ],
                          style: AppTypography.p1.copyWith(
                            // color: AppColors.black,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 90,
                      child: FormButton(
                        height: 40,
                        onPressed: () {
                          setState(() {
                            SignIn.phoneNumber = '';
                          });
                        },
                        text: 'Change',
                      ),
                    ),
                  ],
                )
              else
                FormInput(
                  label: 'Phone Number',
                  keyboardType: .phone,
                  focusNode: _phoneNumberFocusNode,
                  controller: _phoneNumberController,
                  next: (_) {
                    _passwordFocusNode.requestFocus();
                  },
                  onChanged: (value) {
                    SignIn.phoneNumber = value.trim();
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
                      ForgotPwd.phoneNumber = SignIn.phoneNumber;
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

    if (_phoneNumberController.text.trim() ==
        AppState.currentUser?.user?.shortName?.replaceAll('233', '0')) {
      existingLoginEvent = context.dispatchProcess(
        ExistingLoginAction(
          payload: ExistingLoginActionPayload(
            phoneNumber: _phoneNumberController.text,
            password: _passwordController.text,
          ),
        ),
      );
      return;
    }

    newLoginEvent = context.dispatchProcess(
      NewLoginAction(
        payload: NewLoginActionPayload(
          phoneNumber: _phoneNumberController.text,
          password: _passwordController.text,
        ),
      ),
    );
  }
}
