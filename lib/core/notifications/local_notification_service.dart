import 'package:flutter_pulse_app/core/notifications/notification_tap_handler.dart';
import 'package:flutter_pulse_app/core/notifications/push_message.dart';

/// Renders notifications from Dart. FCM shows no banner while the app is in
/// the foreground, so foreground pushes are displayed through this service.
abstract interface class LocalNotificationService {
  /// Must complete before [show]. [onTap] runs when a shown notification is
  /// tapped.
  Future<void> init({required NotificationTapHandler onTap});

  Future<void> show(PushMessage message);
}
