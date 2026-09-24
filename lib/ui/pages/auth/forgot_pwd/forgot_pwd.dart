import 'package:bigpay/data/models/verify_user_data/verify_user_data.dart';

export 'otp_forgot_pwd.pg.dart';
export 'pwd_forgot_pwd.pg.dart';
export 'start_forgot_pwd.pg.dart';

class ForgotPwd {
  ForgotPwd._();

  static VerifyUserData? verifyUserData;
  static String phoneNumber = '';
  static String password = '';
  static String securePhrase = '';
  static String requestId = '';

  static void clear() {
    verifyUserData = null;
    phoneNumber = '';
    password = '';
    securePhrase = '';
    requestId = '';
  }
}
