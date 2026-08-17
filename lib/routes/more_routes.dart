import 'package:go_router/go_router.dart';

import 'package:bigpay/data/models/complaint/complaint.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/pages/more/complaints/complaint_detail.pg.dart';
import 'package:bigpay/ui/pages/more/complaints/complaints.pg.dart';
import 'package:bigpay/ui/pages/more/more.pg.dart';
import 'package:bigpay/ui/pages/more/profile.pg.dart';
import 'package:bigpay/ui/pages/more/security.pg.dart';

GoRoute get moreRoute => GoRoute(
  name: MorePage.route.name,
  path: MorePage.route.path,
  redirect: (context, state) => null,
  builder: (context, state) => MorePage(),
  routes: [
    ProfilePage.route.toGoRoute(
      () => const ProfilePage(),
      nested: true,
      rootNavigator: true,
    ),
    SecurityPage.route.toGoRoute(
      () => const SecurityPage(),
      nested: true,
      rootNavigator: true,
    ),
    ComplaintsPage.route.toGoRoute(
      () => const ComplaintsPage(),
      nested: true,
      rootNavigator: true,
    ),
    ComplaintDetailPage.route.toGoRouteWithState(
      (state) => ComplaintDetailPage(
        complaint: state.extra as Complaint?,
      ),
      nested: true,
      rootNavigator: true,
    ),
  ],
);
