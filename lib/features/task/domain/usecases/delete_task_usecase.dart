import 'package:dartz/dartz.dart';
import 'package:flutter_pulse_app/core/errors/failures.dart';
import 'package:flutter_pulse_app/core/usecase/usecase.dart';
import 'package:flutter_pulse_app/features/task/domain/repositories/task_repository.dart';
import 'package:flutter_pulse_app/features/task/domain/validators/task_validator.dart';

class DeleteTaskParams {
  const DeleteTaskParams({required this.id});
  final String id;
}

class DeleteTaskUseCase implements UseCase<Unit, DeleteTaskParams> {
  const DeleteTaskUseCase(this._repository);
  final TaskRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(DeleteTaskParams params) async {
    final error = TaskValidator.validateId(params.id);
    if (error != null) return Left(ValidationFailure(error));
    return _repository.deleteTask(params.id);
  }
}
