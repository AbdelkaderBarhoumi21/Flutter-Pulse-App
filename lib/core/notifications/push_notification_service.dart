import 'dart:async';

import 'package:flutter_pulse_app/core/notifications/local_notification_service.dart';
import 'package:flutter_pulse_app/core/notifications/notification_tap_handler.dart';
import 'package:flutter_pulse_app/core/notifications/push_messaging_client.dart';
import 'package:flutter_pulse_app/core/notifications/push_token_registrar.dart';
import 'package:flutter_pulse_app/core/utils/app_logger.dart';

/// Orchestrates the push flow: permission, token registration, foreground
/// banners, and taps (background + cold start).
class PushNotificationService {
  PushNotificationService({
    required PushMessagingClient messaging,
    required LocalNotificationService localNotifications,
    required PushTokenRegistrar tokenRegistrar,
    required String platform,
  }) : _messaging = messaging,
       _localNotifications = localNotifications,
       _tokenRegistrar = tokenRegistrar,
       _platform = platform;

  final PushMessagingClient _messaging;
  final LocalNotificationService _localNotifications;
  final PushTokenRegistrar _tokenRegistrar;
  final String _platform;

  final List<StreamSubscription<Object?>> _subscriptions = [];
  bool _started = false;

  /// Safe to call more than once; only the first call does anything.
  /// Never throws — push is a nice-to-have and must not break the app.
  Future<void> start({required NotificationTapHandler onTap}) async {
    if (_started) return;
    _started = true;

    try {
      await _localNotifications.init(onTap: onTap);
      await _messaging.requestPermission();

      _subscriptions.addAll([
        _messaging.onTokenRefresh.listen(_registerToken),
        _messaging.onForegroundMessage.listen(_localNotifications.show),
        _messaging.onNotificationOpened.listen(onTap),
      ]);

      final token = await _messaging.getToken();
      if (token != null) await _registerToken(token);

      final initial = await _messaging.getInitialNotification();
      if (initial != null) onTap(initial);
    } catch (e, st) {
      AppLogger.warning(
        'Push notifications unavailable',
        error: e,
        stackTrace: st,
      );
    }
  }

  Future<void> dispose() async {
    await Future.wait(_subscriptions.map((s) => s.cancel()));
    _subscriptions.clear();
  }

  Future<void> _registerToken(String token) async {
    final result = await _tokenRegistrar.registerToken(
      token: token,
      platform: _platform,
    );
    result.fold(
      (failure) =>
          AppLogger.warning('Device registration failed: ${failure.message}'),
      (_) => AppLogger.info('Device registered for push notifications'),
    );
  }
}
