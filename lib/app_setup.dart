import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';

import 'package:bigpay/app.dart';
import 'package:bigpay/logger.dart';
import 'package:bigpay/utils/app.util.dart';

void bootstrap() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);

      // `init` populates CountryManager, which AppUtil.getInfo reads to resolve
      // the country list. Without it the list is empty.
      await init();

      // Device details ride on the `meta` of every backend request, so they
      // have to be resolved before the app — and its startup call — exists. A
      // failure here is logged rather than fatal: the app still starts and the
      // backend rejects the request, which surfaces as the app error page.
      try {
        await AppUtil.getInfo();
      } catch (ex, stack) {
        logger.e(
          'Failed to resolve device details',
          error: ex,
          stackTrace: stack,
        );
      }

      runApp(const BigPayApp());
    },
    (Object error, StackTrace stack) {
      logger.e(
        'Something went wrong!',
        error: error,
        stackTrace: stack,
      );
    },
  );
}
