import 'package:equatable/equatable.dart';

/// A push/in-app notification, stored locally (like umb). Field names are read
/// tolerantly so a raw FCM payload or a saved record both map cleanly.
class PushNotification extends Equatable {
  const PushNotification({
    this.id,
    this.title,
    this.content,
    this.image,
    this.read = false,
    this.customData,
    this.sentTime,
  });

  final String? id;
  final String? title;
  final String? content;
  final String? image;
  final bool read;
  final Map<String, dynamic>? customData;
  final DateTime? sentTime;

  factory PushNotification.fromMap(Map<String, dynamic> data) {
    final rawTime = data['sentTime'] ?? data['timestamp'] ?? data['date'];
    DateTime? sent;
    if (rawTime is int) {
      sent = DateTime.fromMillisecondsSinceEpoch(rawTime);
    } else if (rawTime is String) {
      sent = DateTime.tryParse(rawTime);
    }

    final rawRead = data['read'];

    return PushNotification(
      id: (data['id'] ?? data['notificationId'] ?? data['messageId'])
          ?.toString(),
      title: (data['title'] ?? data['heading'])?.toString(),
      content: (data['content'] ?? data['body'] ?? data['message'])?.toString(),
      image: (data['image'] ?? data['imageUrl'])?.toString(),
      read: rawRead is bool ? rawRead : rawRead?.toString() == 'true',
      customData: data['customData'] is Map
          ? (data['customData'] as Map).cast<String, dynamic>()
          : null,
      sentTime: sent,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'content': content,
    'image': image,
    'read': read,
    'customData': customData,
    'sentTime': sentTime?.millisecondsSinceEpoch,
  };

  PushNotification copyWith({bool? read}) => PushNotification(
    id: id,
    title: title,
    content: content,
    image: image,
    read: read ?? this.read,
    customData: customData,
    sentTime: sentTime,
  );

  @override
  List<Object?> get props => [
    id,
    title,
    content,
    image,
    read,
    customData,
    sentTime,
  ];
}
