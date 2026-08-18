import 'package:flutter/material.dart';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/data/models/complaint/complaint.dart';
import 'package:bigpay/models/actions/complaints/get_my_complaints_action.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/forms.dart';
import 'package:bigpay/ui/components/process_builder.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/pages/more/complaints/complaint_detail.pg.dart';
import 'package:bigpay/ui/pages/process_flow/feedback.pg.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/utils/date.util.dart';

/// The user's complaints, from `MyAccount/myComplaints`. Tapping one opens its
/// chat-style trail; the button starts a new complaint on the feedback form.
class ComplaintsPage extends StatefulWidget {
  const ComplaintsPage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/more/complaints',
  );

  @override
  State<ComplaintsPage> createState() => _ComplaintsPageState();
}

class _ComplaintsPageState extends State<ComplaintsPage> with RouteAware {
  ExecuteProcessEvent? _event;
  List<Complaint>? _complaints;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      appRouteObserver.subscribe(this, route);
    }
  }

  // Returning from the new-complaint form or a detail — refresh the list.
  @override
  void didPopNext() => setState(_load);

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    super.dispose();
  }

  void _load() {
    _event = context.dispatchProcess(
      const GetMyComplaintsAction(),
      returnSavedResponse: true,
      saveActionResponse: true,
    );
  }

  Color _statusColor(BuildContext context, String? status) {
    switch (status?.toLowerCase()) {
      case 'resolved':
      case 'closed':
      case 'success':
        return AppColors.success;
      case 'open':
      case 'pending':
      case 'in progress':
      case 'processing':
        return AppColors.pending;
      default:
        return context.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Complaints',
      bottomSize: 60,
      actions: SizedBox(
        width: 150,
        child: FormButton(
          height: 35,
          labelSize: 13,
          onPressed: () => AppRouter.router.push(FeedbackPage.route.path),
          text: 'New Complaint',
          icon: Icons.add,
          buttonIconAlignment: .left,
          iconSize: 16,
        ),
      ),
      builder: (scrollController) => ProcessConsumer<List<Complaint>>(
        event: () => _event,
        listener: (context, snapshot) {
          if (snapshot.hasData) {
            setState(() => _complaints = snapshot.data);
          }
        },
        builder: (context, snapshot) {
          if (_complaints == null && snapshot.isLoading) {
            return SliverFillRemaining(
              hasScrollBody: false,
              child: const Center(child: CircularProgressIndicator()),
            );
          }

          final complaints = _complaints ?? const [];
          if (complaints.isEmpty) {
            return SliverFillRemaining(
              hasScrollBody: false,
              child: _buildEmptyState(),
            );
          }

          return SliverPadding(
            padding: const .symmetric(vertical: 10),
            sliver: SliverList.separated(
              itemCount: complaints.length,
              separatorBuilder: (_, _) => Divider(
                height: 1,
                color: context.divider,
                indent: 20,
                endIndent: 20,
              ),
              itemBuilder: (context, index) => _buildItem(complaints[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildItem(Complaint complaint) {
    final color = _statusColor(context, complaint.statusLabel);

    return ListTile(
      onTap: () => AppRouter.router.push(
        ComplaintDetailPage.route.path,
        extra: complaint,
      ),
      contentPadding: const .symmetric(horizontal: 20, vertical: 4),
      leading: CircleAvatar(
        radius: 21,
        backgroundColor: context.avatarBg,
        child: Icon(
          Icons.forum_outlined,
          color: color,
          size: 20,
        ),
      ),
      title: Text(
        complaint.subject ?? complaint.category ?? 'Complaint',
        maxLines: 1,
        overflow: .ellipsis,
        style: context.p1,
      ),
      subtitle: Padding(
        padding: const .only(top: 4),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Text(
              DateUtil.format(complaint.date),
              style: context.smallDetails,
            ),
            if (complaint.lastMessage?.isNotEmpty ?? false) ...[
              const SizedBox(height: 2),
              Text(
                complaint.lastMessage!,
                maxLines: 1,
                overflow: .ellipsis,
                style: context.caption,
              ),
            ],
          ],
        ),
      ),
      trailing: Row(
        mainAxisSize: .min,
        children: [
          Column(
            mainAxisSize: .min,
            mainAxisAlignment: .center,
            crossAxisAlignment: .end,
            children: [
              if (complaint.reference?.isNotEmpty ?? false)
                Text(
                  complaint.reference!,
                  style: context.small,
                ),
              if (complaint.statusLabel?.isNotEmpty ?? false) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const .symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: .circular(6),
                  ),
                  child: Text(
                    complaint.statusLabel!,
                    style: context.smallBold.copyWith(color: color),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right_outlined),
        ],
      ),
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
              Icons.forum_outlined,
              size: 56,
              color: context.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No complaints yet',
              textAlign: .center,
              style: context.p1Medium,
            ),
            const SizedBox(height: 8),
            Text(
              'Raised complaints and their replies will appear here.',
              textAlign: .center,
              style: context.smallDetails,
            ),
          ],
        ),
      ),
    );
  }
}
