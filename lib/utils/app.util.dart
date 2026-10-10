import 'dart:io';

import 'package:bigpay/data/models/response/response.md.dart';
import 'package:bigpay/models/device_info.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:package_info_plus/package_info_plus.dart' as pip;

import 'package:bigpay/env/env.dart';
import 'package:bigpay/logger.dart';
import 'package:bigpay/utils/app_state.util.dart';

class AppUtil {
  static String get appId {
    if (Platform.isAndroid) {
      return Env.androidBundleId;
    }

    if (Platform.isIOS) {
      return Env.iosBundleId;
    }

    return Env.appId;
  }

  static Future<void> getInfo() async {
    _getCountries();

    await Future.wait([deviceInfo, packageInfo]);
  }

  static DeviceInfo get info {
    // `latitude`, `longitude` and `fcmToken` stay unset until location and
    // Firebase are wired up.
    AppState.details = (AppState.device ?? AppState.details).copyWith(
      build: AppState.appPackage?.buildNumber,
      version: AppState.appPackage?.version,
      channel: AppState.appPackage?.packageName,
    );

    return AppState.details;
  }

  static Future<DeviceInfo> get deviceInfo async {
    final device = DeviceInfoPlugin();
    DeviceInfo? newInfo;
    try {
      String udid = await FlutterUdid.udid;
      if (Platform.isAndroid) {
        final android = await device.androidInfo;

        newInfo = DeviceInfo(
          channel: android.device,
          description:
              '${android.manufacturer}::${android.brand}::${android.model}::${android.display}::${android.version}::${android.device}::$udid::${android.isPhysicalDevice}',
          deviceId: udid,
          deviceName: android.product,
          deviceType: 'android',
          userAgent: android.device,
          version: android.version.release,
          isPhysicalDevice: android.isPhysicalDevice,
        );
      } else if (Platform.isIOS) {
        final ios = await device.iosInfo;
        newInfo = DeviceInfo(
          channel: ios.utsname.release,
          description:
              '${ios.utsname.sysname}::${ios.model}::${ios.utsname.release}::${ios.utsname.version}::${ios.systemVersion}::${ios.isPhysicalDevice}',
          deviceId: udid,
          deviceName: ios.name,
          deviceType: 'iphone',
          userAgent: ios.utsname.machine,
          version: ios.utsname.version,
          isPhysicalDevice: ios.isPhysicalDevice,
        );
      }
    } catch (ex) {
      logger.e(ex);
    }

    if (newInfo != null) {
      AppState.device = newInfo;
    }

    return AppState.device ?? AppState.details;
  }

  static Future<pip.PackageInfo?> get packageInfo async {
    try {
      AppState.appPackage = await pip.PackageInfo.fromPlatform();
      if (AppState.appPackage != null) {
        AppState.appPackage = pip.PackageInfo(
          appName: AppState.appPackage!.appName,
          buildNumber: AppState.appPackage?.buildNumber ?? Env.buildNumber,
          packageName: AppState.appPackage!.packageName,
          version: AppState.appPackage!.version,
          buildSignature: AppState.appPackage!.buildSignature,
          installerStore: AppState.appPackage!.installerStore,
        );
      }

      logger.i(AppState.appPackage);
      logger.i(AppState.appPackage?.buildNumber ?? '');
    } catch (ex) {
      logger.e(ex);
    }

    return AppState.appPackage;
  }

  static List<CountryWithPhoneCode> _getCountries() {
    AppState.countries = CountryManager().countries
      ..sort(
        (a, b) => (a.countryName ?? '').compareTo(
          b.countryName ?? '',
        ),
      );
    AppState.gh = AppState.countries.firstWhere(
      (element) => element.countryCode == 'GH',
    );
    AppState.currentCountry = AppState.gh;

    return AppState.countries;
  }

  static void forceUpdate(DataError result) {
    // AppNav.read<AuthBloc>().add(
    //   ForceUpdate(result),
    // );
  }
}
