import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'package:bigpay/app.dart';
import 'package:bigpay/data/database/db.dart';
import 'package:bigpay/logger.dart';
import 'package:bigpay/utils/app.util.dart';
import 'package:bigpay/utils/app_state.util.dart';

void bootstrap() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);

      await Hive.initFlutter();
      await Database.init();
      await AppState.loadTheme();
      await AppState.loadLocale();

      await init();

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
