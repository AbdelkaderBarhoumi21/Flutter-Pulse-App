import 'package:dartz/dartz.dart';
import 'package:flutter_pulse_app/core/errors/failures.dart';
import 'package:flutter_pulse_app/core/usecase/usecase.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_entity.dart';
import 'package:flutter_pulse_app/features/task/domain/repositories/task_repository.dart';

class GetTaskByIdParams {
  const GetTaskByIdParams(this.id);
  final String id;
}

class GetTaskById implements UseCase<TaskEntity, GetTaskByIdParams> {
  GetTaskById(this._repository);

  final TaskRepository _repository;
  @override
  Future<Either<Failure, TaskEntity>> call(GetTaskByIdParams params) async {
    if (params.id.trim().isEmpty) {
      return const Left(ValidationFailure('Task ID cannot be empty'));
    }

    return _repository.getTaskById(params.id);
  }
}
