import 'package:bigpay/data/cache/process_store.dart';
import 'package:bigpay/data/database/db.dart';
import 'package:bigpay/data/models/auth_data/auth_data.dart';
import 'package:bigpay/data/models/initialization_data/initialization_data.dart';
import 'package:bigpay/models/device_info.dart';
import 'package:flutter/material.dart';
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
  static final store = ProcessStore.of(db);
  static bool isLinkedMoMoWalletClosed = false;

  static const _themeKey = 'theme-mode';
  static final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);

  static Future<void> loadTheme() async {
    try {
      final raw = await db.readRaw(_themeKey);
      if (raw == null) return;
      final mode = int.tryParse(raw);
      if (mode == null) return;
      themeNotifier.value = ThemeMode.values[mode];
    } catch (_) {}
  }

  static Future<void> setTheme(ThemeMode mode) async {
    themeNotifier.value = mode;
    try {
      await db.add(key: _themeKey, payload: mode.index);
    } catch (_) {}
  }
}
