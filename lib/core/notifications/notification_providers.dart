import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_pulse_app/core/notifications/firebase_push_messaging_client.dart';
import 'package:flutter_pulse_app/core/notifications/flutter_local_notification_service.dart';
import 'package:flutter_pulse_app/core/notifications/local_notification_service.dart';
import 'package:flutter_pulse_app/core/notifications/push_messaging_client.dart';
import 'package:flutter_pulse_app/core/notifications/push_notification_service.dart';
import 'package:flutter_pulse_app/core/notifications/push_token_registrar.dart';
import 'package:flutter_pulse_app/core/utils/device_platform.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether Firebase initialized successfully. Overridden in `main()`.
final firebaseAvailableProvider = Provider<bool>((ref) => false);

final pushMessagingClientProvider = Provider<PushMessagingClient>(
  (ref) => FirebasePushMessagingClient(FirebaseMessaging.instance),
);

final localNotificationServiceProvider = Provider<LocalNotificationService>(
  (ref) => FlutterLocalNotificationService(),
);

/// Implemented by the `device` feature and bound in `main()`, so core never
/// imports a feature.
final pushTokenRegistrarProvider = Provider<PushTokenRegistrar>(
  (ref) => throw UnimplementedError(
    'pushTokenRegistrarProvider must be overridden in main()',
  ),
);

final pushNotificationServiceProvider = Provider<PushNotificationService>((
  ref,
) {
  final service = PushNotificationService(
    messaging: ref.watch(pushMessagingClientProvider),
    localNotifications: ref.watch(localNotificationServiceProvider),
    tokenRegistrar: ref.watch(pushTokenRegistrarProvider),
    platform: devicePlatformName(),
  );
  ref.onDispose(service.dispose);
  return service;
});
