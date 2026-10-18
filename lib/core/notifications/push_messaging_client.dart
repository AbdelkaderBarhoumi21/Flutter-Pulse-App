import 'package:flutter_pulse_app/core/notifications/notification_payload.dart';
import 'package:flutter_pulse_app/core/notifications/push_message.dart';

/// Abstraction over the push provider (FCM today), so the notification flow
/// can be tested and the provider swapped without touching callers.
abstract interface class PushMessagingClient {
  Future<void> requestPermission();

  Future<String?> getToken();

  Stream<String> get onTokenRefresh;

  /// Messages that arrive while the app is open (no system banner shown).
  Stream<PushMessage> get onForegroundMessage;

  /// The user tapped a notification while the app was in the background.
  Stream<NotificationPayload> get onNotificationOpened;

  /// The notification that launched the app from a terminated state, if any.
  Future<NotificationPayload?> getInitialNotification();
}
