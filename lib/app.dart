import 'package:flutter/cupertino.dart' show CupertinoLocalizations;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/data/models/auth_data/auth_data.dart';
import 'package:bigpay/data/models/initialization_data/initialization_data.dart';
import 'package:bigpay/models/actions/action.dart';
import 'package:bigpay/models/actions/auth_action.dart';
import 'package:bigpay/models/actions/get_profile_picture_action.dart';
import 'package:bigpay/models/actions/login/verify_otp_login_action.dart';
import 'package:bigpay/models/actions/logout_action.dart';
import 'package:bigpay/models/actions/startup_action.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/connectivity_banner.dart';
import 'package:bigpay/ui/components/process_builder.dart';
import 'package:bigpay/ui/pages/app_error.pg.dart';
import 'package:bigpay/ui/pages/auth/signin/signin.dart';
import 'package:bigpay/ui/pages/dashboard.pg.dart';
import 'package:bigpay/ui/pages/kyc/verify_identity_prompt.dart';
import 'package:bigpay/ui/pages/walkthrough.pg.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/utils/app_state.util.dart';
import 'package:bigpay/utils/biometric.util.dart';

/// Flutter's built-in Material/Cupertino chrome translations (back-button
/// tooltip, etc.) don't cover Nigerian Pidgin ('pcm') —
/// `GlobalMaterialLocalizations.delegate.isSupported` returns false for it,
/// so `Localizations` never loads a `MaterialLocalizations` for that locale,
/// and any widget that force-unwraps `MaterialLocalizations.of(context)`
/// (e.g. `SliverAppBar`'s auto-generated back button) crashes with a null
/// check. The app's own [AppLocalizations] (from the ARB files) does support
/// 'pcm' — only the framework's own chrome strings need a fallback — so
/// these delegates claim support for 'pcm' and load English translations for
/// it, leaving every other locale exactly as the real delegate would.
class _PcmFallbackDelegate<T> extends LocalizationsDelegate<T> {
  const _PcmFallbackDelegate(this._delegate);

  final LocalizationsDelegate<T> _delegate;
  static const _fallback = Locale('en');

  @override
  bool isSupported(Locale locale) =>
      locale.languageCode == 'pcm' || _delegate.isSupported(locale);

  @override
  Future<T> load(Locale locale) =>
      _delegate.load(locale.languageCode == 'pcm' ? _fallback : locale);

  @override
  bool shouldReload(_PcmFallbackDelegate<T> old) => false;
}

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
                      await AppState.loadPhoneNumber();
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
                        target = enabled
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
                // Before SignIn.clear() wipes it — the only place this
                // number (as actually typed at login) is available to
                // persist for the existing-device unlock screen next time.
                AppState.savePhoneNumber(SignIn.phoneNumber);
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
            listener: (context, snapshot) async {
              if (snapshot.isSuccessful) {
                // The device is still known after logout — return to its
                // unlock screen (biometric if enabled, same as at launch),
                // not new-device sign-in.
                final biometric = await BiometricUtil.isLoginEnabled;
                AppRouter.router.go(
                  biometric
                      ? BiometricLoginPage.route.path
                      : ExistingDeviceLoginPage.route.path,
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
        // App-wide: any request that comes back 6000 (identity verification
        // required) prompts KYC, wherever it was made.
        child: VerifyIdentityGate(
          navigatorKey: rootNavigatorKey,
          child: ValueListenableBuilder<ThemeMode>(
            valueListenable: AppState.themeNotifier,
            builder: (context, themeMode, _) {
              return ValueListenableBuilder<Locale?>(
                valueListenable: AppState.localeNotifier,
                builder: (context, locale, _) {
                  return MaterialApp.router(
                    title: 'BigPay',
                    debugShowCheckedModeBanner: false,
                    theme: AppTheme.light,
                    darkTheme: AppTheme.dark,
                    themeMode: themeMode,
                    locale: locale,
                    supportedLocales: AppState.supportedLocales,
                    localizationsDelegates: [
                      AppLocalizations.delegate,
                      _PcmFallbackDelegate<MaterialLocalizations>(
                        GlobalMaterialLocalizations.delegate,
                      ),
                      _PcmFallbackDelegate<CupertinoLocalizations>(
                        GlobalCupertinoLocalizations.delegate,
                      ),
                      GlobalWidgetsLocalizations.delegate,
                    ],
                    routerConfig: AppRouter.router,
                    builder: (context, child) {
                      final scaler = MediaQuery.textScalerOf(context).clamp(
                        maxScaleFactor: 1.3,
                      );
                      return MediaQuery(
                        data: MediaQuery.of(
                          context,
                        ).copyWith(textScaler: scaler),
                        child: ConnectivityBanner(
                          child: child ?? SizedBox.shrink(),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
