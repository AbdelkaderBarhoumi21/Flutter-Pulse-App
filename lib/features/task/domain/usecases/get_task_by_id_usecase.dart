import 'package:dartz/dartz.dart';
import 'package:flutter_pulse_app/core/errors/failures.dart';
import 'package:flutter_pulse_app/core/usecase/usecase.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_entity.dart';
import 'package:flutter_pulse_app/features/task/domain/repositories/task_repository.dart';
import 'package:flutter_pulse_app/features/task/domain/validators/task_validator.dart';

class GetTaskByIdParams {
  const GetTaskByIdParams(this.id);
  final String id;
}

class GetTaskByIdUseCase implements UseCase<TaskEntity, GetTaskByIdParams> {
  const GetTaskByIdUseCase(this._repository);
  final TaskRepository _repository;

  @override
  Future<Either<Failure, TaskEntity>> call(GetTaskByIdParams params) async {
    final error = TaskValidator.validateId(params.id);
    if (error != null) return Left(ValidationFailure(error));
    return _repository.getTaskById(params.id);
  }
}
