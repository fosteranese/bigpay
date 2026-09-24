import 'package:flutter/material.dart';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/data/models/complaint/complaint.dart';
import 'package:bigpay/data/models/complaint/complaint_category.dart';
import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/models/actions/complaints/get_complaint_categories_action.dart';
import 'package:bigpay/models/actions/complaints/get_my_complaints_action.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/complaints/complaint_status.dart';
import 'package:bigpay/ui/components/empty_state.dart';
import 'package:bigpay/ui/components/forms/forms.dart';
import 'package:bigpay/ui/components/process_builder.dart';
import 'package:bigpay/ui/components/skeleton/variants.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/pages/more/complaints/complaint_detail.pg.dart';
import 'package:bigpay/ui/pages/process_flow/feedback.pg.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/ui/theme/foldable.dart';
import 'package:bigpay/ui/theme/responsive.dart';
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
  ExecuteProcessEvent? _categoriesEvent;
  List<Complaint>? _complaints;
  List<ComplaintCategory> _categories = const [];
  final _searchController = TextEditingController();
  String _query = '';

  /// Status filter chip selection; null shows every complaint.
  ComplaintStage? _stage;

  /// The complaint shown in the detail pane in split view
  /// ([MasterDetailLayout]) — unused (and the pane not shown) on any other
  /// device, where opening a complaint pushes [ComplaintDetailPage] instead.
  Complaint? _selectedComplaint;

  void _openDetails(Complaint complaint) {
    if (context.usesSplitView) {
      setState(() => _selectedComplaint = complaint);
      return;
    }

    AppRouter.router.push(
      ComplaintDetailPage.route.path,
      extra: complaint,
    );
  }

  void _closeDetails() {
    setState(() => _selectedComplaint = null);
    _load();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(
      () => setState(() => _query = _searchController.text.trim()),
    );
    _load();
    _categoriesEvent = context.dispatchProcess(
      const GetComplaintCategoriesAction(),
      returnSavedResponse: true,
      saveActionResponse: true,
    );
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
    _searchController.dispose();
    super.dispose();
  }

  void _load() {
    _event = context.dispatchProcess(
      const GetMyComplaintsAction(),
      returnSavedResponse: true,
      saveActionResponse: true,
    );
  }

  /// The list actually shown — [_complaints] narrowed by [_query] against
  /// everything visible on a row (subject, category, reference, status, and
  /// the last-message preview), so search matches what the user can see.
  List<Complaint> get _filtered {
    final all = (_complaints ?? const <Complaint>[])
        .where((c) => _stage == null || complaintStage(c.statusLabel) == _stage)
        .toList();
    if (_query.isEmpty) return all;
    final query = _query.toLowerCase();
    return all.where((c) {
      return (c.subject ?? '').toLowerCase().contains(query) ||
          (c.category ?? '').toLowerCase().contains(query) ||
          (c.reference ?? '').toLowerCase().contains(query) ||
          (c.statusLabel ?? '').toLowerCase().contains(query) ||
          (c.lastMessage ?? '').toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ProcessListener<List<ComplaintCategory>>(
      event: () => _categoriesEvent,
      listener: (context, snapshot) {
        if (snapshot.hasData) {
          setState(() => _categories = snapshot.data ?? const []);
        }
      },
      child: MasterDetailLayout(
        detail: _selectedComplaint == null
            ? null
            : ComplaintDetailView(
                // Without a key, switching the selection in the master list
                // reuses the same State instead of creating a new one — its
                // initState (and the fetch it kicks off) never re-runs, so
                // the pane keeps showing the previous complaint's messages.
                key: ValueKey(_selectedComplaint!.id),
                complaint: _selectedComplaint,
                onBack: _closeDetails,
              ),
        master: _master(context),
      ),
    );
  }

  Widget _master(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return MainLayout(
      title: l10n.complaintsTitle,
      onRefresh: () async {
        _load();
        await context.awaitProcess(_event);
      },
      // MainLayout's header reserves a fixed height for bottom/subtitleWidget
      // — it doesn't measure it — so this has to be sized by hand for
      // whatever's actually in there. Matches beneficiaries.pg.dart's own
      // bottomSize, which has the identical title+actions+search layout.
      bottomSize: 129,
      actions: SizedBox(
        width: 110,
        child: FormButton(
          height: 44,
          labelSize: 13,
          onPressed: () => AppRouter.router.push(FeedbackPage.route.path),
          text: l10n.commonAddNew,
          icon: Icons.add,
          buttonIconAlignment: .left,
          iconSize: 16,
        ),
      ),
      subtitleWidget: Container(
        padding: .only(top: 20),
        child: FormInput(
          placeholder: l10n.commonSearch,
          controller: _searchController,
          suffix: const Icon(Icons.search),
          textInputAction: .search,
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
          if (snapshot.isLoading) {
            return SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                mainAxisSize: .min,
                children: List.generate(
                  6,
                  (_) => const ListItemSkeleton(),
                ),
              ),
            );
          }

          final complaints = _filtered;
          // Filters only make sense once there's something to filter.
          final showFilters = _complaints?.isNotEmpty ?? false;
          final Widget content;
          if (complaints.isEmpty) {
            content = SliverFillRemaining(
              hasScrollBody: false,
              child: (_query.isNotEmpty || _stage != null)
                  ? EmptyState(
                      icon: Icons.search_off_outlined,
                      title: l10n.commonNoMatches,
                    )
                  : EmptyState(
                      icon: Icons.forum_outlined,
                      title: l10n.complaintsEmptyTitle,
                      subtitle: l10n.complaintsEmptySubtitle,
                    ),
            );
          } else {
            // No divider lines between rows — each row's own padding plus
            // the avatar's status dot is enough separation, and reads as a
            // cleaner, less cluttered inbox than a hairline under every item.
            content = SliverPadding(
              padding: const .symmetric(vertical: 6),
              sliver: SliverList.builder(
                itemCount: complaints.length,
                itemBuilder: (context, index) => _buildItem(complaints[index]),
              ),
            );
          }

          if (!showFilters) return content;
          return SliverMainAxisGroup(
            slivers: [
              SliverToBoxAdapter(child: _buildFilters(l10n)),
              content,
            ],
          );
        },
      ),
    );
  }

  static final _uuid = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  /// [Complaint.category] is meant to be a human-readable label, but some
  /// complaints only ever get a raw category id in that field — resolved
  /// against the fetched category list so the id still shows as a real
  /// name (same resolution [ComplaintDetailView] does on the detail page).
  String? _categoryLabel(Complaint complaint) {
    final category = complaint.category;
    if (category == null || category.isEmpty) return null;
    if (!_uuid.hasMatch(category)) return category;

    final resolved = _categories
        .where((c) => c.id == category)
        .map((c) => c.name)
        .firstOrNull;
    return (resolved?.isNotEmpty ?? false) ? resolved : null;
  }

  Widget _buildFilters(AppLocalizations l10n) {
    final options = <(ComplaintStage?, String)>[
      (null, l10n.complaintsFilterAll),
      (ComplaintStage.open, l10n.complaintsFilterOpen),
      (ComplaintStage.resolved, l10n.complaintsFilterResolved),
    ];
    return Padding(
      // Lines the chips up with the row content below (row inset + padding).
      padding: const .fromLTRB(Spacing.xxl, Spacing.sm, Spacing.xxl, 0),
      child: Wrap(
        spacing: Spacing.sm,
        runSpacing: Spacing.sm,
        children: [
          for (final (stage, label) in options)
            ChoiceChip(
              label: Text(label),
              selected: _stage == stage,
              showCheckmark: false,
              onSelected: (_) => setState(() => _stage = stage),
              shape: const StadiumBorder(),
              side: BorderSide(
                color: _stage == stage ? AppColors.primary : context.border,
              ),
              selectedColor: AppColors.primary.withValues(alpha: 0.12),
              backgroundColor: Colors.transparent,
              labelStyle: context.smallDetailsMedium.copyWith(
                color: _stage == stage
                    ? context.textPrimary
                    : context.textSecondary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildItem(Complaint complaint) {
    final l10n = AppLocalizations.of(context)!;
    final color = complaintStatusColor(context, complaint.statusLabel);
    final isOpen = context.usesSplitView && complaint == _selectedComplaint;
    // A touch bigger on a wide/desktop-class window — rows have the room and
    // the extra presence matches a full inbox layout better than a
    // phone-sized avatar floating in a much wider row.
    final avatarRadius = context.responsive<double>(
      compact: 22,
      expanded: 26,
    );
    final categoryLabel = _categoryLabel(complaint);

    return Padding(
      padding: const .symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: .circular(14),
        child: InkWell(
          onTap: () => _openDetails(complaint),
          borderRadius: .circular(14),
          child: Container(
            padding: const .symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isOpen
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : Colors.transparent,
              borderRadius: .circular(14),
            ),
            child: Row(
              crossAxisAlignment: .center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: avatarRadius,
                      backgroundColor: context.avatarBg,
                      child: Icon(
                        Icons.forum_outlined,
                        color: context.accentGreen,
                        size: avatarRadius - 2,
                      ),
                    ),
                    if (complaint.statusLabel?.isNotEmpty ?? false)
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: Container(
                          width: 15,
                          height: 15,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: context.cardBg,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Row(
                        // .start (the default) top-aligns text regardless of
                        // font size — since the timestamp's font is much
                        // smaller than the title's, that left it visibly
                        // higher than the title's own baseline instead of
                        // sitting level with it.
                        crossAxisAlignment: .center,
                        children: [
                          Expanded(
                            child: Text(
                              complaint.subject ??
                                  categoryLabel ??
                                  l10n.complaintsFallbackTitle,
                              maxLines: 1,
                              overflow: .ellipsis,
                              style: context.p1Medium,
                            ),
                          ),
                          if (complaint.date?.isNotEmpty ?? false) ...[
                            const SizedBox(width: Spacing.sm),
                            Text(
                              DateUtil.relative(complaint.date),
                              style: context.small,
                            ),
                          ],
                        ],
                      ),
                      // Skipped when there's no subject — categoryLabel is
                      // already standing in as the title itself then, and
                      // showing it a second time right below would just
                      // repeat the same text.
                      if (categoryLabel != null &&
                          (complaint.subject?.isNotEmpty ?? false)) ...[
                        const SizedBox(height: 2),
                        Text(
                          categoryLabel,
                          maxLines: 1,
                          overflow: .ellipsis,
                          style: context.caption.copyWith(
                            color: context.accentGreen,
                          ),
                        ),
                      ],
                      const SizedBox(height: 3),
                      Row(
                        crossAxisAlignment: .center,
                        children: [
                          Expanded(
                            child: Text(
                              (complaint.lastMessage?.isNotEmpty ?? false)
                                  ? complaint.lastMessage!
                                  : (complaint.reference ?? ''),
                              maxLines: 1,
                              overflow: .ellipsis,
                              style: context.caption,
                            ),
                          ),
                          if (complaint.statusLabel?.isNotEmpty ?? false) ...[
                            const SizedBox(width: Spacing.sm),
                            ComplaintStatusChip(status: complaint.statusLabel!),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
