class NotificationPayload {
  final String? type;
  final String? taskId;
  final String? route;
  NotificationPayload({this.type, this.taskId, this.route});

  factory NotificationPayload.fromMap(Map<String, dynamic> data) {
    return NotificationPayload(
      type: data['type'],
      taskId: data['taskId'],
      route: data['route'],
    );
  }
}
