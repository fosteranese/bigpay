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

  /// Dispatches the refresh and completes once it lands, so a
  /// [RefreshIndicator] can hold its spinner until the fresh data arrives.
  Future<void> refreshDashboardData() async {
    final event = context.dispatchProcess(const RefreshDashboardAction());
    if (mounted) setState(() => dashboardRefreshEvent = event);
    await context.awaitProcess(event);
  }

  /// Add to the page's listeners to apply the refreshed data when it arrives.
  ProcessListenerConfig<AuthData> get dashboardRefreshListener =>
      ProcessListenerConfig<AuthData>(
        event: () => dashboardRefreshEvent,
        listener: (context, snapshot) {
          if (snapshot.hasData) {
            setState(() => AppState.currentUser = snapshot.data);
          }
        },
      );
}
