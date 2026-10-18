import 'package:flutter/widgets.dart';
import 'package:flutter_pulse_app/core/constants/app_curves.dart';
import 'package:flutter_pulse_app/core/constants/app_durations.dart';

/// Like [IndexedStack] (every tab keeps its state) but cross-fades between
/// tabs.
///
/// The fade lives *outside* each tab's [TickerMode]: a fade inside a
/// disabled ticker would never run, leaving a half-visible hidden tab.
/// Hidden tabs end fully transparent (not painted), ignore input, are
/// excluded from semantics and take no part in Hero flights.
class FadeIndexedStack extends StatelessWidget {
  const FadeIndexedStack({
    required this.index,
    required this.children,
    super.key,
  });

  final int index;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        for (var i = 0; i < children.length; i++)
          _FadingChild(active: i == index, child: children[i]),
      ],
    );
  }
}

class _FadingChild extends StatelessWidget {
  const _FadingChild({required this.active, required this.child});

  final bool active;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: active ? 1 : 0,
      duration: AppDurations.medium,
      curve: AppCurves.standard,
      child: IgnorePointer(
        ignoring: !active,
        child: ExcludeSemantics(
          excluding: !active,
          child: HeroMode(
            enabled: active,
            child: TickerMode(enabled: active, child: child),
          ),
        ),
      ),
    );
  }
}
