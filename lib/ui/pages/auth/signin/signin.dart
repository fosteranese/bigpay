import 'package:bigpay/data/models/new_device_login_data.dart';
import 'package:bigpay/data/models/verify_user_data/verify_user_data.dart';
import 'package:bigpay/utils/app_state.util.dart';
import 'package:bigpay/utils/phone.util.dart';

export 'biometric_login.pg.dart';
export 'existing_login.pg.dart';
export 'new_login.pg.dart';
export 'secure_phrase_login.pg.dart';

class SignIn {
  SignIn._();

  static String phoneNumber = '';
  static String password = '';
  static NewDeviceLoginData? newDeviceLoginData;
  static VerifyUserData? verifyUserData;

  static void clear() {
    phoneNumber =
        AppState.currentUser?.user?.shortName?.toLocalPhone ?? '';
    password = '';
    newDeviceLoginData = null;
    verifyUserData = null;
  }
}
