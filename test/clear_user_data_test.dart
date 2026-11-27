import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'package:bigpay/data/database/db.dart';
import 'package:bigpay/data/models/response/response.md.dart';
import 'package:bigpay/models/actions/startup_action.dart';
import 'package:bigpay/utils/app_state.util.dart';
import 'package:bigpay/utils/biometric.util.dart';

void main() {
  test('clearUserData keeps theme, language and startup cache only', () async {
    final dir = await Directory.systemTemp.createTemp('bigpay-db');
    Hive.init(dir.path);
    Database.box = await Hive.openBox('test');

    final db = AppState.db;
    await db.add(key: 'theme-mode', payload: 'dark');
    await db.add(key: 'app-locale', payload: 'fr');
    await db.add(key: 'auth-phone-number', payload: '0244000000');
    await BiometricUtil.setLoginEnabled(true);
    const r = DataResponse(code: '1', status: 'SUCCESS', message: 'ok');
    AppState.store.cache.write('startup-entry', r, endpoint: StartupAction.path);
    AppState.store.cache.write('wallets-entry', r, endpoint: '/Wallets');
    await Future<void>.delayed(Duration.zero);

    await AppState.clearUserData();

    expect(await db.readRaw('theme-mode'), 'dark');
    expect(await db.readRaw('app-locale'), 'fr');
    expect(await db.readRaw('auth-phone-number'), isNull);
    expect(await BiometricUtil.isLoginEnabled, isFalse);
    expect(await AppState.store.cache.read('wallets-entry'), isNull);
    expect(await AppState.store.cache.read('startup-entry'), isNotNull);
    expect(
      await AppState.store.cache.latestForEndpoint(StartupAction.path, (m) => m),
      isNotNull,
    );
  });
}
