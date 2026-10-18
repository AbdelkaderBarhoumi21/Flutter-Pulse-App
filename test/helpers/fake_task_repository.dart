import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_pulse_app/core/errors/failures.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_entity.dart';
import 'package:flutter_pulse_app/features/task/domain/repositories/task_repository.dart';

/// In-memory [TaskRepository]. Set [failure] to make every call fail, and
/// [gate] to hold calls until it completes (for in-flight assertions).
class FakeTaskRepository implements TaskRepository {
  FakeTaskRepository([List<TaskEntity> initial = const []])
    : tasks = [...initial];

  final List<TaskEntity> tasks;
  Failure? failure;
  Completer<void>? gate;
  int getTasksCalls = 0;
  int getTaskByIdCalls = 0;
  int _nextId = 1;

  Future<Either<Failure, T>> _run<T>(T Function() body) async {
    await gate?.future;
    final f = failure;
    if (f != null) return Left(f);
    return Right(body());
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> getTasks() {
    getTasksCalls++;
    return _run(() => List.of(tasks));
  }

  @override
  Future<Either<Failure, TaskEntity>> getTaskById(String id) async {
    getTaskByIdCalls++;
    final result = await _run(() => tasks.where((t) => t.id == id).firstOrNull);
    return result.flatMap(
      (task) => task == null
          ? const Left(ServerFailure('Server error: 404'))
          : Right(task),
    );
  }

  @override
  Future<Either<Failure, TaskEntity>> addTask(TaskEntity task) {
    return _run(() {
      final created = task.copyWith(id: 'new-${_nextId++}');
      tasks.insert(0, created);
      return created;
    });
  }

  @override
  Future<Either<Failure, TaskEntity>> updateTask(TaskEntity task) {
    return _run(() {
      final index = tasks.indexWhere((t) => t.id == task.id);
      tasks[index] = task;
      return task;
    });
  }

  @override
  Future<Either<Failure, Unit>> deleteTask(String id) {
    return _run(() {
      tasks.removeWhere((t) => t.id == id);
      return unit;
    });
  }
}
