import 'package:equatable/equatable.dart';
import 'package:flutter_pulse_app/core/notifications/notification_payload.dart';

/// A push received while the app is in the foreground.
class PushMessage extends Equatable {
  const PushMessage({
    required this.title,
    required this.body,
    required this.payload,
  });

  final String title;
  final String body;
  final NotificationPayload payload;

  @override
  List<Object?> get props => [title, body, payload];
}
