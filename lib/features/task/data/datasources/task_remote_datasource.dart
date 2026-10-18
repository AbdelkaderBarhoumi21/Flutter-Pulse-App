import 'package:flutter_pulse_app/features/task/data/models/task_dto.dart';

/// REST access to tasks. Implementations throw `AppException`s only.
abstract interface class TaskRemoteDataSource {
  Future<List<TaskDto>> getTasks();
  Future<TaskDto> getTaskById(String id);
  Future<TaskDto> createTask(TaskDto task);
  Future<TaskDto> updateTask(TaskDto task);
  Future<void> deleteTask(String id);
}
