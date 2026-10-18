import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_pulse_app/core/constants/app_strings.dart';
import 'package:flutter_pulse_app/core/notifications/notification_payload.dart';
import 'package:flutter_pulse_app/core/notifications/push_message.dart';
import 'package:flutter_pulse_app/core/notifications/push_messaging_client.dart';

/// [PushMessagingClient] backed by Firebase Cloud Messaging.
class FirebasePushMessagingClient implements PushMessagingClient {
  const FirebasePushMessagingClient(this._messaging);

  final FirebaseMessaging _messaging;

  @override
  Future<void> requestPermission() => _messaging.requestPermission();

  @override
  Future<String?> getToken() => _messaging.getToken();

  @override
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  @override
  Stream<PushMessage> get onForegroundMessage => FirebaseMessaging.onMessage
      .where((message) => message.notification != null)
      .map(
        (message) => PushMessage(
          title:
              message.notification?.title ??
              AppStrings.notificationFallbackTitle,
          body: message.notification?.body ?? '',
          payload: NotificationPayload.fromMap(message.data),
        ),
      );

  @override
  Stream<NotificationPayload> get onNotificationOpened => FirebaseMessaging
      .onMessageOpenedApp
      .map((message) => NotificationPayload.fromMap(message.data));

  @override
  Future<NotificationPayload?> getInitialNotification() async {
    final message = await _messaging.getInitialMessage();
    return message == null ? null : NotificationPayload.fromMap(message.data);
  }
}
