import 'dart:async';

import 'package:flutter/material.dart';

import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/utils/connectivity.util.dart';

/// Listens to [ConnectivityUtil.isOnline] and shows professional SnackBar
/// alerts on connectivity changes.  Renders [child] unchanged.
///
/// Place inside a [ScaffoldMessenger]-aware subtree (e.g. [MaterialApp]).
class ConnectivityBanner extends StatefulWidget {
  const ConnectivityBanner({super.key, required this.child});

  final Widget child;

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner> {
  static const _onlineDismissDuration = Duration(seconds: 3);
  static const _shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
  );

  late bool _previousOnline;
  Timer? _autoDismissTimer;

  @override
  void initState() {
    super.initState();
    _previousOnline = ConnectivityUtil.isOnline.value;
    ConnectivityUtil.isOnline.addListener(_onConnectivityChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!ConnectivityUtil.isOnline.value) _showOffline();
    });
  }

  @override
  void dispose() {
    ConnectivityUtil.isOnline.removeListener(_onConnectivityChanged);
    _autoDismissTimer?.cancel();
    super.dispose();
  }

  void _onConnectivityChanged() {
    if (!mounted) return;
    final online = ConnectivityUtil.isOnline.value;

    if (_previousOnline && !online) {
      _showOffline();
    } else if (!_previousOnline && online) {
      _showOnline();
    }
    _previousOnline = online;
  }

  // ── Offline ──────────────────────────────────────────────────────────────

  void _showOffline() {
    _autoDismissTimer?.cancel();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(_offlineSnackBar());
  }

  SnackBar _offlineSnackBar() {
    final l10n = AppLocalizations.of(context)!;
    return SnackBar(
      content: Row(
        children: [
          const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.connectivityLost,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.danger,
      behavior: SnackBarBehavior.floating,
      shape: _shape,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      duration: const Duration(days: 1), // stays until we dismiss it
    );
  }

  // ── Online ───────────────────────────────────────────────────────────────

  void _showOnline() {
    _autoDismissTimer?.cancel();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(_onlineSnackBar());

    _autoDismissTimer = Timer(_onlineDismissDuration, () {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
    });
  }

  SnackBar _onlineSnackBar() {
    final l10n = AppLocalizations.of(context)!;
    return SnackBar(
      content: Row(
        children: [
          const Icon(Icons.wifi_rounded, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.connectivityRestored,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: _shape,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      duration: _onlineDismissDuration,
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) => widget.child;
}
