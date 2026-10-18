import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_pulse_app/core/constants/app_strings.dart';
import 'package:flutter_pulse_app/core/notifications/local_notification_service.dart';
import 'package:flutter_pulse_app/core/notifications/notification_payload.dart';
import 'package:flutter_pulse_app/core/notifications/notification_tap_handler.dart';
import 'package:flutter_pulse_app/core/notifications/push_message.dart';
import 'package:flutter_pulse_app/core/utils/app_logger.dart';

/// [LocalNotificationService] backed by `flutter_local_notifications`.
class FlutterLocalNotificationService implements LocalNotificationService {
  FlutterLocalNotificationService([FlutterLocalNotificationsPlugin? plugin])
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  /// The channel-id "rule of three": this id must be identical in
  ///   1. the backend payload (`android.notification.channel_id`),
  ///   2. AndroidManifest.xml (`default_notification_channel_id`),
  ///   3. this channel.
  /// Otherwise notifications land in a channel with the wrong importance.
  static const String _channelId = 'task_updates';

  /// res/drawable-*/ic_notification.png — white on transparent.
  static const String _icon = 'ic_notification';

  @override
  Future<void> init({required NotificationTapHandler onTap}) async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings(_icon),
      iOS: DarwinInitializationSettings(),
    );

    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) {
        final payload = _decode(response.payload);
        if (payload != null) onTap(payload);
      },
    );

    // Required since Android 8 (API 26): every notification needs a channel.
    // Resolves to null on iOS, so the call is skipped there.
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            AppStrings.notificationChannelName,
            description: AppStrings.notificationChannelDescription,
            importance: Importance.high,
          ),
        );
  }

  @override
  Future<void> show(PushMessage message) {
    return _plugin.show(
      // Unique per notification — reusing an id replaces the previous one.
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: message.title,
      body: message.body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          AppStrings.notificationChannelName,
          channelDescription: AppStrings.notificationChannelDescription,
          importance: Importance.max,
          priority: Priority.high,
          icon: _icon,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      // The plugin only carries a String, so the payload travels as JSON.
      payload: jsonEncode(message.payload.toMap()),
    );
  }

  NotificationPayload? _decode(String? raw) {
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return NotificationPayload.fromMap(map);
    } on FormatException catch (e) {
      AppLogger.warning('Ignoring malformed notification payload', error: e);
      return null;
    }
  }
}
