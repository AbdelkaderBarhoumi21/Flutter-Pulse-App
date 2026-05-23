import 'package:flutter_pulse_app/core/di/services_provider.dart';
import 'package:flutter_pulse_app/core/notifications/fcm_service.dart';
import 'package:flutter_pulse_app/core/notifications/local_notification_service.dart';
import 'package:flutter_pulse_app/features/task/presentation/providers/task_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localNotificationServiceProvider = Provider<LocalNotificationService>(
  (ref) => LocalNotificationService(),
);

// ─── FCM ─────────────────────────────────────────────────────────────────────
final fcmServiceProvider = Provider<FcmService>(
  (ref) => FcmService(
    messaging: ref.watch(firebaseMessagingProvider),
    devices: ref.watch(deviceRemoteDataSourceProvider),
    local: ref.watch(localNotificationServiceProvider),
  ),
);
