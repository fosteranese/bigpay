import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/pages/auth/forgot_pwd/forgot_pwd.dart';
import 'package:bigpay/ui/pages/auth/forgot_secure_phrase/forgot_secure_phrase.dart';
import 'package:bigpay/ui/pages/auth/signin/signin.dart';
import 'package:bigpay/ui/pages/auth/signup/signup.dart';
import 'package:go_router/go_router.dart';

GoRoute get authRoute => GoRoute(
  name: 'auth',
  path: '/auth',
  redirect: (context, state) => null,
  routes: [
    NewLoginPage.route.toGoRoute(() => const NewLoginPage(), nested: true),
    BiometricLoginPage.route.toGoRoute(
      () => const BiometricLoginPage(),
      nested: true,
    ),
    StartSignUpPage.route.toGoRoute(
      () => const StartSignUpPage(),
      nested: true,
    ),
    OtpSignUpPage.route.toGoRoute(() => const OtpSignUpPage(), nested: true),
    CreatePasswordSignUpPage.route.toGoRoute(
      () => const CreatePasswordSignUpPage(),
      nested: true,
    ),
    CreateSecurePhrasePage.route.toGoRoute(
      () => const CreateSecurePhrasePage(),
      nested: true,
    ),
    PinSignUpPage.route.toGoRoute(() => const PinSignUpPage(), nested: true),
    DoneSignUpPage.route.toGoRoute(() => const DoneSignUpPage(), nested: true),
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
    DoneForgotPwdPage.route.toGoRoute(
      () => const DoneForgotPwdPage(),
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
