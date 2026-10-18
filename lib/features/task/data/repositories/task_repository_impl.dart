import 'package:dartz/dartz.dart';
import 'package:flutter_pulse_app/core/errors/app_error_guard.dart';
import 'package:flutter_pulse_app/core/errors/failures.dart';
import 'package:flutter_pulse_app/features/task/data/datasources/task_remote_datasource.dart';
import 'package:flutter_pulse_app/features/task/data/models/task_dto.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_entity.dart';
import 'package:flutter_pulse_app/features/task/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  const TaskRepositoryImpl(this._remote);
  final TaskRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<TaskEntity>>> getTasks() {
    return AppErrorGuard.guardEither(() async {
      final dtos = await _remote.getTasks();
      return dtos.map((dto) => dto.toEntity()).toList();
    });
  }

  @override
  Future<Either<Failure, TaskEntity>> getTaskById(String id) {
    return AppErrorGuard.guardEither(
      () async => (await _remote.getTaskById(id)).toEntity(),
    );
  }

  @override
  Future<Either<Failure, TaskEntity>> addTask(TaskEntity task) {
    return AppErrorGuard.guardEither(
      () async =>
          (await _remote.createTask(TaskDto.fromEntity(task))).toEntity(),
    );
  }

  @override
  Future<Either<Failure, TaskEntity>> updateTask(TaskEntity task) {
    return AppErrorGuard.guardEither(
      () async =>
          (await _remote.updateTask(TaskDto.fromEntity(task))).toEntity(),
    );
  }

  @override
  Future<Either<Failure, Unit>> deleteTask(String id) {
    return AppErrorGuard.guardEither(() async {
      await _remote.deleteTask(id);
      return unit;
    });
  }
}
