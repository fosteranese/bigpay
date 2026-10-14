import 'package:equatable/equatable.dart';

import 'package:bigpay/data/models/complaint/complaint.dart';
import 'package:bigpay/data/models/complaint/complaint_message.dart';
import 'package:bigpay/data/models/complaint/complaint_parsing.dart';

/// A complaint plus its message trail, from `MyAccount/complaintDetail`.
class ComplaintDetail extends Equatable {
  const ComplaintDetail({this.complaint, this.messages = const []});

  final Complaint? complaint;
  final List<ComplaintMessage> messages;

  factory ComplaintDetail.fromMap(Map<String, dynamic> data) {
    // The header may be nested under 'complaint'/'detail' or sit at the top
    // level alongside the messages.
    final nested = data['complaint'] ?? data['detail'] ?? data['complaintDetail'];
    final header = nested is Map<String, dynamic> ? nested : data;

    final rawMessages = complaintMapList(data, [
      'messages',
      'trail',
      'conversations',
      'conversation',
      'thread',
      'replies',
      'comments',
    ]);

    return ComplaintDetail(
      complaint: Complaint.fromMap(header),
      messages: rawMessages.map(ComplaintMessage.fromMap).toList(),
    );
  }

  @override
  List<Object?> get props => [complaint, messages];
}
