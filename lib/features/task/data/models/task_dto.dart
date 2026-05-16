import 'package:flutter_pulse_app/core/utils/enums/task_enums.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_entity.dart';

class TaskDto {
  final String id;
  final String title;
  final String description;
  final String priority; // "low" | "medium" | "high"
  final String status; // "pending" | "inProgress" | "completed"
  final String createdAt; // ISO string
  final String? completedAt;

  TaskDto({
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
    description: json['description'] as String,
    priority: json['priority'] as String,
    status: json['status'] as String,
    createdAt: json['createdAt'] as String,
    completedAt: json['completedAt'] as String?,
  );

  TaskEntity toEntity() => TaskEntity(
    id: id,
    title: title,
    description: description,
    priority: TaskPriority.fromApi(priority),
    status: TaskStatus.fromApi(status),
    createdAt: DateTime.parse(createdAt),
    completedAt: completedAt != null ? DateTime.parse(completedAt!) : null,
  );
}
