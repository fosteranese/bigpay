import 'package:flutter/material.dart';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/data/models/complaint/complaint.dart';
import 'package:bigpay/data/models/complaint/complaint_detail.dart';
import 'package:bigpay/models/actions/complaints/add_complaint_message_action.dart';
import 'package:bigpay/models/actions/complaints/get_complaint_detail_action.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/complaints/complaint_bubble.dart';
import 'package:bigpay/ui/components/forms/forms.dart';
import 'package:bigpay/ui/components/process_builder.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/utils/message.util.dart';

/// A complaint's trail, from `MyAccount/complaintDetail`, rendered as a chat.
/// The composer posts replies via `MyAccount/addComplaintMessage`, then the
/// detail is refetched to show them.
class ComplaintDetailPage extends StatefulWidget {
  const ComplaintDetailPage({super.key, this.complaint});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/more/complaint-detail',
  );

  final Complaint? complaint;

  @override
  State<ComplaintDetailPage> createState() => _ComplaintDetailPageState();
}

class _ComplaintDetailPageState extends State<ComplaintDetailPage> {
  final _messageController = TextEditingController();
  final _canSend = ValueNotifier(false);

  ExecuteProcessEvent? _detailEvent;
  ExecuteProcessEvent? _replyEvent;
  ComplaintDetail? _detail;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(
      () => _canSend.value = _messageController.text.trim().isNotEmpty,
    );
    _loadDetail();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _canSend.dispose();
    super.dispose();
  }

  String? get _complaintId => widget.complaint?.id;

  void _loadDetail() {
    _detailEvent = context.dispatchProcess(
      GetComplaintDetailAction(
        payload: GetComplaintDetailPayload(complaintId: _complaintId),
      ),
    );
  }

  void _send() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;
    FocusScope.of(context).unfocus();

    _replyEvent = context.dispatchProcess(
      AddComplaintMessageAction(
        payload: AddComplaintMessagePayload(
          complaintId: _complaintId,
          message: message,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProcessListener<bool>(
      event: () => _replyEvent,
      listener: (context, snapshot) {
        if (snapshot.isLoading) {
          MessageUtil.displayLoading(context);
          return;
        }
        MessageUtil.close(context);

        if (snapshot.isSuccessful) {
          _replyEvent = null;
          _messageController.clear();
          // Refetch the trail so the new reply shows.
          setState(_loadDetail);
          return;
        }

        if (snapshot.hasError) {
          _replyEvent = null;
          MessageUtil.displayErrorDialog(
            context,
            message: snapshot.error!.message,
          );
        }
      },
      child: MainLayout(
        bottomSize: 76,
        title: widget.complaint?.subject ?? 'Complaint',
        subtitle: widget.complaint?.category,
        bottomNav: _buildComposer(),
        child: ProcessConsumer<ComplaintDetail>(
          event: () => _detailEvent,
          listener: (context, snapshot) {
            if (snapshot.hasData) {
              setState(() => _detail = snapshot.data);
            }
          },
          builder: (context, snapshot) {
            if (_detail == null && snapshot.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final messages = _detail?.messages ?? const [];
            if (messages.isEmpty) {
              return Center(
                child: Text(
                  'No messages yet.',
                  style: AppTypography.smallDetails,
                ),
              );
            }

            return Column(
              children: [
                for (final message in messages)
                  ComplaintBubble(message: message),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildComposer() {
    return Row(
      crossAxisAlignment: .end,
      children: [
        Expanded(
          child: FormInput(
            controller: _messageController,
            placeholder: 'Type a reply…',
            maxLines: 4,
          ),
        ),
        const SizedBox(width: 8),
        ValueListenableBuilder(
          valueListenable: _canSend,
          builder: (context, canSend, child) {
            return IconButton.filled(
              style: IconButton.styleFrom(
                backgroundColor: canSend
                    ? AppColors.primary
                    : AppColors.subtitleGrey,
                fixedSize: const Size(48, 48),
              ),
              onPressed: canSend ? _send : null,
              icon: Icon(Icons.send_rounded, color: AppColors.white, size: 20),
            );
          },
        ),
      ],
    );
  }
}
