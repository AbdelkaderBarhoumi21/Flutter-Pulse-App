import 'package:dartz/dartz.dart';
import 'package:flutter_pulse_app/core/errors/failures.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_entity.dart';

abstract class TaskRepository {
  Future<Either<Failure, List<TaskEntity>>> getTasks();
  Future<Either<Failure, TaskEntity>> getTaskById(String id);
  Future<Either<Failure, TaskEntity>> addTask(TaskEntity task);
  Future<Either<Failure, TaskEntity>> updateTask(TaskEntity task);
  Future<Either<Failure, void>> deleteTask(String id);
}
