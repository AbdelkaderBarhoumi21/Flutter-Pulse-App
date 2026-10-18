import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_pulse_app/core/utils/app_logger.dart';
import 'package:flutter_pulse_app/firebase_options.dart';

/// Runs in a separate background isolate when a push arrives while the app
/// is in the background or terminated. Must be a top-level function.
///
/// Android renders the tray notification itself from the payload's
/// `notification` block, so nothing else is needed here.
@pragma('vm:entry-point')
Future<void> firebaseBackgroundMessageHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

abstract final class FirebaseInitializer {
  /// Initializes Firebase and the background handler.
  ///
  /// Returns `false` (and the app keeps running without push) if Firebase
  /// isn't configured for this platform.
  static Future<bool> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      FirebaseMessaging.onBackgroundMessage(firebaseBackgroundMessageHandler);
      return true;
    } catch (e, st) {
      AppLogger.warning(
        'Firebase init failed — continuing without push',
        error: e,
        stackTrace: st,
      );
      return false;
    }
  }
}
