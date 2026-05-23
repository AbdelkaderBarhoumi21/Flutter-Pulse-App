import 'package:dartz/dartz.dart';
import 'package:flutter_pulse_app/core/errors/failures.dart';
import 'package:flutter_pulse_app/core/usecase/usecase.dart';
import 'package:flutter_pulse_app/core/utils/validators/app_validators.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_entity.dart';
import 'package:flutter_pulse_app/features/task/domain/repositories/task_repository.dart';

class UpdateTaskParams {
  const UpdateTaskParams({required this.taskEntity});
  final TaskEntity taskEntity;
}

class UpdateTaskUseCase implements UseCase<TaskEntity, UpdateTaskParams> {
  const UpdateTaskUseCase(this._repository);
  final TaskRepository _repository;

  @override
  Future<Either<Failure, TaskEntity>> call(UpdateTaskParams params) async {
    if (params.taskEntity.id.trim().isEmpty) {
      return const Left(ValidationFailure('Task ID cannot be empty'));
    }

    final titleError = AppValidators.validateTitle(params.taskEntity.title);
    if (titleError != null) {
      return Left(ValidationFailure(titleError));
    }

    final descError = AppValidators.validateDescription(
      params.taskEntity.description,
    );
    if (descError != null) {
      return Left(ValidationFailure(descError));
    }

    return _repository.updateTask(params.taskEntity);
  }
}
