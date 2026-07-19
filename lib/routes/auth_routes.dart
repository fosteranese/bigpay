import 'package:go_router/go_router.dart';

import 'package:bigpay/data/models/verify_user_data/verify_user_data.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/pages/auth/forgot_pwd/forgot_pwd.dart';
import 'package:bigpay/ui/pages/auth/forgot_secure_phrase/forgot_secure_phrase.dart';
import 'package:bigpay/ui/pages/auth/signin/otp_login.pg.dart';
import 'package:bigpay/ui/pages/auth/signin/signin.dart';
import 'package:bigpay/ui/pages/auth/signup/signup.dart';

GoRoute get authRoute => GoRoute(
  name: 'auth',
  path: '/auth',
  redirect: (context, state) => null,
  routes: [
    NewLoginPage.route.toGoRoute(() => const NewLoginPage(), nested: true),
    SecurePhraseLoginPage.route.toGoRoute(
      () => const SecurePhraseLoginPage(),
      nested: true,
    ),
    OtpLoginPage.route.toGoRoute(
      () => const OtpLoginPage(),
      nested: true,
    ),

    BiometricLoginPage.route.toGoRoute(
      () => const BiometricLoginPage(),
      nested: true,
    ),
    StartSignUpPage.route.toGoRoute(
      () => const StartSignUpPage(),
      nested: true,
    ),
    OtpSignUpPage.route.toGoRouteWithState(
      (state) {
        return OtpSignUpPage(
          data: state.extra as VerifyUserData,
        );
      },
      nested: true,
    ),
    CreatePasswordSignUpPage.route.toGoRoute(
      () => const CreatePasswordSignUpPage(),
      nested: true,
      onExit: (context, state) {
        Future.delayed(Duration(seconds: 1), () {
          AppRouter.router.pop();
        });
        return true;
      },
    ),
    CreateSecurePhrasePage.route.toGoRoute(
      () => const CreateSecurePhrasePage(),
      nested: true,
    ),
    PinSignUpPage.route.toGoRoute(() => const PinSignUpPage(), nested: true),
    StartForgotPasswordPage.route.toGoRoute(
      () => const StartForgotPasswordPage(),
      nested: true,
    ),
    OtpForgotPasswordPage.route.toGoRoute(
      () => const OtpForgotPasswordPage(),
      nested: true,
    ),
    CreatePwdForgotPwdPage.route.toGoRoute(
      () => const CreatePwdForgotPwdPage(),
      nested: true,
    ),
    StartForgotSecurePhrasePage.route.toGoRoute(
      () => const StartForgotSecurePhrasePage(),
      nested: true,
    ),
    DoneForgotSecurePhrasePage.route.toGoRoute(
      () => const DoneForgotSecurePhrasePage(),
      nested: true,
    ),
  ],
);
