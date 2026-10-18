import 'package:flutter_pulse_app/core/utils/entrance_tracker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('animates each id only once', () {
    final tracker = EntranceTracker();
    expect(tracker.shouldAnimate('a'), isTrue);
    expect(tracker.shouldAnimate('a'), isFalse);
    expect(tracker.shouldAnimate('b'), isTrue);
  });
}
