import 'package:bigpay/ui/pages/auth/forgot_pwd/done_forgot_pwd.pg.dart';
import 'package:bigpay/ui/pages/auth/forgot_pwd/otp_forgot_pwd.pg.dart';
import 'package:bigpay/ui/pages/auth/forgot_pwd/pwd_forgot_pwd.pg.dart';
import 'package:bigpay/ui/pages/auth/forgot_pwd/start_forgot_pwd.pg.dart';
import 'package:bigpay/ui/pages/auth/forgot_secure_phrase/done_forgot_secure_phrase.pg.dart';
import 'package:bigpay/ui/pages/auth/forgot_secure_phrase/start_forgot_secure_phrase.pg.dart';
import 'package:bigpay/ui/pages/auth/signin/biometric_login.pg.dart';
import 'package:bigpay/ui/pages/auth/signin/new_login.pg.dart';
import 'package:bigpay/ui/pages/auth/signup/done_signup.pg.dart';
import 'package:bigpay/ui/pages/auth/signup/otp_signup.pg.dart';
import 'package:bigpay/ui/pages/auth/signup/password_signup.pg.dart';
import 'package:bigpay/ui/pages/auth/signup/pin_signup.pg.dart';
import 'package:bigpay/ui/pages/auth/signup/secure_phrase_signup.pg.dart';
import 'package:bigpay/ui/pages/auth/signup/start_signup.pg.dart';
import 'package:go_router/go_router.dart';

GoRoute get authRoute => GoRoute(
      path: '/auth',
      redirect: (context, state) => null,
      routes: [
        GoRoute(
          path: 'new-login',
          builder: (context, state) => const NewLoginPage(),
        ),
        GoRoute(
          path: 'biometric-login',
          builder: (context, state) => const BiometricLoginPage(),
        ),
        GoRoute(
          path: 'start-signup',
          builder: (context, state) => const StartSignUpPage(),
        ),
        GoRoute(
          path: 'otp-signup',
          builder: (context, state) => const OtpSignUpPage(),
        ),
        GoRoute(
          path: 'create-password-signup',
          builder: (context, state) => const CreatePasswordSignUpPage(),
        ),
        GoRoute(
          path: 'create-secure-phrase-signup',
          builder: (context, state) => const CreateSecurePhrasePage(),
        ),
        GoRoute(
          path: 'create-pin-signup',
          builder: (context, state) => const PinSignUpPage(),
        ),
        GoRoute(
          path: 'done-signup',
          builder: (context, state) => const DoneSignUpPage(),
        ),
        GoRoute(
          path: 'start-forgot-phoneNumber',
          builder: (context, state) => const StartForgotPasswordPage(),
        ),
        GoRoute(
          path: 'otp-forgot-pwd',
          builder: (context, state) => const OtpForgotPasswordPage(),
        ),
        GoRoute(
          path: 'create-pwd-forgot-pwd',
          builder: (context, state) => const CreatePwdForgotPwdPage(),
        ),
        GoRoute(
          path: 'done-forgot-pwd',
          builder: (context, state) => const DoneForgotPwdPage(),
        ),
        GoRoute(
          path: 'start-forgot-secure-phrase',
          builder: (context, state) => const StartForgotSecurePhrasePage(),
        ),
        GoRoute(
          path: 'done-forgot-secure-phrase',
          builder: (context, state) => const DoneForgotSecurePhrasePage(),
        ),
      ],
    );
