import 'package:dartz/dartz.dart';
import 'package:flutter_pulse_app/core/errors/failures.dart';
import 'package:flutter_pulse_app/core/usecase/usecase.dart';
import 'package:flutter_pulse_app/core/utils/validators/app_validators.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_entity.dart';
import 'package:flutter_pulse_app/features/task/domain/repositories/task_repository.dart';

class AddTaskParams {
  const AddTaskParams({required this.taskEntity});
  final TaskEntity taskEntity;
}

class AddTask implements UseCase<TaskEntity, AddTaskParams> {
  const AddTask(this._repository);
  final TaskRepository _repository;

  @override
  Future<Either<Failure, TaskEntity>> call(AddTaskParams params) async {
    final titleError = AppValidators.validateTitle(params.taskEntity.title);
    final descError = AppValidators.validateDescription(
      params.taskEntity.description,
    );
    if (titleError != null) {
      return Left(ValidationFailure(titleError));
    }

    if (descError != null) {
      return Left(ValidationFailure(descError));
    }

    return _repository.addTask(params.taskEntity);
  }
}
