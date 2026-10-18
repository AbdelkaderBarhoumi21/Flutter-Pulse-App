import 'package:equatable/equatable.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_priority.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_status.dart';

class TaskEntity extends Equatable {
  const TaskEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.createdAt,
    this.completedAt,
  });

  /// A not-yet-saved task. The backend assigns the real id.
  factory TaskEntity.draft({
    required String title,
    required String description,
    required TaskPriority priority,
    required DateTime now,
  }) {
    return TaskEntity(
      id: '',
      title: title,
      description: description,
      priority: priority,
      status: TaskStatus.pending,
      createdAt: now,
    );
  }

  final String id;
  final String title;
  final String description;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;

  bool get isCompleted => status == TaskStatus.completed;

  TaskEntity copyWith({
    String? id,
    String? title,
    String? description,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? createdAt,
    DateTime? Function()? completedAt,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt != null ? completedAt() : this.completedAt,
    );
  }

  /// Moves the task to [next], keeping `completedAt` consistent: stamped
  /// when it becomes completed, cleared when it's reopened.
  TaskEntity withStatus(TaskStatus next, {required DateTime now}) {
    if (next == status) return this;
    return copyWith(
      status: next,
      completedAt: () => next == TaskStatus.completed ? now : null,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    priority,
    status,
    createdAt,
    completedAt,
  ];
}
