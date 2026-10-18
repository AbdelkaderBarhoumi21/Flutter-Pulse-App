import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_pulse_app/core/constants/app_curves.dart';
import 'package:flutter_pulse_app/core/constants/app_durations.dart';

/// Press-to-shrink feedback for any tappable surface.
///
/// Listens to raw pointer events, so it never competes with the child's own
/// gesture handling (InkWell, buttons). Moving past the touch slop — i.e.
/// starting to scroll — releases the press.
class PressableScale extends StatefulWidget {
  const PressableScale({
    required this.child,
    this.enabled = true,
    this.pressedScale = 0.97,
    super.key,
  });

  final Widget child;
  final bool enabled;
  final double pressedScale;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  Offset? _downPosition;
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  void _onDown(PointerDownEvent event) {
    _downPosition = event.position;
    _setPressed(true);
  }

  void _onMove(PointerMoveEvent event) {
    final start = _downPosition;
    if (start != null && (event.position - start).distance > kTouchSlop) {
      _release();
    }
  }

  void _release() {
    _downPosition = null;
    _setPressed(false);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: widget.enabled ? _onDown : null,
      onPointerMove: widget.enabled ? _onMove : null,
      onPointerUp: (_) => _release(),
      onPointerCancel: (_) => _release(),
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1,
        duration: AppDurations.fast,
        curve: AppCurves.standard,
        child: widget.child,
      ),
    );
  }
}
