import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pulse_app/core/app/app.dart';
import 'package:flutter_pulse_app/firebase_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// MUST be a top-level function (not a method) and annotated.
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Background isolate has no UI — keep this minimal. We rely on the system
  // tray notification (FCM payload's `notification` block) to be shown by Android.
  // No need to call flutter_local_notifications here unless you want custom UI.
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // onBackgroundMessage tells FCM → "when a message arrives and the app is in background/killed, call this function
  FirebaseMessaging.onBackgroundMessage(
    (message) => _firebaseBackgroundHandler(message),
  );
  runApp(ProviderScope(child: const MyApp()));
}

