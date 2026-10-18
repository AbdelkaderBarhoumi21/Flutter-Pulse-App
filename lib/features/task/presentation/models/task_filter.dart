import 'package:flutter_pulse_app/features/task/domain/entities/task_entity.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_status.dart';

/// Filters of the task list: everything, or one status.
enum TaskFilter {
  all(null),
  pending(TaskStatus.pending),
  inProgress(TaskStatus.inProgress),
  completed(TaskStatus.completed);

  const TaskFilter(this.status);

  /// The status this filter keeps, or `null` for [all].
  final TaskStatus? status;

  bool matches(TaskEntity task) => status == null || task.status == status;
}
