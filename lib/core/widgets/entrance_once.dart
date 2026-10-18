import 'package:flutter/widgets.dart';
import 'package:flutter_pulse_app/core/extensions/animate_extensions.dart';
import 'package:flutter_pulse_app/core/utils/entrance_tracker.dart';

/// Plays the staggered entrance for [child] only the first time its [id]
/// appears. The decision is taken once per element, so rebuilds mid-animation
/// don't cut it short, and re-created elements (scrolled back into view)
/// don't replay it. Give list items stable keys.
class EntranceOnce extends StatefulWidget {
  const EntranceOnce({
    required this.id,
    required this.tracker,
    required this.child,
    this.index = 0,
    super.key,
  });

  final Object id;
  final EntranceTracker tracker;
  final int index;
  final Widget child;

  @override
  State<EntranceOnce> createState() => _EntranceOnceState();
}

class _EntranceOnceState extends State<EntranceOnce> {
  late final bool _animate = widget.tracker.shouldAnimate(widget.id);

  @override
  Widget build(BuildContext context) {
    return _animate ? widget.child.entrance(index: widget.index) : widget.child;
  }
}
