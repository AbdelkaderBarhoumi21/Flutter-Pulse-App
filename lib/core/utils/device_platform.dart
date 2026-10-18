import 'package:flutter/foundation.dart';

/// Platform name in the format the backend expects
/// (`android` | `ios` | `web` | other lowercase name).
String devicePlatformName() {
  if (kIsWeb) return 'web';
  return switch (defaultTargetPlatform) {
    TargetPlatform.android => 'android',
    TargetPlatform.iOS => 'ios',
    final other => other.name.toLowerCase(),
  };
}
