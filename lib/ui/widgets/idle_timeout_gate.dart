import 'dart:async';

import 'package:flutter/material.dart';

import 'package:bigpay/env/env.dart';
import 'package:bigpay/models/actions/action.dart';
import 'package:bigpay/models/actions/logout_action.dart';
import 'package:bigpay/ui/components/process_builder.dart';
import 'package:bigpay/utils/app_state.util.dart';

/// Auto-signs-out an idle user.
///
/// After [Env.idleTimeoutMinutes] of no interaction — taps, scrolling, or
/// typing-triggering touches anywhere in the app — the user is signed out by
/// dispatching the same [LogoutAction] the in-app Sign Out button uses
/// (`/UserAccess/Logout`, local-only; the app-wide [LogoutAction] listener
/// then navigates back to the unlock screen).
///
/// Behavior:
/// * Duration comes from `IDLE_TIMEOUT_MINUTES` in the environment (default 3
///   minutes in `.env`); a configured value of `0` disables the timeout.
/// * Only counts while a user is signed in ([AppState.currentUser] != null)
///   and the app is in the foreground (`AppLifecycleState.resumed`).
/// * Backgrounding pauses the countdown; returning to the foreground resets
///   it (a fresh session). Every pointer event resets it too.
class IdleTimeoutGate extends StatefulWidget {
  const IdleTimeoutGate({super.key, required this.child});

  final Widget child;

  @override
  State<IdleTimeoutGate> createState() => _IdleTimeoutGateState();
}

class _IdleTimeoutGateState extends State<IdleTimeoutGate>
    with WidgetsBindingObserver {
  static const _tickDuration = Duration(seconds: 1);

  final int _timeoutSeconds = Env.idleTimeoutMinutes * 60;
  Timer? _timer;
  int _remaining = 0;
  bool _signedIn = false;
  bool _loggedOut = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _remaining = _timeoutSeconds;
    if (_timeoutSeconds > 0) {
      _timer = Timer.periodic(_tickDuration, (_) => _onTick());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Returning to the foreground starts a fresh idle window. The countdown
    // itself only advances while the app is resumed (see [_tick]), so
    // background time never counts towards the timeout.
    if (state == AppLifecycleState.resumed) {
      _remaining = _timeoutSeconds;
    }
  }

  void _reset() {
    _remaining = _timeoutSeconds;
  }

  void _onTick() {
    if (!mounted) return;
    final signedIn = AppState.currentUser != null;
    if (signedIn != _signedIn) {
      _signedIn = signedIn;
      if (signedIn) _loggedOut = false;
    }

    // Not signed in, no timeout configured, or not the foreground app:
    // hold the window open rather than counting down.
    if (!_signedIn ||
        _timeoutSeconds <= 0 ||
        WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      _remaining = _timeoutSeconds;
      return;
    }

    if (_remaining <= 1) {
      if (!_loggedOut) {
        _loggedOut = true;
        _logout();
      }
      return;
    }
    _remaining--;
  }

  void _logout() {
    if (!mounted) return;
    // Same path as More -> Sign Out; the app-wide LogoutAction listener
    // navigates back to the unlock screen.
    context.dispatchProcess(
      LogoutAction(payload: NoPayload()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _reset(),
      onPointerUp: (_) => _reset(),
      onPointerMove: (_) => _reset(),
      onPointerSignal: (_) => _reset(),
      child: widget.child,
    );
  }
}
