import 'package:bigpay/data/models/general_flow/general_flow_category.dart';
import 'package:go_router/go_router.dart';

import 'package:bigpay/data/models/auth_data/activity_datum.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/pages/process_flow/feedback.pg.dart';
import 'package:bigpay/ui/pages/process_flow/service.pg.dart';
import 'package:bigpay/ui/pages/process_flow/services.pg.dart';
import 'package:bigpay/ui/pages/process_flow/summary.pg.dart';

GoRoute get processFlowRoute => GoRoute(
  name: ServicesPage.route.name,
  path: ServicesPage.route.path,
  redirect: (context, state) => null,
  builder: (context, state) => ServicesPage(),
  routes: [
    ServicePage.route.toGoRouteWithState(
      (state) {
        final payload = state.extra as Map<String, dynamic>;
        return ServicePage(
          activityDatum: payload['activityDatum'] as ActivityDatum,
          category: payload['category'] as GeneralFlowCategory,
        );
      },
      nested: true,
    ),
    FeedbackPage.route.toGoRoute(
      () => const FeedbackPage(),
      nested: true,
    ),
    SummaryPage.route.toGoRoute(
      () => const SummaryPage(),
      nested: true,
    ),
  ],
);
