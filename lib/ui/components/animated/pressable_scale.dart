import 'package:flutter/material.dart';

/// Subtly scales [child] down while it's pressed and springs it back on
/// release — a barely-there tactile cue that a tap registered.
///
/// Uses a [Listener] rather than a [GestureDetector] so it observes raw
/// pointer events without competing with the child's own tap recognizer (e.g.
/// a button's InkWell), which a [GestureDetector] would fight over in the
/// gesture arena.
class PressableScale extends StatefulWidget {
  const PressableScale({
    super.key,
    required this.child,
    this.scale = 0.97,
    this.enabled = true,
  });

  final Widget child;

  /// Scale factor while pressed — default 0.97 keeps it subtle.
  final double scale;

  /// When false the child never scales (a disabled/loading button).
  final bool enabled;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    // Ignore presses on a disabled control, but always allow the release to
    // reset the scale back to rest.
    if (value && !widget.enabled) return;
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? widget.scale : 1,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
