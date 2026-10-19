import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/pages/kyc/contact-info-kyc.pg.dart';
import 'package:bigpay/ui/pages/kyc/face-capture-kyc.pg.dart';
import 'package:bigpay/ui/pages/kyc/info-kyc.pg.dart';
import 'package:bigpay/ui/pages/kyc/intro-kyc.pg.dart';
import 'package:bigpay/ui/pages/kyc/preview-picture-kyc.pg.dart';
import 'package:bigpay/ui/pages/kyc/start-kyc.pg.dart';
import 'package:flutter/cupertino.dart' show CupertinoPage;
import 'package:go_router/go_router.dart';

GoRoute get kycRoute => GoRoute(
  name: IntroKycPage.route.name,
  path: IntroKycPage.route.path,
  redirect: (context, state) => null,
  // CupertinoPage (see app_router.dart) so the KYC intro also gets the iOS
  // back-swipe gesture.
  pageBuilder: (context, state) => CupertinoPage(
    key: state.pageKey,
    name: state.name ?? state.path,
    arguments: <String, String>{
      ...state.pathParameters,
      ...state.uri.queryParameters,
    },
    restorationId: state.pageKey.value,
    child: const IntroKycPage(),
  ),
  routes: [
    StartKycPage.route.toGoRoute(
      () => const StartKycPage(),
      nested: true,
    ),
    InfoKycPage.route.toGoRoute(
      () => const InfoKycPage(),
      nested: true,
    ),
    FaceCaptureKycPage.route.toGoRoute(
      () => const FaceCaptureKycPage(),
      nested: true,
    ),
    PicturePreviewKycPage.route.toGoRoute(
      () => const PicturePreviewKycPage(),
      nested: true,
    ),
    ContactInfoKycPage.route.toGoRoute(
      () => const ContactInfoKycPage(),
      nested: true,
    ),
  ],
);
