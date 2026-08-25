import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/constants/status.const.dart';
import 'package:bigpay/data/models/auth_data/auth_data.dart';
import 'package:bigpay/models/actions/auth_action.dart';
import 'package:bigpay/models/actions/login/existing_login_action.dart';
import 'package:bigpay/models/actions/login/verify_otp_login_action.dart';
import 'package:bigpay/l10n/app_localizations.dart';
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
    await BiometricUtil.saveLoginPassword(password);
  }

  /// Runs the biometric unlock right here instead of navigating to a separate
  /// page — this page already has the password field, avatar, and login
  /// listener it needs.
  Future<void> _biometricUnlock() async {
    final password = await BiometricUtil.readLoginPassword();
    if (!mounted) return;

    // Nothing stored to replay yet — point the user at the password field
    // already on this page rather than sending them anywhere.
    if (password == null || password.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      MessageUtil.displayActionDialog(
        context,
        title: l10n.authPasswordRequiredTitle,
        message: l10n.authPasswordRequiredMessage,
        onConfirmText: l10n.commonOk,
        onConfirm: () => _passwordFocusNode.requestFocus(),
      );
      return;
    }

    final result = await BiometricUtil.authenticate(AppLocalizations.of(context)!.securityUnlockBigPay);
    if (!mounted || result != BiometricResult.success) return;

    _loginEvent = context.dispatchProcess(
      ExistingLoginAction(
        payload: ExistingLoginActionPayload(
          phoneNumber: _phone,
          password: password,
        ),
      ),
    );
  }

  void _signIn() {
    FocusScope.of(context).unfocus();
    if (_passwordController.text.trim().isEmpty) {
      MessageUtil.displayErrorDialog(
        context,
        message: AppLocalizations.of(context)!.authPasswordRequiredError,
      );
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
    final l10n = AppLocalizations.of(context)!;
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
        maxWidth: 480,
        showBackBtn: false,
        bottomSize: 60,
        subtitleWidget: Align(
          alignment: .center,
          child: SvgPicture.asset(
            SvgImages.icon,
            height: 50,
          ),
        ),
        bottomNav: Column(
          mainAxisSize: .min,
          children: [
            FormButton(onPressed: _signIn, text: l10n.authSignIn),
            const SizedBox(height: 6),
            TextButton(
              onPressed: _useDifferentAccount,
              child: Text(
                l10n.authUseDifferentAccount,
                style: context.smallDetails.copyWith(
                  color: context.accentGreen,
                ),
              ),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            const SizedBox(height: 120),
            Center(child: _buildAvatar()),
            const SizedBox(height: Spacing.lg),
            Text(
              l10n.authWelcomeBack,
              textAlign: .center,
              style: context.smallDetails,
            ),
            const SizedBox(height: 2),
            Text(
              _name.isEmpty ? l10n.authSignInToContinue : _name,
              textAlign: .center,
              style: context.header2,
            ),
            const SizedBox(height: 36),
            FormPasswordInput(
              label: l10n.commonPasswordLabel,
              placeholder: l10n.authEnterPasswordPlaceholder,
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
                    onPressed: _biometricUnlock,
                    child: Row(
                      mainAxisSize: .min,
                      mainAxisAlignment: .start,
                      crossAxisAlignment: .center,
                      children: [
                        SvgPicture.asset(SvgImages.biometric),
                        SizedBox(width: 5),
                        Text(
                          l10n.commonBiometricLogin,
                          style: context.smallDetails.copyWith(
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
