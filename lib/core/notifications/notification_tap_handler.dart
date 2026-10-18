import 'package:flutter_pulse_app/core/notifications/notification_payload.dart';

/// Called when the user opens the app from a notification.
typedef NotificationTapHandler = void Function(NotificationPayload payload);
