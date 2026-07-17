import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:bigpay/data/cache/response_cache.dart';
import 'package:bigpay/data/database/db.dart';
import 'package:bigpay/data/models/response/response.md.dart';

/// In-memory stand-in for [Database], so the cache logic can be tested without
/// Hive or platform channels. Mirrors [Database.add]'s json encoding.
class FakeDatabase implements Database {
  final Map<String, String> store = {};

  @override
  Future<void> add({required String key, required dynamic payload}) async {
    store[key] = json.encode(payload);
  }

  @override
  Future<Map<String, dynamic>?> read(String key) async {
    final raw = store[key];
    return raw == null ? null : json.decode(raw) as Map<String, dynamic>;
  }

  @override
  Future<void> delete(String key) async => store.remove(key);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

DataResponse _resp(String msg) => DataResponse<dynamic>(
  code: '1',
  status: 'SUCCESS',
  message: msg,
  data: {'value': msg},
);

void main() {
  const endpoint = '/MyAccount/dashboard';
  final keyA = 'k:a';
  final keyB = 'k:b';

  test('latestForEndpoint returns the most recent write for an endpoint', () async {
    final cache = ResponseCache(FakeDatabase());

    cache.write(keyA, _resp('page-1'), endpoint: endpoint);
    expect((await cache.latestForEndpoint(endpoint))?.message, 'page-1');

    // A different payload → different key, same endpoint. Latest wins.
    cache.write(keyB, _resp('page-2'), endpoint: endpoint);
    expect((await cache.latestForEndpoint(endpoint))?.message, 'page-2');
  });

  test('content-addressed read still finds the specific older entry', () async {
    final cache = ResponseCache(FakeDatabase());
    cache.write(keyA, _resp('page-1'), endpoint: endpoint);
    cache.write(keyB, _resp('page-2'), endpoint: endpoint);

    expect((await cache.read(keyA))?.message, 'page-1');
    expect((await cache.read(keyB))?.message, 'page-2');
  });

  test('unknown endpoint is a clean miss', () async {
    final cache = ResponseCache(FakeDatabase());
    expect(await cache.latestForEndpoint('/nothing/here'), isNull);
  });

  test('resolves via the persisted pointer when memory is cold', () async {
    final db = FakeDatabase();
    ResponseCache(db).write(keyB, _resp('page-2'), endpoint: endpoint);

    // A fresh cache over the same store has an empty memory tier.
    final cold = ResponseCache(db);
    expect((await cold.latestForEndpoint(endpoint))?.message, 'page-2');
  });

  test('endpoint is never stored as a plaintext disk key', () async {
    final db = FakeDatabase();
    ResponseCache(db).write(keyA, _resp('page-1'), endpoint: endpoint);

    expect(
      db.store.keys.any((k) => k.contains('MyAccount')),
      isFalse,
    );
  });

  test('remove invalidates a content entry', () async {
    final cache = ResponseCache(FakeDatabase());
    cache.write(keyA, _resp('page-1'), endpoint: endpoint);

    await cache.remove(keyA);
    expect(await cache.read(keyA), isNull);
  });
}
