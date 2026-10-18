import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Current time source. Override it in tests for deterministic timestamps.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);
