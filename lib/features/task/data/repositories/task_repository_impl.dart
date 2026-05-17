import 'package:dartz/dartz.dart';
import 'package:flutter_pulse_app/core/errors/app_error_guard.dart';
import 'package:flutter_pulse_app/core/errors/failures.dart';
import 'package:flutter_pulse_app/features/task/data/datasources/remote/task_remote_datasource.dart';
import 'package:flutter_pulse_app/features/task/data/models/task_dto.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_entity.dart';
import 'package:flutter_pulse_app/features/task/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;
  TaskRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<TaskEntity>>> getTasks() {
    return AppErrorGuard.guardEither(() async {
      final dtos = await remoteDataSource.getTasks();
      return dtos.map((d) => d.toEntity()).toList();
    });
  }

  @override
  Future<Either<Failure, TaskEntity>> getTaskById(String id) {
    return AppErrorGuard.guardEither(() async {
      final dto = await remoteDataSource.getTaskById(id);
      return dto.toEntity();
    });
  }

  @override
  Future<Either<Failure, TaskEntity>> addTask(TaskEntity task) {
    return AppErrorGuard.guardEither(() async {
      final dto = await remoteDataSource.createTask(TaskDto.fromEntity(task));
      return dto.toEntity();
    });
  }

  @override
  Future<Either<Failure, TaskEntity>> updateTask(TaskEntity task) {
    return AppErrorGuard.guardEither(() async {
      final dto = await remoteDataSource.updateTask(
        task.id,
        TaskDto.fromEntity(task),
      );
      return dto.toEntity();
    });
  }

  @override
  Future<Either<Failure, void>> deleteTask(String id) {
    return AppErrorGuard.guardEither(() => remoteDataSource.deleteTask(id));
  }
}
