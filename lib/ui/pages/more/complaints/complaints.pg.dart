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

  Color _statusColor(String? status) {
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
        return AppColors.subtitleGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      bottomSize: 72,
      title: 'Complaints',
      bottomNav: FormButton(
        onPressed: () => AppRouter.router.push(FeedbackPage.route.path),
        text: 'New Complaint',
      ),
      child: ProcessConsumer<List<Complaint>>(
        event: () => _event,
        listener: (context, snapshot) {
          if (snapshot.hasData) {
            setState(() => _complaints = snapshot.data);
          }
        },
        builder: (context, snapshot) {
          if (_complaints == null && snapshot.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final complaints = _complaints ?? const [];
          if (complaints.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              for (final complaint in complaints) _buildCard(complaint),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCard(Complaint complaint) {
    return Padding(
      padding: const .only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: .circular(14),
        ),
        child: ListTile(
          contentPadding: const .symmetric(horizontal: 16, vertical: 6),
          onTap: () => AppRouter.router.push(
            ComplaintDetailPage.route.path,
            extra: complaint,
          ),
          title: Text(
            complaint.subject ?? complaint.category ?? 'Complaint',
            maxLines: 1,
            overflow: .ellipsis,
            style: AppTypography.header4,
          ),
          subtitle: Column(
            crossAxisAlignment: .start,
            children: [
              if (complaint.lastMessage?.isNotEmpty ?? false)
                Padding(
                  padding: const .only(top: 4),
                  child: Text(
                    complaint.lastMessage!,
                    maxLines: 1,
                    overflow: .ellipsis,
                    style: AppTypography.caption,
                  ),
                ),
              const SizedBox(height: 6),
              Row(
                children: [
                  if (complaint.statusLabel?.isNotEmpty ?? false) ...[
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _statusColor(complaint.statusLabel),
                        shape: .circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      complaint.statusLabel!,
                      style: AppTypography.caption.copyWith(
                        color: _statusColor(complaint.statusLabel),
                      ),
                    ),
                    const Spacer(),
                  ] else
                    const Spacer(),
                  if (complaint.date?.isNotEmpty ?? false)
                    Text(
                      complaint.date!,
                      style: AppTypography.caption,
                    ),
                ],
              ),
            ],
          ),
        ),
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
              color: AppColors.subtitleGrey,
            ),
            const SizedBox(height: 16),
            Text(
              'No complaints yet',
              textAlign: .center,
              style: AppTypography.p1Medium,
            ),
            const SizedBox(height: 8),
            Text(
              'Raised complaints and their replies will appear here.',
              textAlign: .center,
              style: AppTypography.smallDetails,
            ),
          ],
        ),
      ),
    );
  }
}
