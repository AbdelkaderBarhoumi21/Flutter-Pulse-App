/// Remembers which items already played their entrance animation, so items
/// that scroll back into view (or rebuild) never animate twice.
class EntranceTracker {
  final Set<Object> _seen = {};

  /// `true` the first time [id] is seen, `false` afterwards.
  bool shouldAnimate(Object id) => _seen.add(id);
}
