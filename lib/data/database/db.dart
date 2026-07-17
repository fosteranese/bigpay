import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'package:bigpay/logger.dart';

class Database {
  static late Box<dynamic> box;

  static const _boxName = 'bigpay-db.box';
  static const _keyName = 'bigpay-db-key';

  /// Backed by the iOS Keychain and the Android Keystore.
  ///
  /// `first_unlock_this_device` keeps the key off iCloud and out of backups, so
  /// it can never follow the data onto another device, while still being
  /// readable when the app is launched in the background after a reboot.
  static const _secureStorage = FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
    aOptions: AndroidOptions(),
  );

  /// The box key, generated once per install and held in platform secure
  /// storage.
  ///
  /// A key shipped inside the binary is not a secret — every install shares it,
  /// so recovering it once would decrypt every user's box. Generating it on the
  /// device instead means the key is never built, committed, or transmitted.
  static Future<List<int>> _encryptionKey() async {
    final existing = await _secureStorage.read(key: _keyName);
    if (existing != null) {
      return base64Url.decode(existing);
    }

    final key = Hive.generateSecureKey();
    await _secureStorage.write(
      key: _keyName,
      value: base64UrlEncode(key),
    );

    return key;
  }

  /// Opens the box, generating and storing the key on first launch.
  ///
  /// If the key and the box ever diverge — a restored backup, a cleared
  /// Keystore — every frame fails its checksum and Hive's `crashRecovery`
  /// (on by default) truncates the box rather than throwing, so the app comes
  /// up with an empty box instead of no box. That is the right outcome here:
  /// everything stored is re-fetchable cache, and the alternative is refusing
  /// to start. Verified against a deliberately mismatched key.
  static Future<void> init() async {
    try {
      final key = await _encryptionKey();

      Database.box = await Hive.openBox(
        _boxName,
        encryptionCipher: HiveAesCipher(key),
      );
    } catch (ex) {
      logger.e(ex);
    }
  }

  Future<void> deleteAll() async {
    Database.box.clear();
  }

  Future<void> delete(String key) async {
    await Database.box.delete(key);
  }

  Future<void> checkBeforeOperation() async {
    if (!Database.box.isOpen) {
      await Database.init();
    }
  }

  Future<void> add({
    required String key,
    required dynamic payload,
  }) async {
    try {
      await checkBeforeOperation();

      final data = json.encode(payload);
      await Database.box.put(key, data);
    } catch (ex) {
      logger.e(ex);
    }
  }

  Future<Map<String, dynamic>?> read(String key) async {
    try {
      await checkBeforeOperation();

      final raw = await Database.box.get(key);
      if (raw == null) {
        return null;
      }

      return json.decode(raw) as Map<String, dynamic>;
    } catch (ex) {
      logger.e(ex);
      return null;
    }
  }

  Future<String?> readRaw(String key) async {
    try {
      await checkBeforeOperation();
      final record = await Database.box.get(key) as String?;
      return record;
    } catch (ex) {
      logger.e('DB readRaw error: $ex');
      return null;
    }
  }
}
