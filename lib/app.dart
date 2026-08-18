import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/data/models/auth_data/auth_data.dart';
import 'package:bigpay/data/models/initialization_data/initialization_data.dart';
import 'package:bigpay/models/actions/action.dart';
import 'package:bigpay/models/actions/auth_action.dart';
import 'package:bigpay/models/actions/get_profile_picture_action.dart';
import 'package:bigpay/models/actions/login/verify_otp_login_action.dart';
import 'package:bigpay/models/actions/logout_action.dart';
import 'package:bigpay/models/actions/startup_action.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/process_builder.dart';
import 'package:bigpay/ui/pages/app_error.pg.dart';
import 'package:bigpay/ui/pages/auth/signin/signin.dart';
import 'package:bigpay/ui/pages/dashboard.pg.dart';
import 'package:bigpay/ui/pages/walkthrough.pg.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/utils/app_state.util.dart';
import 'package:bigpay/utils/biometric.util.dart';

class BigPayApp extends StatelessWidget {
  const BigPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          lazy: false,
          create: (_) => ProcessBloc(
            store: AppState.store,
          )..add(startUpEvent),
        ),
      ],
      child: MultiProcessListener(
        listeners: [
          ProcessListenerConfig<InitializationData>(
            event: () => startUpEvent,
            listener: (context, snapshot) {
              if (snapshot.hasData) {
                AppState.data = snapshot.data!;
                if (snapshot.isSilent) return;

                AppState.store.cache
                    .latestForEndpoint<AuthData>(
                      VerifyOtpLoginAction.path,
                      AuthData.fromMap,
                    )
                    .then((result) async {
                      final savedUser = result?.data;
                      if (savedUser != null) {
                        AppState.currentUser = savedUser;
                      }
                      SignIn.clear();

                      // A returning user (a saved login surfaced on the cached
                      // startup emission) gets the quick re-login screen —
                      // biometric unlock when it's set up, otherwise the
                      // password screen. Everyone else — including a first
                      // launch with no saved login — goes through onboarding.
                      // Without navigating in the no-saved-user case, the app
                      // stayed on the splash.
                      var target = WalkthroughPage.route.path;
                      if (savedUser != null && snapshot.isCached) {
                        final enabled = await BiometricUtil.isLoginEnabled;
                        final password =
                            await BiometricUtil.readLoginPassword();
                        final biometricReady =
                            enabled && (password?.isNotEmpty ?? false);
                        target = biometricReady
                            ? BiometricLoginPage.route.path
                            : ExistingDeviceLoginPage.route.path;
                      }

                      AppRouter.router.go(target, extra: snapshot.data);
                    });
              } else if (snapshot.hasError &&
                  !snapshot.isSilent &&
                  !snapshot.isCached) {
                AppRouter.router.go(
                  AppErrorPage.route.path,
                  extra: snapshot.error,
                );
              }
            },
          ),
          ProcessListenerConfig<AuthData>(
            event: () => AuthAction.event,
            listener: (context, snapshot) {
              if (snapshot.hasData) {
                AppState.currentUser = snapshot.data!;
                SignIn.clear();
                AppRouter.router.go(
                  DashboardPage.route.path,
                );
                GetProfilePictureAction.event = context.dispatchProcess(
                  returnSavedResponse: true,
                  saveActionResponse: true,
                  GetProfilePictureAction(
                    payload: NoPayload(),
                  ),
                );
              } else if (snapshot.hasError &&
                  !snapshot.isSilent &&
                  !snapshot.isCached) {
                AppRouter.router.go(
                  AppErrorPage.route.path,
                  extra: snapshot.error,
                );
              }
            },
          ),
          ProcessListenerConfig<Null>(
            event: () => LogoutAction.event,
            listener: (context, snapshot) {
              if (snapshot.isSuccessful) {
                // The device is still known after logout — return to the
                // existing-device unlock screen, not new-device sign-in.
                AppRouter.router.go(
                  ExistingDeviceLoginPage.route.path,
                );
              }
            },
          ),
          ProcessListenerConfig<String>(
            event: () => GetProfilePictureAction.event,
            listener: (context, snapshot) {
              if (snapshot.hasData) {
                AppState.currentUser = AppState.currentUser!.copyWith(
                  profilePicture: snapshot.data ?? '',
                );
              }
            },
          ),
        ],
        child: ValueListenableBuilder<ThemeMode>(
          valueListenable: AppState.themeNotifier,
          builder: (context, themeMode, _) {
            return MaterialApp.router(
              title: 'BigPay',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: themeMode,
              routerConfig: AppRouter.router,
            );
          },
        ),
      ),
    );
  }
}
