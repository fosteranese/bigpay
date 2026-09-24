import 'package:flutter/material.dart';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/constants/status.const.dart';
import 'package:bigpay/data/models/auth_data/auth_data.dart';
import 'package:bigpay/data/models/new_device_login_data.dart';
import 'package:bigpay/models/actions/auth_action.dart';
import 'package:bigpay/models/actions/login/existing_login_action.dart';
import 'package:bigpay/models/actions/login/login_action.dart';
import 'package:bigpay/models/actions/login/verify_otp_login_action.dart';
import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/button.dart';
import 'package:bigpay/ui/components/forms/password_input.dart';
import 'package:bigpay/ui/components/forms/phone_input.dart';
import 'package:bigpay/ui/components/process_builder.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/pages/auth/forgot_pwd/forgot_pwd.dart';
import 'package:bigpay/ui/pages/auth/signin/signin.dart';
import 'package:bigpay/ui/pages/auth/signup/signup.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/utils/app_state.util.dart';
import 'package:bigpay/utils/phone.util.dart';
import 'package:bigpay/utils/biometric.util.dart';
import 'package:bigpay/utils/message.util.dart';
import 'package:bigpay/utils/validator.util.dart';

class NewLoginPage extends StatefulWidget {
  const NewLoginPage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/auth/new-login',
  );

  @override
  State<NewLoginPage> createState() => _NewLoginPageState();
}

class _NewLoginPageState extends State<NewLoginPage> with RouteAware {
  final _formKey = GlobalKey<FormState>();
  final _phone = PhoneNumberController();
  final _phoneNumberFocusNode = FocusNode();
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();

  ExecuteProcessEvent? newLoginEvent;
  ExecuteProcessEvent? existingLoginEvent;

  @override
  void initState() {
    _phone.text.text = SignIn.phoneNumber;
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
    _phone.text.text = SignIn.phoneNumber;
    ForgotPwd.clear();
  }

  @override
  dispose() {
    appRouteObserver.unsubscribe(this);
    _phone.dispose();
    _passwordController.dispose();

    _phoneNumberFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
              SignIn.phoneNumber = _phone.text.text.trim();
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
              // The password verified — keep it for biometric sign-in if the
              // user has that enabled.
              _rememberPasswordForBiometric(_passwordController.text);
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
        maxWidth: 480,
        title: l10n.authSignIn,
        titleStyle: context.display1,
        subtitleWidget: Column(
          mainAxisSize: .min,
          children: [
            Row(
              children: [
                Text(
                  l10n.authDontHaveAccount,
                  style: context.smallDetails,
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
                    l10n.authSignUpLink,
                    style: context.buttons.copyWith(
                      color: context.accentGreen,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        bottomNav: FormButton(
          onPressed: _onSave,
          text: l10n.authSignIn,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: .min,
            mainAxisAlignment: .start,
            crossAxisAlignment: .center,
            children: [
              PhoneNumberInput(
                label: l10n.commonPhoneNumberLabel,
                focusNode: _phoneNumberFocusNode,
                controller: _phone,
                validator: _phone.validator(
                  l10n.validationPhoneInvalid,
                ),
                next: (_) {
                  _passwordFocusNode.requestFocus();
                },
                onChanged: (value) {
                  SignIn.phoneNumber = value.trim();
                },
              ),

              SizedBox(height: Spacing.lg),
              FormPasswordInput(
                label: l10n.commonPasswordLabel,
                placeholder: l10n.commonPasswordPlaceholder,
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                validator: Validator.requiredField(
                  l10n.validationPasswordRequired,
                ),
              ),
              Row(
                mainAxisSize: .max,
                mainAxisAlignment: .end,
                crossAxisAlignment: .start,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(padding: .zero),
                    onPressed: () {
                      ForgotPwd.phoneNumber = SignIn.phoneNumber;
                      AppRouter.router.push(
                        StartForgotPasswordPage.route.path,
                      );
                    },
                    child: Text(
                      l10n.commonForgotPassword,
                      style: context.smallDetails.copyWith(
                        color: context.textPrimary,
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

  /// Stores the just-used password for biometric sign-in, but only when the
  /// user has enabled it on the security screen.
  Future<void> _rememberPasswordForBiometric(String password) async {
    if (password.isEmpty) return;
    if (await BiometricUtil.isLoginEnabled) {
      await BiometricUtil.saveLoginPassword(password);
    }
  }

  Future<void> _onSave() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    if (_phone.text.text.trim() ==
        AppState.currentUser?.user?.shortName?.toLocalPhone) {
      existingLoginEvent = context.dispatchProcess(
        ExistingLoginAction(
          payload: ExistingLoginActionPayload(
            phoneNumber: _phone.international,
            password: _passwordController.text,
          ),
        ),
      );
      return;
    }

    // A different user is signing in on this device — nothing of the
    // previous user's may carry over. Awaited, so the wipe can't race the new
    // session's own responses into the cache.
    await AppState.clearUserData();
    if (!mounted) return;
    newLoginEvent = context.dispatchProcess(
      NewLoginAction(
        payload: NewLoginActionPayload(
          phoneNumber: _phone.international,
          password: _passwordController.text,
        ),
      ),
    );
  }
}
