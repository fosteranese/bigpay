import 'dart:ui' as ui;

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

  /// True while a [MasterDetailLayout]'s split is actually showing a detail
  /// pane (book mode or a wide screen, with something selected) — [MainShell]
  /// listens to this to collapse the sidebar/rail while it's active, so a
  /// tab-root split-view page (Services, Wallets, History) reads the same
  /// way a pushed one already does (Complaints, Beneficiaries — full-width
  /// master+detail, no competing nav chrome). Purely in-memory UI state, not
  /// persisted — [MasterDetailLayout] itself keeps this in sync as its own
  /// `detail` prop changes.
  static final splitDetailOpenNotifier = ValueNotifier<bool>(false);

  /// Bumped whenever an action elsewhere completes in a way that should
  /// invalidate a tab-root page's own list (a wallet linked, a transaction
  /// processed) — those pages (Dashboard, Wallets, History) live in separate
  /// [StatefulShellBranch] navigators from the process-flow pages that
  /// trigger this, so they can't rely on a same-navigator pop/[RouteAware]
  /// to know to refresh. Each listens in `initState` and re-loads its own
  /// data when this changes, rather than trying to target one specific page
  /// — cheap to over-refresh, not safe to miss one.
  static final dataChangedNotifier = ValueNotifier<int>(0);

  static void notifyDataChanged() {
    dataChangedNotifier.value++;
  }

  static const _phoneKey = 'auth-phone-number';

  /// The phone number this device last logged in with, persisted so the
  /// existing-device unlock screen has one to send on a fresh app launch —
  /// before that, it was read off [User.shortName], which is a display
  /// name, not a phone number, and stopped working once the backend
  /// actually started returning one there.
  static String? savedPhoneNumber;

  static Future<void> loadPhoneNumber() async {
    try {
      savedPhoneNumber = await db.readRaw(_phoneKey);
    } catch (_) {}
  }

  static Future<void> savePhoneNumber(String phone) async {
    if (phone.isEmpty) return;
    savedPhoneNumber = phone;
    try {
      await db.add(key: _phoneKey, payload: phone);
    } catch (_) {}
  }

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

  static const _localeKey = 'app-locale';
  static const supportedLocales = [
    Locale('en'),
    Locale('de'),
    Locale('es'),
    Locale('fr'),
    Locale('ar'),
    Locale('pcm'),
  ];
  static final localeNotifier = ValueNotifier<Locale?>(null);

  static Future<void> loadLocale() async {
    try {
      final raw = await db.readRaw(_localeKey);
      if (raw == null) return;
      if (!supportedLocales.any((locale) => locale.languageCode == raw)) {
        return;
      }
      localeNotifier.value = Locale(raw);
    } catch (_) {}
  }

  static Future<void> setLocale(Locale? locale) async {
    localeNotifier.value = locale;
    try {
      if (locale == null) {
        await db.delete(_localeKey);
      } else {
        await db.add(key: _localeKey, payload: locale.languageCode);
      }
    } catch (_) {}
  }

  /// The language code actually in effect — the user's explicit choice, or
  /// (when they've left it on "Auto") whichever of [supportedLocales] best
  /// matches the device's system locale, the same fallback `MaterialApp`
  /// applies when `locale` is null. Used to tell the backend what language
  /// the app is rendered in, independent of any widget/BuildContext.
  static String get effectiveLocaleCode {
    final selected = localeNotifier.value;
    if (selected != null) return selected.languageCode;

    final systemLanguageCode =
        ui.PlatformDispatcher.instance.locale.languageCode;
    final match = supportedLocales.firstWhere(
      (locale) => locale.languageCode == systemLanguageCode,
      orElse: () => supportedLocales.first,
    );
    return match.languageCode;
  }
}
