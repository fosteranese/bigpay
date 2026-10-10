import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'package:bigpay/logger.dart';

class Database {
  static Box<dynamic>? _box;

  /// The open box. Only valid after [init]/[checkBeforeOperation] — every
  /// public operation below routes through [checkBeforeOperation] first.
  static Box<dynamic> get box => _box!;

  /// Lets tests inject a fake box (and the app assign the real one in [init]).
  static set box(Box<dynamic> value) => _box = value;

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
  /// Keystore/Keychain — `crashRecovery` only heals a *truncated trailing*
  /// frame; a box that can't be decoded with the current key makes hive_ce
  /// throw instead (`Could not read the box. The encryption cipher may be
  /// wrong or the box may be corrupted.`). To keep the app startable we
  /// delete the unreadable box and retry, coming up empty. That is the right
  /// outcome here: everything stored is re-fetchable cache, and the
  /// alternative is refusing to start.
  static Future<void> init() async {
    try {
      final key = await _encryptionKey();
      await _open(key);
    } catch (ex) {
      logger.e(ex);

      // A box that can't be decoded with the current key (diverged
      // Keychain/Keystore, restored backup) never got registered, so it must
      // be removed from disk before a fresh open can succeed.
      try {
        await Hive.deleteBoxFromDisk(_boxName);
      } catch (_) {
        // Nothing on disk — a fresh open below creates the box.
      }
      await _open(await _encryptionKey());
    }
  }

  static Future<void> _open(List<int> key) async {
    Database._box = await Hive.openBox(
      _boxName,
      encryptionCipher: HiveAesCipher(key),
    );
  }

  Future<void> deleteAll() async {
    await checkBeforeOperation();
    await Database.box.clear();
  }

  /// Deletes every key except [keep].
  Future<void> deleteAllExcept(Set<String> keep) async {
    await checkBeforeOperation();
    final doomed = Database.box.keys.where((k) => !keep.contains(k)).toList();
    await Database.box.deleteAll(doomed);
  }

  Future<void> delete(String key) async {
    await checkBeforeOperation();
    await Database.box.delete(key);
  }

  /// Ensures the box is open before an operation. The box may never have been
  /// assigned (init not yet run, or it caught an error) — check the nullable
  /// backing field, not [box], or this guard itself would throw.
  Future<void> checkBeforeOperation() async {
    if (_box == null || !_box!.isOpen) {
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
      if (record == null) {
        return null;
      }

      // add() always json.encode()s its payload (so a String payload comes
      // back quoted, e.g. `"en"`) — decode here so callers get back exactly
      // what they originally passed in.
      return json.decode(record).toString();
    } catch (ex) {
      logger.e('DB readRaw error: $ex');
      return null;
    }
  }
}
