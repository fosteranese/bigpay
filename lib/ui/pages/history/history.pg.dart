import 'package:bigpay/ui/pages/history/transaction_details.pg.dart';
import 'package:flutter/material.dart';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/data/models/general_flow/history_response.dart';
import 'package:bigpay/data/models/general_flow/request_response.dart';
import 'package:bigpay/models/actions/history/get_history_action.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/forms.dart';
import 'package:bigpay/ui/components/history/history_transaction_item.dart';
import 'package:bigpay/ui/components/process_builder.dart';
import 'package:bigpay/ui/layouts/list.lo.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/ui/theme/foldable.dart';
import 'package:bigpay/utils/app_modal.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/history',
  );

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final _searchController = TextEditingController();

  /// The in-flight/last history request, correlated by [ProcessConsumer].
  ExecuteProcessEvent? _historyEvent;

  /// The last successful result, retained so a silent refresh doesn't blank
  /// the list while it runs.
  HistoryResponse? _source;

  String _query = '';

  /// The active filter's activity name, shown in the empty state and used to
  /// label the filter control. Empty means "all".
  String _filterName = '';

  /// The receipt shown in the detail pane in split view
  /// ([MasterDetailLayout]) — unused (and the pane not shown) on any other
  /// device, where opening a receipt pushes [TransactionDetailsPage] instead.
  RequestResponse? _selectedRecord;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(
      () => setState(() => _query = _searchController.text.trim()),
    );
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// (Re)loads the history — optionally filtered to [activityId] — through the
  /// cache-then-refresh path.
  void _load({String? activityId}) {
    setState(() {
      _historyEvent = context.dispatchProcess(
        GetHistoryAction(
          payload: GetHistoryActionPayload(activityId: activityId),
        ),
        returnSavedResponse: true,
        saveActionResponse: true,
      );
    });
  }

  /// The current list: the source transactions, narrowed by the search query
  /// against the service name.
  List<RequestResponse> get _filtered {
    final all = _source?.request ?? const [];
    if (_query.isEmpty) return all;
    final query = _query.toLowerCase();
    return all
        .where((e) => (e.formName ?? '').toLowerCase().contains(query))
        .toList();
  }

  void _openReceipt(RequestResponse record) {
    if (context.usesSplitView) {
      setState(() => _selectedRecord = record);
      return;
    }

    AppRouter.router.push(
      TransactionDetailsPage.route.path,
      extra: record,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasterDetailLayout(
      detail: _selectedRecord == null
          ? null
          : TransactionDetailsView(
              receipt: _selectedRecord!,
              onBack: () => setState(() => _selectedRecord = null),
            ),
      emptyDetail: const PaneEmptyState(
        icon: Icons.receipt_long_outlined,
        message: 'Select a transaction to view its receipt',
      ),
      master: _master(context),
    );
  }

  Widget _master(BuildContext context) {
    return ListLayout(
      appBarColor: context.cardBg,
      appBarBottomColor: 5,
      bodyColor: context.cardBg,
      miniTitle: 'Transactions',
      onRefresh: () async {
        _load();
        await context.awaitProcess(_historyEvent);
      },
      bottom: PreferredSize(
        preferredSize: Size(double.maxFinite, 70),
        child: Container(
          width: double.maxFinite,
          padding: .only(left: 20, right: 20, bottom: 15),
          child: Row(
            children: [
              Expanded(
                child: FormInput(
                  placeholder: 'Search',
                  controller: _searchController,
                  suffix: Icon(Icons.search),
                ),
              ),
              const SizedBox(width: 5),
              IconButton(
                tooltip: _filterName.isEmpty
                    ? 'Filter transactions'
                    : 'Filter: $_filterName',
                style: IconButton.styleFrom(
                  backgroundColor: context.cardBg,
                  fixedSize: Size(48, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: .circular(12),
                    side: .new(
                      color: _filterName.isEmpty
                          ? context.border
                          : AppColors.primary,
                    ),
                  ),
                ),
                onPressed: _onOpenFilter,
                icon: Icon(
                  Icons.filter_list_outlined,
                  color: _filterName.isEmpty
                      ? context.textPrimary
                      : AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
      child: (scrollController) => ProcessConsumer<HistoryResponse>(
        event: () => _historyEvent,
        listener: (context, snapshot) {
          if (snapshot.hasData) {
            setState(() => _source = snapshot.data);
          }
        },
        builder: (context, snapshot) {
          if (_source == null && snapshot.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = _filtered;
          if (items.isEmpty) {
            return _scrollWrap(scrollController, _buildEmptyState());
          }

          return ListView.separated(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: ClampingScrollPhysics(),
            ),
            padding: const .symmetric(vertical: 10),
            itemCount: items.length,
            separatorBuilder: (_, _) => Divider(
              height: 1,
              color: context.divider,
              indent: 20,
              endIndent: 20,
            ),
            itemBuilder: (context, index) {
              final record = items[index];
              return HistoryTransactionItem(
                record: record,
                onTap: (record.amount?.isNotEmpty ?? false)
                    ? () => _openReceipt(record)
                    : null,
              );
            },
          );
        },
      ),
    );
  }

  /// Wraps a non-scrolling widget (empty state) in a full-height scrollable so
  /// pull-to-refresh still works when there's nothing to scroll.
  Widget _scrollWrap(ScrollController controller, Widget child) {
    return ListView(
      controller: controller,
      physics: const AlwaysScrollableScrollPhysics(
        parent: ClampingScrollPhysics(),
      ),
      children: [
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.6, child: child),
      ],
    );
  }

  Widget _buildEmptyState() {
    final label = _query.isNotEmpty
        ? 'No transactions match "$_query"'
        : _filterName.isNotEmpty
        ? 'No $_filterName transactions found'
        : 'No transactions yet';

    return Center(
      child: Padding(
        padding: const .symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: .min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 56,
              color: context.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              label,
              textAlign: .center,
              style: context.p1Medium,
            ),
            const SizedBox(height: 8),
            Text(
              'Completed transactions will appear here.',
              textAlign: .center,
              style: context.smallDetails,
            ),
          ],
        ),
      ),
    );
  }

  void _onOpenFilter() {
    final activities = _source?.activity ?? const [];

    AppModal.showBottomModal(
      context,
      label: 'Filter by service',
      padding: .all(20),
      actions: [
        if (_filterName.isNotEmpty)
          TextButton(
            onPressed: () {
              AppRouter.router.pop();
              setState(() => _filterName = '');
              _load();
            },
            child: Text(
              'Clear Filter',
              style: context.formLabels.copyWith(
                decoration: .underline,
              ),
            ),
          ),
      ],
      children: [
        const SizedBox(height: 10),
        if (activities.isEmpty)
          Padding(
            padding: const .symmetric(vertical: 20),
            child: Text(
              'No services to filter by yet.',
              style: context.smallDetails,
            ),
          )
        else
          for (final activity in activities)
            ListTile(
              contentPadding: .zero,
              title: Text(
                activity.activityName ?? '',
                style: context.formLabels,
              ),
              trailing: _filterName == activity.activityName
                  ? Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                AppRouter.router.pop();
                setState(() => _filterName = activity.activityName ?? '');
                _load(activityId: activity.activityId);
              },
            ),
      ],
    );
  }
}
