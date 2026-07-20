import 'package:go_router/go_router.dart';

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
    ServicePage.route.toGoRoute(
      () => const ServicePage(),
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
