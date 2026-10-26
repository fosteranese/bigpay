import 'package:equatable/equatable.dart';

/// One complaint in the list from `MyAccount/myComplaints`, and the header of a
/// complaint detail. Field names are read tolerantly since the exact backend
/// shape isn't pinned down.
class Complaint extends Equatable {
  const Complaint({
    this.id,
    this.reference,
    this.subject,
    this.category,
    this.status,
    this.statusLabel,
    this.lastMessage,
    this.date,
  });

  final String? id;
  final String? reference;
  final String? subject;
  final String? category;
  final String? status;
  final String? statusLabel;
  final String? lastMessage;
  final String? date;

  factory Complaint.fromMap(Map<String, dynamic> data) => Complaint(
    id: (data['id'] ??
            data['complaintId'] ??
            data['ticketId'] ??
            data['complaintNumber'])
        ?.toString(),
    reference: (data['reference'] ??
            data['ticketNumber'] ??
            data['complaintRef'] ??
            data['refNumber'])
        ?.toString(),
    subject:
        (data['subject'] ?? data['title'] ?? data['complaintSubject'])
            ?.toString(),
    category: (data['category'] ??
            data['categoryName'] ??
            data['complaintCategory'])
        ?.toString(),
    status: data['status']?.toString(),
    statusLabel: (data['statusLabel'] ??
            data['statusName'] ??
            data['statusDescription'])
        ?.toString(),
    lastMessage: (data['lastMessage'] ??
            data['message'] ??
            data['description'])
        ?.toString(),
    date: (data['date'] ??
            data['createdDate'] ??
            data['dateCreated'] ??
            data['createdAt'])
        ?.toString(),
  );

  @override
  List<Object?> get props => [
    id,
    reference,
    subject,
    category,
    status,
    statusLabel,
    lastMessage,
    date,
  ];
}
