import 'package:dio/dio.dart';
import 'package:flutter_pulse_app/core/errors/app_error_guard.dart';
import 'package:flutter_pulse_app/core/network/app_api_endpoints.dart';
import 'package:flutter_pulse_app/features/task/data/datasources/task_remote_datasource.dart';
import 'package:flutter_pulse_app/features/task/data/models/task_dto.dart';

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  const TaskRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<List<TaskDto>> getTasks() {
    return AppErrorGuard.guardThrowing(() async {
      final response = await _dio.get<List<dynamic>>(AppApiEndpoints.tasks);
      return (response.data ?? const [])
          .map((json) => TaskDto.fromJson(json as Map<String, dynamic>))
          .toList();
    }, parseErrorMessage: 'Failed to parse tasks response');
  }

  @override
  Future<TaskDto> getTaskById(String id) {
    return AppErrorGuard.guardThrowing(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        AppApiEndpoints.task(id),
      );
      return TaskDto.fromJson(response.data!);
    }, parseErrorMessage: 'Failed to parse task response');
  }

  @override
  Future<TaskDto> createTask(TaskDto task) {
    return AppErrorGuard.guardThrowing(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        AppApiEndpoints.tasks,
        data: task.toJson(),
      );
      return TaskDto.fromJson(response.data!);
    }, parseErrorMessage: 'Failed to parse create response');
  }

  @override
  Future<TaskDto> updateTask(TaskDto task) {
    return AppErrorGuard.guardThrowing(() async {
      final response = await _dio.put<Map<String, dynamic>>(
        AppApiEndpoints.task(task.id),
        data: task.toJson(),
      );
      return TaskDto.fromJson(response.data!);
    }, parseErrorMessage: 'Failed to parse update response');
  }

  @override
  Future<void> deleteTask(String id) {
    return AppErrorGuard.guardThrowing(
      () => _dio.delete<void>(AppApiEndpoints.task(id)),
    );
  }
}
