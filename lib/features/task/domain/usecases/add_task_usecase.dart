import 'package:dartz/dartz.dart';
import 'package:flutter_pulse_app/core/errors/failures.dart';
import 'package:flutter_pulse_app/core/usecase/usecase.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_entity.dart';
import 'package:flutter_pulse_app/features/task/domain/repositories/task_repository.dart';
import 'package:flutter_pulse_app/features/task/domain/validators/task_validator.dart';

class AddTaskParams {
  const AddTaskParams({required this.task});
  final TaskEntity task;
}

class AddTaskUseCase implements UseCase<TaskEntity, AddTaskParams> {
  const AddTaskUseCase(this._repository);
  final TaskRepository _repository;

  @override
  Future<Either<Failure, TaskEntity>> call(AddTaskParams params) async {
    final error = TaskValidator.validateContent(params.task);
    if (error != null) return Left(ValidationFailure(error));
    return _repository.addTask(params.task);
  }
}
