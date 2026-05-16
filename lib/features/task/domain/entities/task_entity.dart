import 'package:equatable/equatable.dart';
import 'package:flutter_pulse_app/core/utils/enums/task_enums.dart';



class TaskEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;

  const TaskEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.createdAt,
    this.completedAt,
  });

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
