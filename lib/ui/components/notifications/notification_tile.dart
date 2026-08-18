import 'package:flutter/material.dart';

import 'package:bigpay/data/models/notification/push_notification.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';

/// One notification row — unread items are emphasised with a bold title and a
/// dot, matching umb's read/unread treatment.
class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    this.onTap,
  });

  final PushNotification notification;
  final VoidCallback? onTap;

  String get _time {
    final t = notification.sentTime;
    if (t == null) return '';
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${t.day.toString().padLeft(2, '0')}/'
        '${t.month.toString().padLeft(2, '0')}/${t.year}';
  }

  @override
  Widget build(BuildContext context) {
    final unread = !notification.read;

    return ListTile(
      onTap: onTap,
      contentPadding: const .symmetric(horizontal: 20, vertical: 4),
      leading: Stack(
        clipBehavior: .none,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: context.avatarBg,
            child: Icon(
              unread ? Icons.notifications : Icons.notifications_none,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          if (unread)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.danger,
                  shape: .circle,
                  border: Border.all(color: context.cardBg, width: 1.5),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        notification.title ?? 'Notification',
        maxLines: 1,
        overflow: .ellipsis,
        style: unread ? context.smallDetailsBold : context.smallDetailsMedium,
      ),
      subtitle: Column(
        crossAxisAlignment: .start,
        children: [
          if (notification.content?.isNotEmpty ?? false)
            Padding(
              padding: const .only(top: 2),
              child: Text(
                notification.content!,
                maxLines: 2,
                overflow: .ellipsis,
                style: context.caption,
              ),
            ),
          const SizedBox(height: 4),
          Text(_time, style: context.caption.copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}
