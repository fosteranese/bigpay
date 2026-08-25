import 'package:flutter/material.dart';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/data/models/complaint/complaint.dart';
import 'package:bigpay/data/models/complaint/complaint_detail.dart';
import 'package:bigpay/models/actions/complaints/add_complaint_message_action.dart';
import 'package:bigpay/models/actions/complaints/get_complaint_detail_action.dart';
import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/complaints/complaint_bubble.dart';
import 'package:bigpay/ui/components/forms/forms.dart';
import 'package:bigpay/ui/components/process_builder.dart';
import 'package:bigpay/ui/components/skeleton/variants.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/utils/message.util.dart';

/// A pushed full page wrapping [ComplaintDetailView] — used on every device
/// except a foldable in book mode (or a wide screen), where [ComplaintsPage]
/// shows the same view inline in the second pane instead (see
/// [MasterDetailLayout]).
class ComplaintDetailPage extends StatelessWidget {
  const ComplaintDetailPage({super.key, this.complaint});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/more/complaint-detail',
  );

  final Complaint? complaint;

  @override
  Widget build(BuildContext context) {
    return ComplaintDetailView(complaint: complaint);
  }
}

/// A complaint's trail, from `MyAccount/complaintDetail`, rendered as a chat
/// — independent of how it's hosted: a pushed page ([ComplaintDetailPage],
/// default back behavior) or an inline pane in [ComplaintsPage]'s split view
/// ([onBack] provided, clears the pane's selection instead of popping a
/// route that was never pushed). The composer posts replies via
/// `MyAccount/addComplaintMessage`, then the detail is refetched to show
/// them.
class ComplaintDetailView extends StatefulWidget {
  const ComplaintDetailView({super.key, this.complaint, this.onBack});

  final Complaint? complaint;
  final VoidCallback? onBack;

  @override
  State<ComplaintDetailView> createState() => _ComplaintDetailViewState();
}

class _ComplaintDetailViewState extends State<ComplaintDetailView> {
  final _messageController = TextEditingController();
  final _canSend = ValueNotifier(false);
  final _isSending = ValueNotifier(false);

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
    _isSending.dispose();
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
        // A reply is a small, in-place action — the send button's own
        // spinner is enough feedback; the app-wide modal blocker (used for
        // page-level actions elsewhere) would be disproportionate here and
        // block the whole pane just to post one chat message.
        _isSending.value = snapshot.isLoading;
        if (snapshot.isLoading) return;

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
        useScaffold: widget.onBack == null,
        onBack: widget.onBack,
        // Tints the message area like a chat wallpaper, so bubbles read as
        // a conversation surface instead of floating on the page background.
        bodyColor: context.scaffoldBg,
        // A short thread should sit at the bottom near the composer, like
        // every chat UI (this one included, on phone) — not centered with
        // equal blank margins above and below.
        bottomAlign: true,
        bottomSize: 76,
        title:
            widget.complaint?.subject ??
            AppLocalizations.of(context)!.complaintsFallbackTitle,
        subtitle: widget.complaint?.category,
        onRefresh: () async {
          _loadDetail();
          await context.awaitProcess(_detailEvent);
        },
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
              return const Center(child: ListItemSkeleton());
            }

            final messages = _detail?.messages ?? const [];
            if (messages.isEmpty) {
              return Center(
                child: Text(
                  AppLocalizations.of(context)!.complaintsNoMessages,
                  style: context.smallDetails,
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
          child: ValueListenableBuilder(
            valueListenable: _isSending,
            builder: (context, sending, child) => FormInput(
              controller: _messageController,
              readOnly: sending,
              placeholder: AppLocalizations.of(context)!.complaintsReplyPlaceholder,
              maxLines: 4,
            ),
          ),
        ),
        const SizedBox(width: Spacing.sm),
        ValueListenableBuilder(
          valueListenable: _canSend,
          builder: (context, canSend, child) => ValueListenableBuilder(
            valueListenable: _isSending,
            builder: (context, sending, child) {
              final enabled = canSend && !sending;
              return IconButton.filled(
                tooltip: AppLocalizations.of(context)!.complaintsSendMessageTooltip,
                style: IconButton.styleFrom(
                  backgroundColor: enabled
                      ? AppColors.primary
                      : context.textSecondary,
                  fixedSize: const Size(48, 48),
                ),
                onPressed: enabled ? _send : null,
                icon: sending
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : Icon(
                        Icons.send_rounded,
                        color: AppColors.white,
                        size: 20,
                      ),
              );
            },
          ),
        ),
      ],
    );
  }
}
