import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_pulse_app/core/notifications/notification_payload.dart';



/// Service that displays native notifications from Dart (foreground case).
/// FCM does NOT show a banner when the app is in foreground — we render it
/// here ourselves via flutter_local_notifications.
class LocalNotificationService {
  LocalNotificationService();

  // The plugin object that bridges Dart ↔ native APIs via MethodChannel.
  // Android → NotificationManager, iOS → UNUserNotificationCenter.
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // External tap handler — assigned by FcmService.bootstrap().
  // Nullable because notifications can fire before the router wires it up.
  void Function(NotificationPayload payload)? onTap;

  /// Phase 1 — initialize the plugin and create the Android channel.
  /// Must be called ONCE from main.dart before runApp().
  Future<void> init() async {
    // ── Per-platform init settings ──────────────────────────────────────
    // Android: default small icon used in the status bar for local notifications.
    // 'ic_notification_local' refers to res/drawable-*/ic_notification_local.png
    const android = AndroidInitializationSettings('ic_notification_local');

    // iOS/macOS: default permissions (alert + badge + sound = true).
    const ios = DarwinInitializationSettings();

    // Container that bundles both — the plugin reads only the field
    // matching the current OS at runtime.
    const settings = InitializationSettings(android: android, iOS: ios);

    // ── Initialize the plugin + register tap callback ───────────────────
    await _plugin.initialize(
      settings: settings,
      // Called by the native side when the user taps a local notification.
      onDidReceiveNotificationResponse: (response) {
        // No payload attached → nothing to navigate to, exit early.
        if (response.payload == null) return;

        // Payload is stored as a JSON string (plugin only accepts String?),
        // so we decode it back into a typed NotificationPayload.
        final map = jsonDecode(response.payload!) as Map<String, dynamic>;
        final payload = NotificationPayload.fromMap(map);

        // Delegate to whoever wired themselves up (the router via FcmService).
        // `?.call(...)` = safe call; does nothing if onTap is still null.
        onTap?.call(payload);
      },
    );

    // ── Create the Android notification channel ─────────────────────────
    // Required since Android 8 (API 26): every notification MUST belong to a channel.
    // The id 'task_updates' is the "channel-id rule of three":
    //   1. Rust backend payload (android.notification.channel_id)
    //   2. AndroidManifest.xml (default_notification_channel_id)
    //   3. This createNotificationChannel call
    // All three must be EXACTLY 'task_updates' or notifications end up in the wrong
    // channel (different sound / importance / user settings).
    const channel = AndroidNotificationChannel(
      'task_updates',
      'Task Updates',
      description: 'Notifications about task changes',
      importance: Importance.high, // heads-up banner + sound
    );

    // Channel creation is Android-only → resolve the Android-specific impl
    // and call it. On iOS this returns null and `?.` skips the call.
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  /// Phase 2 — actually display a notification (called by FcmService.onMessage).
  Future<void> show({
    required String title,
    required String body,
    required NotificationPayload payload,
  }) async {
    // ── Android-specific render details ─────────────────────────────────
    const androidDetails = AndroidNotificationDetails(
      'task_updates', // MUST match the channel id created in init()
      'Task Updates',
      channelDescription: 'Notifications about task changes',
      importance: Importance.max, // strongest priority for heads-up
      priority: Priority.high, // legacy pre-API 26 priority hint
      icon: 'ic_notification_local', // small white-on-transparent icon
    );

    // ── iOS-specific render details (defaults are fine here) ────────────
    const iosDetails = DarwinNotificationDetails();

    // ── Fire the notification ───────────────────────────────────────────
    await _plugin.show(
      // Unique id per notification → timestamp guarantees no collision.
      // Reusing an id REPLACES the previous notification of the same id.
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      // Payload travels with the notification and survives an app kill.
      // The plugin only accepts a String, so we serialize as JSON.
      // It will be decoded back inside onDidReceiveNotificationResponse above.
      payload: jsonEncode({
        'type': payload.type,
        'taskId': payload.taskId,
        'route': payload.route,
      }),
    );
  }
}
