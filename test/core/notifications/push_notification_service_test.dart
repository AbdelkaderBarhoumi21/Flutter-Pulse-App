import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_pulse_app/core/errors/failures.dart';
import 'package:flutter_pulse_app/core/notifications/local_notification_service.dart';
import 'package:flutter_pulse_app/core/notifications/notification_payload.dart';
import 'package:flutter_pulse_app/core/notifications/notification_tap_handler.dart';
import 'package:flutter_pulse_app/core/notifications/push_message.dart';
import 'package:flutter_pulse_app/core/notifications/push_messaging_client.dart';
import 'package:flutter_pulse_app/core/notifications/push_notification_service.dart';
import 'package:flutter_pulse_app/core/notifications/push_token_registrar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockLocal extends Mock implements LocalNotificationService {}

class _MockRegistrar extends Mock implements PushTokenRegistrar {}

class _FakeClient implements PushMessagingClient {
  final tokenRefresh = StreamController<String>.broadcast();
  final foreground = StreamController<PushMessage>.broadcast();
  final opened = StreamController<NotificationPayload>.broadcast();
  String? token = 'token-1';
  NotificationPayload? initial;
  Object? permissionError;

  @override
  Future<void> requestPermission() async {
    if (permissionError != null) throw permissionError!;
  }

  @override
  Future<String?> getToken() async => token;

  @override
  Stream<String> get onTokenRefresh => tokenRefresh.stream;

  @override
  Stream<PushMessage> get onForegroundMessage => foreground.stream;

  @override
  Stream<NotificationPayload> get onNotificationOpened => opened.stream;

  @override
  Future<NotificationPayload?> getInitialNotification() async => initial;

  Future<void> close() async {
    await tokenRefresh.close();
    await foreground.close();
    await opened.close();
  }
}

void main() {
  late _FakeClient client;
  late _MockLocal local;
  late _MockRegistrar registrar;
  late PushNotificationService service;
  late List<NotificationPayload> taps;

  const message = PushMessage(
    title: 'Task updated',
    body: 'Ship it',
    payload: NotificationPayload(taskId: '7', route: '/task-details'),
  );

  setUpAll(() => registerFallbackValue(message));

  setUp(() {
    client = _FakeClient();
    local = _MockLocal();
    registrar = _MockRegistrar();
    taps = [];
    service = PushNotificationService(
      messaging: client,
      localNotifications: local,
      tokenRegistrar: registrar,
      platform: 'android',
    );
    when(() => local.init(onTap: any(named: 'onTap'))).thenAnswer((_) async {});
    when(() => local.show(any())).thenAnswer((_) async {});
    when(
      () => registrar.registerToken(
        token: any(named: 'token'),
        platform: any(named: 'platform'),
      ),
    ).thenAnswer((_) async => const Right(unit));
  });

  tearDown(() => client.close());

  // Regression: LocalNotificationService.init() was never called, so
  // foreground pushes were never shown and local taps went nowhere.
  test('initializes local notifications with the tap handler', () async {
    await service.start(onTap: taps.add);

    final captured = verify(
      () => local.init(onTap: captureAny(named: 'onTap')),
    ).captured;
    (captured.single as NotificationTapHandler)(message.payload);
    expect(taps, [message.payload]);
  });

  test('registers the token, and again when it refreshes', () async {
    await service.start(onTap: taps.add);
    client.tokenRefresh.add('token-2');
    await pumpEventQueue();

    verify(
      () => registrar.registerToken(token: 'token-1', platform: 'android'),
    ).called(1);
    verify(
      () => registrar.registerToken(token: 'token-2', platform: 'android'),
    ).called(1);
  });

  test('shows foreground messages and forwards opened ones', () async {
    await service.start(onTap: taps.add);
    client.foreground.add(message);
    client.opened.add(message.payload);
    await pumpEventQueue();

    verify(() => local.show(message)).called(1);
    expect(taps, [message.payload]);
  });

  test('opens the notification that launched the app', () async {
    client.initial = message.payload;
    await service.start(onTap: taps.add);
    expect(taps, [message.payload]);
  });

  test('starting twice does nothing the second time', () async {
    await service.start(onTap: taps.add);
    await service.start(onTap: taps.add);
    verify(() => local.init(onTap: any(named: 'onTap'))).called(1);
  });

  test('never throws when push is unavailable', () async {
    client.permissionError = Exception('no play services');
    await expectLater(service.start(onTap: taps.add), completes);
  });

  test('a failed registration is swallowed', () async {
    when(
      () => registrar.registerToken(
        token: any(named: 'token'),
        platform: any(named: 'platform'),
      ),
    ).thenAnswer((_) async => const Left(NetworkFailure()));
    await expectLater(service.start(onTap: taps.add), completes);
  });

  // Regression: stream subscriptions were never cancelled.
  test('dispose cancels every subscription', () async {
    await service.start(onTap: taps.add);
    expect(client.foreground.hasListener, isTrue);

    await service.dispose();

    expect(client.tokenRefresh.hasListener, isFalse);
    expect(client.foreground.hasListener, isFalse);
    expect(client.opened.hasListener, isFalse);
  });
}
