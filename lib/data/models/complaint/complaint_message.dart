import 'package:equatable/equatable.dart';

/// One message in a complaint's trail — rendered as a chat bubble, aligned by
/// [fromUser].
class ComplaintMessage extends Equatable {
  const ComplaintMessage({
    this.message,
    this.sender,
    this.date,
    this.fromUser = false,
  });

  final String? message;
  final String? sender;
  final String? date;

  /// True when the customer sent it (right-aligned); false for a support agent.
  final bool fromUser;

  factory ComplaintMessage.fromMap(Map<String, dynamic> data) {
    final flag = data['isUser'] ??
        data['fromUser'] ??
        data['isCustomer'] ??
        data['mine'] ??
        data['isMine'];

    bool fromUser;
    if (flag is bool) {
      fromUser = flag;
    } else {
      final direction = (data['direction'] ??
              data['senderType'] ??
              data['type'] ??
              data['source'] ??
              data['sender'] ??
              '')
          .toString()
          .toLowerCase();
      fromUser = direction.contains('user') ||
          direction.contains('customer') ||
          direction.contains('client') ||
          direction == 'me' ||
          direction == 'out' ||
          direction == 'outbound' ||
          direction == 'sent';
    }

    return ComplaintMessage(
      message: (data['message'] ??
              data['body'] ??
              data['text'] ??
              data['content'] ??
              data['comment'])
          ?.toString(),
      sender: (data['senderName'] ??
              data['author'] ??
              data['name'] ??
              data['sender'])
          ?.toString(),
      date: (data['date'] ??
              data['createdDate'] ??
              data['timestamp'] ??
              data['dateCreated'] ??
              data['createdAt'])
          ?.toString(),
      fromUser: fromUser,
    );
  }

  @override
  List<Object?> get props => [message, sender, date, fromUser];
}
