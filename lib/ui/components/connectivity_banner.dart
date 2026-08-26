import 'dart:async';

import 'package:flutter/material.dart';

import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/utils/connectivity.util.dart';

/// Monitors [ConnectivityUtil.isOnline] and shows an elegant, dismissible
/// notification card at the top of the screen on connectivity changes.
///
/// Drop into [MaterialApp.router.builder] wrapping the route [child].
class ConnectivityBanner extends StatefulWidget {
  const ConnectivityBanner({super.key, required this.child});

  final Widget child;

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner>
    with SingleTickerProviderStateMixin {
  static const _slideDuration = Duration(milliseconds: 320);
  static const _onlineAutoDismiss = Duration(seconds: 3);
  static const _cardMargin = EdgeInsets.fromLTRB(20, 0, 20, 0);

  late final AnimationController _slideCtrl;
  late final Animation<double> _slideAnim;

  bool _visible = false;
  bool _isOffline = false;
  late bool _prevOnline;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _prevOnline = ConnectivityUtil.isOnline.value;
    ConnectivityUtil.isOnline.addListener(_onChanged);

    _slideCtrl = AnimationController(vsync: this, duration: _slideDuration);
    _slideAnim = CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!ConnectivityUtil.isOnline.value) _showOffline();
    });
  }

  @override
  void dispose() {
    ConnectivityUtil.isOnline.removeListener(_onChanged);
    _dismissTimer?.cancel();
    _slideCtrl.dispose();
    super.dispose();
  }

  // ── Connectivity listener ──────────────────────────────────────────────

  void _onChanged() {
    if (!mounted) return;
    final online = ConnectivityUtil.isOnline.value;

    if (_prevOnline && !online) {
      _showOffline();
    } else if (!_prevOnline && online) {
      _showOnline();
    }
    _prevOnline = online;
  }

  // ── Show / hide ───────────────────────────────────────────────────────

  void _showOffline() {
    _dismissTimer?.cancel();
    setState(() {
      _isOffline = true;
      _visible = true;
    });
    _slideCtrl.forward(from: 0);
  }

  void _showOnline() {
    _dismissTimer?.cancel();
    setState(() {
      _isOffline = false;
      _visible = true;
    });
    _slideCtrl.forward(from: 0);
    _dismissTimer = Timer(_onlineAutoDismiss, _dismiss);
  }

  void _dismiss() {
    _dismissTimer?.cancel();
    _slideCtrl.reverse().then((_) {
      if (mounted) setState(() => _visible = false);
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,

        if (_visible)
          Positioned(
            top: MediaQuery.of(context).padding.top + 6,
            left: _cardMargin.left,
            right: _cardMargin.right,
            child: AnimatedBuilder(
              animation: _slideAnim,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -40 * (1 - _slideAnim.value)),
                  child: Opacity(
                    opacity: _slideAnim.value,
                    child: child,
                  ),
                );
              },
              child: _NotificationCard(
                isOffline: _isOffline,
                onDismiss: _dismiss,
              ),
            ),
          ),
      ],
    );
  }
}

// ── Notification card ────────────────────────────────────────────────────

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.isOffline, required this.onDismiss});

  final bool isOffline;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = isOffline ? AppColors.danger : AppColors.success;

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.all(Radius.circular(14)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Icon(
                isOffline ? Icons.wifi_off_rounded : Icons.wifi_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isOffline
                        ? l10n.connectivityLostTitle
                        : l10n.connectivityRestoredTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isOffline
                        ? l10n.connectivityLostMessage
                        : l10n.connectivityRestoredMessage,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDismiss,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
