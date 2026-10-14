import 'package:bigpay/ui/pages/history/history.pg.dart';
import 'package:go_router/go_router.dart';

import 'package:bigpay/data/models/general_flow/request_response.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/pages/history/transaction_details.pg.dart';

GoRoute get historyRoute => GoRoute(
  name: HistoryPage.route.name,
  path: HistoryPage.route.path,
  redirect: (context, state) => null,
  builder: (context, state) => HistoryPage(),
  routes: [
    TransactionDetailsPage.route.toGoRouteWithState(
      (state) => TransactionDetailsPage(
        receipt: state.extra as RequestResponse,
      ),
      nested: true,
      rootNavigator: true,
    ),
  ],
);
