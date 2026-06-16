import 'package:go_router/go_router.dart';

import 'package:bigpay/ui/pages/auth/signin/biometric_login.pg.dart';
import 'package:bigpay/ui/pages/auth/signin/new_login.pg.dart';
import 'package:bigpay/ui/pages/auth/signup/done_signup.pg.dart';
import 'package:bigpay/ui/pages/auth/signup/otp_signup.pg.dart';
import 'package:bigpay/ui/pages/auth/signup/password_signup.pg.dart';
import 'package:bigpay/ui/pages/auth/signup/pin_signup.pg.dart';
import 'package:bigpay/ui/pages/auth/signup/secure_phrase_signup.pg.dart';
import 'package:bigpay/ui/pages/auth/signup/start_signup.pg.dart';
import 'package:bigpay/ui/pages/splash_screen.pg.dart';
import 'package:bigpay/ui/pages/walkthrough.pg.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: DoneSignUpPage.routeName,
    routes: [
      GoRoute(
        path: SplashScreenPage.routeName,
        builder: (context, state) => const SplashScreenPage(),
      ),
      GoRoute(
        path: WalkthroughPage.routeName,
        builder: (context, state) => const WalkthroughPage(),
      ),
      GoRoute(
        path: NewLoginPage.routeName,
        builder: (context, state) => const NewLoginPage(),
      ),
      GoRoute(
        path: BiometricLoginPage.routeName,
        builder: (context, state) => const BiometricLoginPage(),
      ),
      GoRoute(
        path: StartSignUpPage.routeName,
        builder: (context, state) => const StartSignUpPage(),
      ),
      GoRoute(
        path: OtpSignUpPage.routeName,
        builder: (context, state) => const OtpSignUpPage(),
      ),
      GoRoute(
        path: CreatePasswordSignUpPage.routeName,
        builder: (context, state) => const CreatePasswordSignUpPage(),
      ),
      GoRoute(
        path: CreateSecurePhrasePage.routeName,
        builder: (context, state) => const CreateSecurePhrasePage(),
      ),
      GoRoute(
        path: PinSignUpPage.routeName,
        builder: (context, state) => const PinSignUpPage(),
      ),
      GoRoute(
        path: DoneSignUpPage.routeName,
        builder: (context, state) => const DoneSignUpPage(),
      ),
    ],
  );
}
