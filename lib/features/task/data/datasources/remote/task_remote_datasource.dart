import 'package:dio/dio.dart';
import 'package:flutter_pulse_app/core/errors/app_error_guard.dart';
import 'package:flutter_pulse_app/core/network/app_api_endpoints.dart';
import 'package:flutter_pulse_app/features/task/data/models/task_dto.dart';

abstract class TaskRemoteDataSource {
  Future<List<TaskDto>> getTasks();
  Future<TaskDto> getTaskById(String id);
  Future<TaskDto> createTask(TaskDto task);
  Future<TaskDto> updateTask(String id, TaskDto task);
  Future<void> deleteTask(String id);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final Dio dio;
  TaskRemoteDataSourceImpl(this.dio);

  @override
  Future<List<TaskDto>> getTasks() {
    return AppErrorGuard.guardThrowing(() async {
      final response = await dio.get(AppApiEndpoints.getTasks);
      return (response.data as List)
          .map((e) => TaskDto.fromJson(e as Map<String, dynamic>))
          .toList();
    }, parseErrorMessage: 'Failed to parse tasks response');
  }

  @override
  Future<TaskDto> getTaskById(String id) {
    return AppErrorGuard.guardThrowing(() async {
      final response = await dio.get(AppApiEndpoints.getTasksById(id));
      return TaskDto.fromJson(response.data as Map<String, dynamic>);
    }, parseErrorMessage: 'Failed to parse task response');
  }

  @override
  Future<TaskDto> createTask(TaskDto task) {
    return AppErrorGuard.guardThrowing(() async {
      final response = await dio.post(
        AppApiEndpoints.createTask,
        data: task.toJson(),
      );
      return TaskDto.fromJson(response.data as Map<String, dynamic>);
    }, parseErrorMessage: 'Failed to parse create response');
  }

  @override
  Future<TaskDto> updateTask(String id, TaskDto task) {
    return AppErrorGuard.guardThrowing(() async {
      final response = await dio.put(
        AppApiEndpoints.updateTask(id),
        data: task.toJson(),
      );
      return TaskDto.fromJson(response.data as Map<String, dynamic>);
    }, parseErrorMessage: 'Failed to parse update response');
  }

  @override
  Future<void> deleteTask(String id) {
    return AppErrorGuard.guardThrowing(
      () => dio.delete(AppApiEndpoints.deleteTask(id)),
    );
  }
}
