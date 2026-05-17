import 'package:dio/dio.dart';
import 'package:flutter_pulse_app/core/errors/app_error_guard.dart';
import 'package:flutter_pulse_app/core/errors/dio_error_mapper.dart';
import 'package:flutter_pulse_app/core/network/app_api_endpoints.dart';
import 'package:flutter_pulse_app/core/network/app_dio_client.dart';
import 'package:flutter_pulse_app/features/task/data/models/task_dto.dart';

abstract class TaskRemoteDataSource {
  Future<List<TaskDto>> getTasks();
  Future<TaskDto> getTaskById(String id);
  Future<TaskDto> createTask(TaskDto task);
  Future<TaskDto> updateTask(String id, TaskDto task);
  Future<void> deleteTask(String id);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  @override
  Future<List<TaskDto>> getTasks() async {
    return AppErrorGuard.guardThrowing<List<TaskDto>>(() async {
      final response = await AppDioClient.instance.get(
        AppApiEndpoints.getTasks,
      );
      return (response.data as List).map((e) => TaskDto.fromJson(e)).toList();
    });
  }

  @override
  Future<TaskDto> getTaskById(String id) async {
    return AppErrorGuard.guardThrowing<TaskDto>(() async {
      final response = await AppDioClient.instance.get(
        AppApiEndpoints.getTasksById(id),
      );
      return TaskDto.fromJson(response.data);
    });
  }

  @override
  Future<TaskDto> createTask(TaskDto task) async {
    return AppErrorGuard.guardThrowing<TaskDto>(() async {
      final response = await AppDioClient.instance.post(
        AppApiEndpoints.createTask,
        data: task.toJson(),
      );
      return TaskDto.fromJson(response.data);
    });
  }

  @override
  Future<TaskDto> updateTask(String id, TaskDto task) async {
    return AppErrorGuard.guardThrowing<TaskDto>(() async {
      final response = await AppDioClient.instance.put(
        AppApiEndpoints.updateTask(id),
        data: task.toJson(),
      );
      return TaskDto.fromJson(response.data);
    });
  }

  @override
  Future<void> deleteTask(String id) async {
    try {
      await AppDioClient.instance.delete(AppApiEndpoints.deleteTask(id));
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }
}
