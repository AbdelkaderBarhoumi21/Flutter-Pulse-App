import 'package:equatable/equatable.dart';

/// Typed view of a push message's `data` block, e.g.
/// `{ "type": "task_updated", "taskId": "…", "route": "/task-details" }`.
class NotificationPayload extends Equatable {
  const NotificationPayload({this.type, this.taskId, this.route});

  factory NotificationPayload.fromMap(Map<String, dynamic> data) {
    return NotificationPayload(
      type: _string(data[_typeKey]),
      taskId: _string(data[_taskIdKey]),
      route: _string(data[_routeKey]),
    );
  }

  static const String _typeKey = 'type';
  static const String _taskIdKey = 'taskId';
  static const String _routeKey = 'route';

  final String? type;
  final String? taskId;
  final String? route;

  Map<String, String?> toMap() => {
    _typeKey: type,
    _taskIdKey: taskId,
    _routeKey: route,
  };

  static String? _string(Object? value) => value?.toString();

  @override
  List<Object?> get props => [type, taskId, route];
}
