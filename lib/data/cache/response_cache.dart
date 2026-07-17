import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'package:bigpay/data/database/db.dart';
import 'package:bigpay/data/models/response/response.md.dart';
import 'package:bigpay/logger.dart';
import 'package:bigpay/models/actions/action.dart';

class ResponseCache {
  ResponseCache(this._db);

  final Database _db;
  final Map<String, DataResponse> _memory = {};
  final Map<String, String> _latestKeyByEndpoint = {};

  static String _hash(String value) =>
      sha256.convert(utf8.encode(value)).toString();
  static String keyFor(Action action) =>
      _hash('${action.endpoint}:${action.payload.toJsonString()}');

  static String _endpointPointerKey(String endpoint) =>
      _hash('endpoint-latest:$endpoint');

  Future<DataResponse?> read(String key) async {
    final inMemory = _memory[key];
    if (inMemory != null) return inMemory;

    try {
      final stored = await _db.read(key);
      if (stored == null || stored.isEmpty) return null;

      final response = DataResponse.fromMap(stored);
      _memory[key] = response;
      return response;
    } catch (ex) {
      logger.e('ResponseCache read failed for $key: $ex');
      return null;
    }
  }

  void write(
    String key,
    DataResponse response, {
    required String endpoint,
  }) {
    _memory[key] = response;
    _latestKeyByEndpoint[endpoint] = key;
    _db.add(key: key, payload: response.toMap());
    _db.add(
      key: _endpointPointerKey(endpoint),
      payload: {'key': key},
    );
  }

  Future<DataResponse?> latestForEndpoint(String endpoint) async {
    final inMemoryKey = _latestKeyByEndpoint[endpoint];
    if (inMemoryKey != null) {
      final cached = await read(inMemoryKey);
      if (cached != null) return cached;
    }

    final pointer = await _db.read(_endpointPointerKey(endpoint));
    final key = pointer?['key'] as String?;
    if (key == null) return null;

    return read(key);
  }

  /// Drops [key] from both tiers — e.g. to invalidate a stale entry.
  Future<void> remove(String key) async {
    _memory.remove(key);
    await _db.delete(key);
  }
}
