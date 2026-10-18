import 'package:equatable/equatable.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_entity.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_status.dart';

/// Counts per status, derived from a task list.
class TaskStats extends Equatable {
  const TaskStats({
    required this.pending,
    required this.inProgress,
    required this.completed,
  });

  factory TaskStats.fromTasks(Iterable<TaskEntity> tasks) {
    var pending = 0;
    var inProgress = 0;
    var completed = 0;
    for (final task in tasks) {
      switch (task.status) {
        case TaskStatus.pending:
          pending++;
        case TaskStatus.inProgress:
          inProgress++;
        case TaskStatus.completed:
          completed++;
      }
    }
    return TaskStats(
      pending: pending,
      inProgress: inProgress,
      completed: completed,
    );
  }

  final int pending;
  final int inProgress;
  final int completed;

  int get total => pending + inProgress + completed;

  /// Completed share in `0..1` (0 when there are no tasks).
  double get progress => total == 0 ? 0 : completed / total;

  int countOf(TaskStatus status) => switch (status) {
    TaskStatus.pending => pending,
    TaskStatus.inProgress => inProgress,
    TaskStatus.completed => completed,
  };

  @override
  List<Object> get props => [pending, inProgress, completed];
}
