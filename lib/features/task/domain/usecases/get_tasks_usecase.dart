import 'package:dartz/dartz.dart';
import 'package:flutter_pulse_app/core/errors/failures.dart';
import 'package:flutter_pulse_app/core/usecase/usecase.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_entity.dart';
import 'package:flutter_pulse_app/features/task/domain/repositories/task_repository.dart';

class GetTasksUseCase implements UseCase<List<TaskEntity>, NoParams> {
  const GetTasksUseCase(this._repository);
  final TaskRepository _repository;

  /// Newest first, so freshly created tasks show up on top.
  @override
  Future<Either<Failure, List<TaskEntity>>> call(NoParams params) async {
    final result = await _repository.getTasks();
    return result.map(
      (tasks) => [...tasks]..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
    );
  }
}
