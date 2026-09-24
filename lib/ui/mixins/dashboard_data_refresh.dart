import 'package:flutter/material.dart';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/data/models/auth_data/auth_data.dart';
import 'package:bigpay/models/actions/refresh_dashboard_action.dart';
import 'package:bigpay/ui/components/process_builder.dart';
import 'package:bigpay/utils/app_state.util.dart';

/// Shared pull-to-refresh for pages that render the signed-in user's account
/// data — the dashboard and the services list. Re-fetches the full [AuthData]
/// via [RefreshDashboardAction], swaps it into [AppState.currentUser], and
/// rebuilds, so both pages stay a single source of that behaviour.
mixin DashboardDataRefresh<T extends StatefulWidget> on State<T> {
  /// The in-flight refresh, correlated by [dashboardRefreshListener].
  ExecuteProcessEvent? dashboardRefreshEvent;

  /// True from the moment a refresh is dispatched until its result (success
  /// or error) lands — pages reading straight off [AppState.currentUser]
  /// have no [ProcessBuilder] snapshot of their own to gate a loading state
  /// on, so this is what they check instead to swap to a skeleton while a
  /// pull-to-refresh is in flight, rather than leaving stale content up.
  bool dashboardRefreshing = false;

  /// Dispatches the refresh and completes once it lands, so a
  /// [RefreshIndicator] can hold its spinner until the fresh data arrives.
  Future<void> refreshDashboardData() async {
    final event = context.dispatchProcess(const RefreshDashboardAction());
    if (mounted) {
      setState(() {
        dashboardRefreshEvent = event;
        dashboardRefreshing = true;
      });
    }
    await context.awaitProcess(event);
  }

  /// Add to the page's listeners to apply the refreshed data when it arrives.
  ProcessListenerConfig<AuthData> get dashboardRefreshListener =>
      ProcessListenerConfig<AuthData>(
        event: () => dashboardRefreshEvent,
        listener: (context, snapshot) {
          if (snapshot.isLoading) return;
          if (snapshot.hasData) {
            setState(() {
              AppState.currentUser = snapshot.data;
              dashboardRefreshing = false;
            });
            return;
          }
          if (snapshot.hasError) {
            setState(() => dashboardRefreshing = false);
          }
        },
      );
}
