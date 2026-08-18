import 'package:flutter/material.dart';

import 'package:bigpay/data/models/notification/push_notification.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/button.dart';
import 'package:bigpay/ui/components/notifications/notification_tile.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/utils/notification_store.util.dart';

/// The notifications inbox — reads from the local [NotificationStore] (like
/// umb), splits into New/Earlier, marks read on tap, and swipes to delete.
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/notifications',
  );

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<PushNotification>? _items;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await NotificationStore.all();
    if (!mounted) return;
    setState(() => _items = items);
  }

  Future<void> _markRead(PushNotification n) async {
    if (n.read) return;
    final items = await NotificationStore.markRead(n.id);
    if (!mounted) return;
    setState(() => _items = items);
  }

  Future<void> _markAllRead() async {
    final items = await NotificationStore.markAllRead();
    if (!mounted) return;
    setState(() => _items = items);
  }

  Future<void> _delete(PushNotification n) async {
    final items = await NotificationStore.delete(n.id);
    if (!mounted) return;
    setState(() => _items = items);
  }

  @override
  Widget build(BuildContext context) {
    final items = _items ?? const [];
    final unread = items.where((n) => !n.read).toList();
    final read = items.where((n) => n.read).toList();
    final hasUnread = unread.isNotEmpty;

    return MainLayout(
      title: 'Notifications',
      actions: hasUnread
          ? SizedBox(
              width: 120,
              child: FormButton(
                padding: .zero,
                height: 35,
                labelSize: 12,
                onPressed: _markAllRead,
                text: 'Mark all read',
              ),
            )
          : null,
      child: _items == null
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
          ? _buildEmptyState()
          : Column(
              crossAxisAlignment: .stretch,
              children: [
                if (unread.isNotEmpty) ...[
                  _sectionHeader('New'),
                  for (final n in unread) _buildItem(n),
                ],
                if (read.isNotEmpty) ...[
                  _sectionHeader('Earlier'),
                  for (final n in read) _buildItem(n),
                ],
              ],
            ),
    );
  }

  Widget _buildItem(PushNotification n) {
    return Dismissible(
      key: ValueKey(n.id ?? n.hashCode),
      direction: .endToStart,
      onDismissed: (_) => _delete(n),
      background: Container(
        alignment: .centerRight,
        padding: const .symmetric(horizontal: 24),
        margin: const .only(bottom: 4),
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: .circular(10),
        ),
        child: Icon(Icons.delete_outline, color: AppColors.white),
      ),
      child: NotificationTile(
        notification: n,
        onTap: () => _markRead(n),
      ),
    );
  }

  Widget _sectionHeader(String label) {
    return Padding(
      padding: const .only(left: 20, top: 12, bottom: 4),
      child: Text(label, style: context.captionBold),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const .symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: .min,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 56,
              color: context.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No notifications yet',
              textAlign: .center,
              style: context.p1Medium,
            ),
            const SizedBox(height: 8),
            Text(
              'Updates about your account and transactions will appear here.',
              textAlign: .center,
              style: context.smallDetails,
            ),
          ],
        ),
      ),
    );
  }
}
