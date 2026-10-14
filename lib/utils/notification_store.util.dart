import 'package:bigpay/data/models/notification/push_notification.dart';
import 'package:bigpay/utils/app_state.util.dart';

/// Local store for notifications, backed by the encrypted Hive box — mirrors
/// umb, where notifications accumulate on-device rather than from an endpoint.
/// A push handler can call [add]; the notifications page reads and mutates via
/// the rest.
class NotificationStore {
  NotificationStore._();

  static const _key = 'notifications';

  /// All notifications, newest first.
  static Future<List<PushNotification>> all() async {
    final record = await AppState.db.read(_key);
    final items = record?['items'];
    if (items is! List) return const [];
    final list = items
        .whereType<Map<String, dynamic>>()
        .map(PushNotification.fromMap)
        .toList();
    list.sort(
      (a, b) => (b.sentTime ?? DateTime(0)).compareTo(a.sentTime ?? DateTime(0)),
    );
    return list;
  }

  static Future<int> unreadCount() async {
    final list = await all();
    return list.where((n) => !n.read).length;
  }

  static Future<void> _write(List<PushNotification> list) => AppState.db.add(
    key: _key,
    payload: {'items': list.map((e) => e.toMap()).toList()},
  );

  /// Adds (or replaces, by id) a notification at the top.
  static Future<void> add(PushNotification notification) async {
    final list = await all();
    if (notification.id != null) {
      list.removeWhere((e) => e.id == notification.id);
    }
    await _write([notification, ...list]);
  }

  static Future<List<PushNotification>> markRead(String? id) async {
    final list = await all();
    final updated = [
      for (final n in list) n.id == id ? n.copyWith(read: true) : n,
    ];
    await _write(updated);
    return updated;
  }

  static Future<List<PushNotification>> markAllRead() async {
    final updated = [for (final n in await all()) n.copyWith(read: true)];
    await _write(updated);
    return updated;
  }

  static Future<List<PushNotification>> delete(String? id) async {
    final list = await all()
      ..removeWhere((e) => e.id == id);
    await _write(list);
    return list;
  }

  /// Clears everything (e.g. on logout).
  static Future<void> clear() => AppState.db.delete(_key);
}
