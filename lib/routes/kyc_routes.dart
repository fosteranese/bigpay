import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/pages/kyc/contact-info-kyc.pg.dart';
import 'package:bigpay/ui/pages/kyc/ghana-card-kyc.pg.dart';
import 'package:bigpay/ui/pages/kyc/info-kyc.pg.dart';
import 'package:bigpay/ui/pages/kyc/intro-kyc.pg.dart';
import 'package:bigpay/ui/pages/kyc/personal-info-kyc.pg.dart';
import 'package:bigpay/ui/pages/kyc/preview-picture-kyc.pg.dart';
import 'package:bigpay/ui/pages/kyc/residential-info-kyc.pg.dart';
import 'package:bigpay/ui/pages/kyc/start-kyc.pg.dart';
import 'package:go_router/go_router.dart';

GoRoute get kycRoute => GoRoute(
  name: IntroKycPage.route.name,
  path: IntroKycPage.route.path,
  redirect: (context, state) => null,
  builder: (context, state) => IntroKycPage(),
  routes: [
    StartKycPage.route.toGoRoute(
      () => const StartKycPage(),
      nested: true,
    ),
    InfoKycPage.route.toGoRoute(
      () => const InfoKycPage(),
      nested: true,
    ),
    PicturePreviewKycPage.route.toGoRoute(
      () => const PicturePreviewKycPage(),
      nested: true,
    ),
    PersonalInfoKycPage.route.toGoRoute(
      () => const PersonalInfoKycPage(),
      nested: true,
    ),
    ResidentialInfoKycPage.route.toGoRoute(
      () => const ResidentialInfoKycPage(),
      nested: true,
    ),
    GhanaCardKycPage.route.toGoRoute(
      () => const GhanaCardKycPage(),
      nested: true,
    ),
    ContactInfoKycPage.route.toGoRoute(
      () => const ContactInfoKycPage(),
      nested: true,
    ),
  ],
);
