import 'package:flutter_pulse_app/features/task/domain/entities/task_entity.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_priority.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_status.dart';

final DateTime testNow = DateTime(2026, 10, 18, 9, 41);

TaskEntity buildTask({
  String id = 'task-1',
  String title = 'Write the release notes',
  String description = 'Summarize every change for the team',
  TaskPriority priority = TaskPriority.medium,
  TaskStatus status = TaskStatus.pending,
  DateTime? createdAt,
  DateTime? completedAt,
}) {
  return TaskEntity(
    id: id,
    title: title,
    description: description,
    priority: priority,
    status: status,
    createdAt: createdAt ?? testNow.subtract(const Duration(hours: 2)),
    completedAt: completedAt,
  );
}
