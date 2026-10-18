import 'package:flutter_pulse_app/features/task/domain/entities/task_entity.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_priority.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_status.dart';

/// Wire format of a task. Enums travel as their `name`, dates as ISO-8601.
class TaskDto {
  const TaskDto({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.createdAt,
    this.completedAt,
  });

  factory TaskDto.fromJson(Map<String, dynamic> json) => TaskDto(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String? ?? '',
    priority: json['priority'] as String,
    status: json['status'] as String,
    createdAt: json['createdAt'] as String,
    completedAt: json['completedAt'] as String?,
  );

  factory TaskDto.fromEntity(TaskEntity task) => TaskDto(
    id: task.id,
    title: task.title,
    description: task.description,
    priority: task.priority.name,
    status: task.status.name,
    createdAt: task.createdAt.toIso8601String(),
    completedAt: task.completedAt?.toIso8601String(),
  );

  final String id;
  final String title;
  final String description;
  final String priority; // "low" | "medium" | "high"
  final String status; // "pending" | "inProgress" | "completed"
  final String createdAt;
  final String? completedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'priority': priority,
    'status': status,
    'createdAt': createdAt,
    'completedAt': completedAt,
  };

  /// Throws on unknown enum values or bad dates; the datasource guard turns
  /// that into an `UnexpectedException`.
  TaskEntity toEntity() => TaskEntity(
    id: id,
    title: title,
    description: description,
    priority: TaskPriority.values.byName(priority),
    status: TaskStatus.values.byName(status),
    createdAt: DateTime.parse(createdAt),
    completedAt: completedAt == null ? null : DateTime.parse(completedAt!),
  );
}
