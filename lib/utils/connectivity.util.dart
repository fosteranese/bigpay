import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import 'package:bigpay/logger.dart';

class ConnectivityUtil {
  ConnectivityUtil._();

  static final Connectivity _connectivity = Connectivity();
  static StreamSubscription<List<ConnectivityResult>>? _subscription;
  static bool _initialized = false;

  /// Current online status — true when at least one network interface is
  /// available (WiFi or mobile). Updated reactively by the stream listener.
  static final isOnline = ValueNotifier<bool>(true);

  /// Reads the initial connectivity state and starts listening for changes.
  /// Safe to call multiple times; only the first call takes effect.
  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    try {
      final results = await _connectivity.checkConnectivity();
      isOnline.value = results.any((r) => r != ConnectivityResult.none);
    } catch (e) {
      logger.e('ConnectivityUtil.init error: $e');
    }

    _subscription = _connectivity.onConnectivityChanged.listen(
      (results) {
        isOnline.value = results.any((r) => r != ConnectivityResult.none);
      },
      onError: (e) => logger.e('ConnectivityUtil stream error: $e'),
    );
  }

  /// Cancels the stream subscription. Call on app teardown (rare).
  static void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _initialized = false;
  }
}
