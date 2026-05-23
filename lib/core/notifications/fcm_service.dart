import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pulse_app/core/notifications/local_notification_service.dart';
import 'package:flutter_pulse_app/core/notifications/notification_payload.dart';
import 'package:flutter_pulse_app/core/utils/typedef/typedef.dart';
import 'package:flutter_pulse_app/features/device/data/datasources/device_remote_datasource.dart';

class FcmService {
  final FirebaseMessaging _messaging;
  final DeviceRemoteDataSource _deviceRemoteDataSource;
  final LocalNotificationService _localNotificationService;

  FcmService({
    required FirebaseMessaging messaging,
    required DeviceRemoteDataSource devices,
    required LocalNotificationService local,
  }) : _messaging = messaging,
       _deviceRemoteDataSource = devices,
       _localNotificationService = local;

  /// Call once after the app starts and the user is "ready" for push.
  Future<void> bootstrap({required NotificationTapHandler onTap}) async {
    // 1. Ask permission (iOS + Android 13+)
    await _messaging.requestPermission();

    // 2. Get the FCM token and register it on the backend.

    final token = await _messaging.getToken();
    if (token != null) {
      await _registerToken(token);
    }
    _messaging.onTokenRefresh.listen((token) => _registerToken(token));
    // 3. Foreground messages → render via local notifications.
    FirebaseMessaging.onMessage.listen((remoteMessage) {
      final n = remoteMessage.notification;
      if (n != null) {
        _localNotificationService.show(
          title: n.title ?? 'Update',
          body: n.body ?? '',
          payload: NotificationPayload.fromMap(remoteMessage.data),
        );
      }
    });
    // 4. Tap on a notification while app is in background and brought back.
    FirebaseMessaging.onMessageOpenedApp.listen((remoteMessage) {
      onTap(NotificationPayload.fromMap(remoteMessage.data));
    });

    // 5. App opened from a terminated state by tapping a push.
    final RemoteMessage? initial = await _messaging.getInitialMessage();
    if (initial != null) {
      onTap(NotificationPayload.fromMap(initial.data));
    }
    // onTap here = the router's callback (passed as a Bootstrap parameter)
    _localNotificationService.onTap = onTap;
  }

  Future<void> _registerToken(String token) async {
    try {
      final platform = Platform.isAndroid
          ? 'android'
          : Platform.isIOS
          ? 'ios'
          : 'web';
      await _deviceRemoteDataSource.register(token: token, platform: platform);
    } catch (e) {
      debugPrint('FCM token registration failed: $e');
    }
  }
}
