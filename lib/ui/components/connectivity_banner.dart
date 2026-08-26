import 'dart:async';

import 'package:flutter/material.dart';

import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/utils/connectivity.util.dart';

/// Slides a coloured banner in from the top of the screen when connectivity
/// changes.  The offline banner stays until connectivity returns; the
/// "back online" banner auto-dismisses after 3 seconds.
///
/// Drop this into [MaterialApp.router.builder] as a wrapper around [child].
class ConnectivityBanner extends StatefulWidget {
  const ConnectivityBanner({super.key, required this.child});

  final Widget child;

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner> {
  static const _bannerHeight = 44.0;
  static const _slideDuration = Duration(milliseconds: 280);
  static const _onlineDismissDuration = Duration(seconds: 3);

  bool _showBanner = false;
  bool _isOffline = false;
  late bool _previousOnline;
  Timer? _autoDismissTimer;

  @override
  void initState() {
    super.initState();
    _previousOnline = ConnectivityUtil.isOnline.value;
    ConnectivityUtil.isOnline.addListener(_onConnectivityChanged);

    // Show immediately if the device is offline at launch.
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

  void _showOffline() {
    _autoDismissTimer?.cancel();
    setState(() {
      _showBanner = true;
      _isOffline = true;
    });
  }

  void _showOnline() {
    _autoDismissTimer?.cancel();
    setState(() {
      _showBanner = true;
      _isOffline = false;
    });
    _autoDismissTimer = Timer(_onlineDismissDuration, () {
      if (mounted) setState(() => _showBanner = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        widget.child,

        // Banner
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: AnimatedContainer(
            duration: _slideDuration,
            curve: Curves.easeInOut,
            height: _showBanner ? topPadding + _bannerHeight : 0,
            clipBehavior: Clip.hardEdge,
            color: Colors.transparent,
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                height: _bannerHeight,
                child: _isOffline ? const _OfflineBanner() : const _OnlineBanner(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Offline banner
// ---------------------------------------------------------------------------

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      width: double.infinity,
      color: AppColors.danger,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            AppLocalizations.of(context)!.connectivityLost,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Online banner
// ---------------------------------------------------------------------------

class _OnlineBanner extends StatelessWidget {
  const _OnlineBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      width: double.infinity,
      color: AppColors.success,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_rounded, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            AppLocalizations.of(context)!.connectivityRestored,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
