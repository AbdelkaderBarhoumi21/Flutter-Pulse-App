import 'package:flutter_pulse_app/core/notifications/notification_payload.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('round-trips through a map', () {
    const payload = NotificationPayload(
      type: 'task_updated',
      taskId: '42',
      route: '/task-details',
    );
    expect(NotificationPayload.fromMap(payload.toMap()), payload);
  });

  test('tolerates missing and non-string values', () {
    final payload = NotificationPayload.fromMap(const {'taskId': 42});
    expect(payload.taskId, '42');
    expect(payload.route, isNull);
    expect(payload.type, isNull);
  });
}
