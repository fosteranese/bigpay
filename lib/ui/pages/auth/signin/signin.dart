import 'package:bigpay/data/models/new_device_login_data.dart';
import 'package:bigpay/data/models/verify_user_data/verify_user_data.dart';

export 'biometric_login.pg.dart';
export 'new_login.pg.dart';
export 'secure_phrase_login.pg.dart';

class SignIn {
  static NewDeviceLoginData? newDeviceLoginData;
  static VerifyUserData? verifyUserData;
}
