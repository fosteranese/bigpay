import 'package:bigpay/data/models/general_flow/general_flow_category.dart';
import 'package:bigpay/ui/pages/process_flow/service_form.pg.dart';
import 'package:go_router/go_router.dart';

import 'package:bigpay/data/models/auth_data/activity_datum.dart';
import 'package:bigpay/data/models/general_flow/request_response.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/pages/process_flow/done.pg.dart';
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
    ServiceFormPage.route.toGoRouteWithState(
      (state) {
        final payload = state.extra as Map<String, dynamic>;
        return ServiceFormPage(
          activityDatum: payload['activityDatum'],
          category: payload['category'],
          formData: payload['formData'],
        );
      },
      nested: true,
      rootNavigator: true,
    ),
    FeedbackPage.route.toGoRoute(
      () => const FeedbackPage(),
      nested: true,
      rootNavigator: true,
    ),
    SummaryPage.route.toGoRouteWithState(
      (state) {
        final payload = state.extra as Map<String, dynamic>?;
        return SummaryPage(
          verification: payload?['verification'],
          formData: payload?['formData'],
          activityDatum: payload?['activityDatum'],
          category: payload?['category'],
        );
      },
      nested: true,
      // Full-screen like the form and receipt — and consistent with them, so a
      // push from the (root-navigator) form doesn't collide page keys across
      // the shell branch and the root navigator.
      rootNavigator: true,
    ),
    DonePage.route.toGoRouteWithState(
      (state) => DonePage(receipt: state.extra as RequestResponse?),
      nested: true,
      rootNavigator: true,
    ),
  ],
);
