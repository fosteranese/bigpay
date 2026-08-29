export 'otp_signup.pg.dart';
export 'password_signup.pg.dart';
export 'pin_signup.pg.dart';
export 'secure_phrase_signup.pg.dart';
export 'start_signup.pg.dart';

class SignUp {
  SignUp._();

  static String registrationId = '';
  static String secretQuestion = '';
  static String secretAnswer = '';
  static String password = '';
  static String pin = '';
}
