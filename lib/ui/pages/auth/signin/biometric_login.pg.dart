import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/data/models/auth_data/auth_data.dart';
import 'package:bigpay/models/actions/auth_action.dart';
import 'package:bigpay/models/actions/login/existing_login_action.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/button.dart';
import 'package:bigpay/ui/components/process_builder.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/pages/auth/signin/existing_login.pg.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/ui/theme/assets/app_images.dart';
import 'package:bigpay/utils/app_state.util.dart';
import 'package:bigpay/utils/phone.util.dart';
import 'package:bigpay/utils/biometric.util.dart';
import 'package:bigpay/utils/message.util.dart';

/// The returning-user unlock screen. A successful device biometric replays the
/// stored login password through [ExistingLoginAction] → [AuthAction], the same
/// chain a manual sign-in runs.
class BiometricLoginPage extends StatefulWidget {
  const BiometricLoginPage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/auth/biometric-login',
  );

  @override
  State<BiometricLoginPage> createState() => _BiometricLoginPageState();
}

class _BiometricLoginPageState extends State<BiometricLoginPage> {
  ExecuteProcessEvent? _loginEvent;

  // @override
  // void initState() {
  //   super.initState();
  //   // Prompt for biometrics as soon as the screen settles. Auto-triggered —
  //   // stays on this page rather than bouncing to the password screen when
  //   // there's nothing to replay yet, so the user actually sees it land here.
  //   WidgetsBinding.instance.addPostFrameCallback((_) => _unlock(auto: true));
  // }

  Future<void> _unlock({bool auto = false}) async {
    final password = await BiometricUtil.readLoginPassword();
    if (!mounted) return;

    // Nothing stored to replay. A manual tap explains why and lets the user
    // opt into the password screen; the auto-trigger on launch just stays put
    // instead of bouncing the user away before they see this page.
    if (password == null || password.isEmpty) {
      if (!auto) {
        MessageUtil.displayActionDialog(
          context,
          title: 'Password Required',
          message:
              'Login with your password first to enjoy login with biometrics.',
          onConfirmText: 'Login',
          onConfirm: _usePassword,
        );
      }
      return;
    }

    final result = await BiometricUtil.authenticate('Unlock BigPay');
    if (!mounted || result != BiometricResult.success) return;

    final phone = AppState.currentUser?.user?.shortName?.toLocalPhone ?? '';

    setState(() {
      _loginEvent = context.dispatchProcess(
        ExistingLoginAction(
          payload: ExistingLoginActionPayload(
            phoneNumber: phone,
            password: password,
          ),
        ),
      );
    });
  }

  void _usePassword() {
    // A device with biometrics set up is an existing device — fall back to the
    // existing-device password screen, not new-device sign-in.
    AppRouter.router.go(ExistingDeviceLoginPage.route.path);
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
          // Auth succeeds globally in app.dart's AuthAction listener, which
          // routes on to the dashboard.
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
          MessageUtil.displayErrorDialog(
            context,
            message: snapshot.error!.message,
          );
          return;
        }
      },
      child: MainLayout(
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
            FormButton(
              onPressed: _unlock,
              text: 'Unlock with Biometrics',
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: _usePassword,
              child: Text(
                'Login with Password',
                style: AppTypography.buttons.copyWith(
                  fontSize: 14,
                  color: context.textPrimary,
                  decoration: .underline,
                ),
              ),
            ),
          ],
        ),
        child: Center(
          child: IconButton(
            tooltip: 'Unlock with biometrics',
            onPressed: _unlock,
            icon: SvgPicture.asset(
              SvgImages.biometric,
              width: 104,
            ),
          ),
        ),
      ),
    );
  }
}
