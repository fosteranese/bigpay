import 'package:bigpay/data/cache/process_store.dart';
import 'package:bigpay/data/database/db.dart';
import 'package:bigpay/data/models/auth_data/auth_data.dart';
import 'package:bigpay/data/models/initialization_data/initialization_data.dart';
import 'package:bigpay/models/device_info.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';
import 'package:package_info_plus/package_info_plus.dart' as pip;

class AppState {
  static DeviceInfo? device;
  static DeviceInfo details = const DeviceInfo();
  static pip.PackageInfo? appPackage;
  static List<CountryWithPhoneCode> countries = [];
  static late CountryWithPhoneCode currentCountry;
  static late CountryWithPhoneCode gh;
  static InitializationData? data;
  static AuthData? currentUser;
  static final db = Database();
  // Shared response cache + request-input store, one instance so the bloc and
  // any outside caller share the same tiers. Reach the parts via `store.cache`
  // and `store.inputs`.
  static final store = ProcessStore.of(db);
  // static final auth = AuthRepo();
  static bool isLinkedMoMoWalletClosed = false;
}
