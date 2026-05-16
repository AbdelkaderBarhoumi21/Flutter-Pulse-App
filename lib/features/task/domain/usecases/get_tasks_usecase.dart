import 'package:dartz/dartz.dart';
import 'package:flutter_pulse_app/core/errors/failures.dart';
import 'package:flutter_pulse_app/core/usecase/usecase.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_entity.dart';
import 'package:flutter_pulse_app/features/task/domain/repositories/task_repository.dart';

class GetTasksUseCase implements UseCase<List<TaskEntity>, NoParams> {
  final TaskRepository repository;
  GetTasksUseCase({required this.repository});

  @override
  Future<Either<Failure, List<TaskEntity>>> call(NoParams params) =>
      repository.getTasks();
}
