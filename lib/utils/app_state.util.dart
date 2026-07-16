import 'package:bigpay/models/device_info.dart';
import 'package:bigpay/models/user_response.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';
import 'package:package_info_plus/package_info_plus.dart' as pip;

class AppState {
  static DeviceInfo? device;
  static DeviceInfo details = const DeviceInfo();
  static pip.PackageInfo? appPackage;
  static List<CountryWithPhoneCode> countries = [];
  static late CountryWithPhoneCode currentCountry;
  static late CountryWithPhoneCode gh;
  // static InitializationResponse? data;
  static late UserResponse currentUser;
  // static final db = Database();
  // static final auth = AuthRepo();
  static bool isLinkedMoMoWalletClosed = false;
}
