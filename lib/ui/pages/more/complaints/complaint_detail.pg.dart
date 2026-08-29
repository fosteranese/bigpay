import 'package:flutter/material.dart';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/data/models/complaint/complaint.dart';
import 'package:bigpay/data/models/complaint/complaint_category.dart';
import 'package:bigpay/data/models/complaint/complaint_detail.dart';
import 'package:bigpay/models/actions/complaints/add_complaint_message_action.dart';
import 'package:bigpay/models/actions/complaints/get_complaint_categories_action.dart';
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
import 'package:bigpay/utils/date.util.dart';
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
  ExecuteProcessEvent? _categoriesEvent;
  ComplaintDetail? _detail;
  List<ComplaintCategory> _categories = const [];

  @override
  void initState() {
    super.initState();
    _messageController.addListener(
      () => _canSend.value = _messageController.text.trim().isNotEmpty,
    );
    _loadDetail();
    _categoriesEvent = context.dispatchProcess(
      const GetComplaintCategoriesAction(),
      returnSavedResponse: true,
      saveActionResponse: true,
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _canSend.dispose();
    _isSending.dispose();
    super.dispose();
  }

  String? get _complaintId => widget.complaint?.id;

  static final _uuid = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  /// [Complaint.category] is meant to be a human-readable label, but some
  /// complaints only ever get a raw category id in that field — resolved
  /// against the same category list the new-complaint form itself picks
  /// from, so the id still shows as a real name. Falls back to the raw
  /// value on the off chance it isn't actually a UUID (still better than
  /// showing nothing), and to null only if there's truly nothing usable.
  String? get _subtitle {
    final category = widget.complaint?.category;
    if (category == null || category.isEmpty) return null;
    if (!_uuid.hasMatch(category)) return category;

    final resolved = _categories
        .where((c) => c.id == category)
        .map((c) => c.name)
        .firstOrNull;
    return (resolved?.isNotEmpty ?? false) ? resolved : null;
  }

  /// The complaint's own original description, shown above the reply
  /// trail — `Complaint` has no dedicated field for it, but for a fresh
  /// complaint (before any replies) `lastMessage` *is* that original text.
  /// Skipped if the trail already opens with the exact same line, so it
  /// never shows twice.
  Widget? _originalMessageCard(BuildContext context) {
    final message = widget.complaint?.lastMessage;
    if (message == null || message.isEmpty) return null;
    if (message == _detail?.messages.firstOrNull?.message) return null;

    return Container(
      margin: const .only(bottom: 12),
      padding: const .all(12),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: .circular(12),
        border: .all(color: context.border),
      ),
      child: Column(
        crossAxisAlignment: .start,
        mainAxisSize: .min,
        children: [
          Text(
            AppLocalizations.of(context)!.complaintsOriginalRequestLabel,
            style: context.caption.copyWith(color: context.accentGreen),
          ),
          const SizedBox(height: 4),
          Text(message, style: context.smallDetails),
        ],
      ),
    );
  }

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
    return MultiProcessListener(
      listeners: [
        ProcessListenerConfig<bool>(
          event: () => _replyEvent,
          listener: (context, snapshot) {
            // A reply is a small, in-place action — the send button's own
            // spinner is enough feedback; the app-wide modal blocker (used
            // for page-level actions elsewhere) would be disproportionate
            // here and block the whole pane just to post one chat message.
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
        ),
        ProcessListenerConfig<List<ComplaintCategory>>(
          event: () => _categoriesEvent,
          listener: (context, snapshot) {
            if (snapshot.hasData) {
              setState(() => _categories = snapshot.data ?? const []);
            }
          },
        ),
      ],
      child: MainLayout(
        useScaffold: widget.onBack == null,
        onBack: widget.onBack,
        // Tints the message area like a chat wallpaper, so bubbles read as
        // a conversation surface instead of floating on the page background.
        bodyColor: context.scaffoldBg,
        // Bubbles are already visually distinct blocks — they don't need
        // the same breathing room from the edge a form or a list gets.
        bodyHorizontalPadding: 10,
        // A short thread should sit at the bottom near the composer, like
        // every chat UI (this one included, on phone) — not centered with
        // equal blank margins above and below.
        bottomAlign: true,
        bottomSize: 76,
        title:
            widget.complaint?.subject ??
            AppLocalizations.of(context)!.complaintsFallbackTitle,
        subtitle: _subtitle,
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
            if (snapshot.isLoading) {
              return const ChatBubbleSkeleton();
            }

            final messages = _detail?.messages ?? const [];
            final original = _originalMessageCard(context);
            if (messages.isEmpty && original == null) {
              return Center(
                child: Text(
                  AppLocalizations.of(context)!.complaintsNoMessages,
                  style: context.smallDetails,
                ),
              );
            }

            return Column(
              children: [
                ?original,
                for (var i = 0; i < messages.length; i++) ...[
                  // A day divider ahead of the first message in the trail,
                  // and again wherever the calendar day actually changes
                  // from the message before it — never repeated for a run
                  // of messages still on the same day.
                  if (i == 0 ||
                      !DateUtil.isSameDay(
                        messages[i].date,
                        messages[i - 1].date,
                      ))
                    ComplaintDateDivider(date: messages[i].date),
                  ComplaintBubble(
                    message: messages[i],
                    // Whether this message opens/closes a consecutive run
                    // from the same sender — a day boundary always breaks
                    // the run too, even mid-streak from the same sender, so
                    // a bubble right before or after a date divider never
                    // ends up flattened against a neighbor on the other
                    // side of it (see ComplaintBubble's own doc).
                    isGroupStart:
                        i == 0 ||
                        messages[i - 1].fromUser != messages[i].fromUser ||
                        !DateUtil.isSameDay(
                          messages[i - 1].date,
                          messages[i].date,
                        ),
                    isGroupEnd:
                        i == messages.length - 1 ||
                        messages[i + 1].fromUser != messages[i].fromUser ||
                        !DateUtil.isSameDay(
                          messages[i + 1].date,
                          messages[i].date,
                        ),
                  ),
                ],
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
              // A single line, like every chat composer — it was reserving
              // room for up to 4 lines even when empty, towering over the
              // send button next to it.
              maxLines: 1,
              padding: const .symmetric(horizontal: 15, vertical: 10),
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
