import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/constants/status.const.dart';
import 'package:bigpay/data/models/auth_data/auth_data.dart';
import 'package:bigpay/models/actions/auth_action.dart';
import 'package:bigpay/models/actions/login/existing_login_action.dart';
import 'package:bigpay/models/actions/login/verify_otp_login_action.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/button.dart';
import 'package:bigpay/ui/components/forms/password_input.dart';
import 'package:bigpay/ui/components/process_builder.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/pages/auth/forgot_pwd/forgot_pwd.dart';
import 'package:bigpay/ui/pages/auth/signin/signin.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/ui/theme/assets/app_images.dart';
import 'package:bigpay/utils/app_state.util.dart';
import 'package:bigpay/utils/phone.util.dart';
import 'package:bigpay/utils/biometric.util.dart';
import 'package:bigpay/utils/notification_store.util.dart';
import 'package:bigpay/utils/message.util.dart';

/// The returning-user unlock screen for a device that already has a saved
/// login. It greets the user by name (and avatar) and only asks for the
/// password (or biometrics) — no phone number. If the backend says the device
/// is no longer recognised (`newLogin`), it hands off to new-device sign-in.
class ExistingDeviceLoginPage extends StatefulWidget {
  const ExistingDeviceLoginPage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/auth/existing-login',
    name: 'existing-login',
  );

  @override
  State<ExistingDeviceLoginPage> createState() =>
      _ExistingDeviceLoginPageState();
}

class _ExistingDeviceLoginPageState extends State<ExistingDeviceLoginPage> {
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();

  ExecuteProcessEvent? _loginEvent;
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadBiometric();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadBiometric() async {
    final enabled = await BiometricUtil.isLoginEnabled;
    if (!mounted) return;
    setState(() => _biometricEnabled = enabled);
  }

  String get _name => AppState.currentUser?.user?.name ?? '';

  String get _phone =>
      AppState.currentUser?.user?.shortName?.toLocalPhone ?? '';

  String get _initials {
    final parts = _name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '?';
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  /// The saved base64 avatar, decoded, or null when it's absent/invalid.
  ImageProvider? get _avatar {
    final raw = AppState.currentUser?.profilePicture ?? '';
    if (raw.isEmpty) return null;
    try {
      return MemoryImage(base64Decode(raw));
    } catch (_) {
      return null;
    }
  }

  /// Keeps the just-used password for biometric sign-in when it's enabled.
  Future<void> _rememberPasswordForBiometric(String password) async {
    if (password.isEmpty) return;
    if (await BiometricUtil.isLoginEnabled) {
      await BiometricUtil.saveLoginPassword(password);
    }
  }

  void _signIn() {
    FocusScope.of(context).unfocus();
    if (_passwordController.text.trim().isEmpty) {
      MessageUtil.displayErrorDialog(context, message: 'Password is required');
      return;
    }

    _loginEvent = context.dispatchProcess(
      ExistingLoginAction(
        payload: ExistingLoginActionPayload(
          phoneNumber: _phone,
          password: _passwordController.text,
        ),
      ),
    );
  }

  void _useDifferentAccount() {
    // Switching accounts — drop the previous user's saved biometric secrets
    // and their notifications.
    AppState.currentUser = null;
    SignIn.clear();
    BiometricUtil.clear();
    NotificationStore.clear();
    AppRouter.router.go(NewLoginPage.route.path);
  }

  @override
  Widget build(BuildContext context) {
    return ProcessListener<AuthData>(
      event: () => _loginEvent,
      listener: (context, snapshot) {
        if (snapshot.isLoading) {
          MessageUtil.displayLoading(context);
          return;
        } else {
          MessageUtil.close(context);
        }

        if (snapshot.hasData) {
          _rememberPasswordForBiometric(_passwordController.text);
          AuthAction.event = context.dispatchProcess(
            AuthAction(
              payload: AuthActionPayload(dataResponse: snapshot.response!),
            ),
          );
          return;
        }

        if (snapshot.hasError) {
          // The device is no longer recognised — restart on the new-device
          // sign-in.
          if (snapshot.error?.code == StatusCodeConstants.newLogin) {
            AppState.store.cache.remove(VerifyOtpLoginAction.path);
            AppState.currentUser = null;
            SignIn.clear();
            BiometricUtil.clear();
            NotificationStore.clear();
            MessageUtil.displayErrorDialog(
              context,
              message: snapshot.error!.message,
              onOkPressed: () => AppRouter.router.go(NewLoginPage.route.path),
            );
            return;
          }

          MessageUtil.displayErrorDialog(
            context,
            message: snapshot.error!.message,
          );
        }
      },
      child: MainLayout(
        showBackBtn: false,
        bottomSize: 120,
        bottomNav: Column(
          mainAxisSize: .min,
          children: [
            FormButton(onPressed: _signIn, text: 'Sign In'),
            const SizedBox(height: 6),
            TextButton(
              onPressed: _useDifferentAccount,
              child: Text(
                'Not you? Use a different account',
                style: AppTypography.smallDetails.copyWith(
                  color: AppColors.secondary,
                ),
              ),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            const SizedBox(height: 20),
            Center(child: _buildAvatar()),
            const SizedBox(height: 16),
            Text(
              'Welcome back',
              textAlign: .center,
              style: context.smallDetails,
            ),
            const SizedBox(height: 2),
            Text(
              _name.isEmpty ? 'Sign in to continue' : _name,
              textAlign: .center,
              style: context.header2,
            ),
            const SizedBox(height: 36),
            FormPasswordInput(
              label: 'Password',
              placeholder: 'Enter your password',
              controller: _passwordController,
              focusNode: _passwordFocusNode,
            ),
            Row(
              mainAxisAlignment: .spaceBetween,
              crossAxisAlignment: .center,
              children: [
                if (_biometricEnabled)
                  TextButton(
                    style: TextButton.styleFrom(padding: .zero),
                    onPressed: () {
                      AppRouter.router.push(
                        BiometricLoginPage.route.path,
                      );
                    },
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
                            color: context.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  const SizedBox.shrink(),
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
                      color: context.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final image = _avatar;
    return CircleAvatar(
      radius: 46,
      backgroundColor: context.avatarBg,
      backgroundImage: image,
      child: image == null ? Text(_initials, style: context.header1) : null,
    );
  }
}
