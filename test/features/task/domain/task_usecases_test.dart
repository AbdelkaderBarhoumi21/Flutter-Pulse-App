import 'package:dartz/dartz.dart';
import 'package:flutter_pulse_app/core/constants/app_strings.dart';
import 'package:flutter_pulse_app/core/errors/failures.dart';
import 'package:flutter_pulse_app/core/usecase/usecase.dart';
import 'package:flutter_pulse_app/features/task/domain/usecases/add_task_usecase.dart';
import 'package:flutter_pulse_app/features/task/domain/usecases/delete_task_usecase.dart';
import 'package:flutter_pulse_app/features/task/domain/usecases/get_task_by_id_usecase.dart';
import 'package:flutter_pulse_app/features/task/domain/usecases/get_tasks_usecase.dart';
import 'package:flutter_pulse_app/features/task/domain/usecases/update_task_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_task_repository.dart';
import '../../../helpers/task_factory.dart';

void main() {
  late FakeTaskRepository repository;

  setUp(() => repository = FakeTaskRepository());

  test('GetTasks returns newest first', () async {
    repository.tasks.addAll([
      buildTask(id: 'old', createdAt: DateTime(2026)),
      buildTask(id: 'new', createdAt: DateTime(2026, 6)),
    ]);
    final result = await GetTasksUseCase(repository)(const NoParams());
    expect(result.getOrElse(() => []).map((t) => t.id), ['new', 'old']);
  });

  test('AddTask validates before calling the repository', () async {
    final result = await AddTaskUseCase(repository)(
      AddTaskParams(task: buildTask(title: 'ab')),
    );
    expect(
      result,
      const Left<Failure, Never>(ValidationFailure(AppStrings.titleTooShort)),
    );
    expect(repository.tasks, isEmpty);
  });

  test('AddTask creates a valid task', () async {
    final result = await AddTaskUseCase(repository)(
      AddTaskParams(task: buildTask(id: '')),
    );
    expect(result.isRight(), isTrue);
    expect(repository.tasks, hasLength(1));
  });

  test('UpdateTask rejects an empty id', () async {
    final result = await UpdateTaskUseCase(repository)(
      UpdateTaskParams(task: buildTask(id: ' ')),
    );
    expect(
      result,
      const Left<Failure, Never>(ValidationFailure(AppStrings.taskIdRequired)),
    );
  });

  test('DeleteTask and GetTaskById reject an empty id', () async {
    expect(
      await DeleteTaskUseCase(repository)(const DeleteTaskParams(id: '')),
      const Left<Failure, Never>(ValidationFailure(AppStrings.taskIdRequired)),
    );
    expect(
      await GetTaskByIdUseCase(repository)(const GetTaskByIdParams('')),
      const Left<Failure, Never>(ValidationFailure(AppStrings.taskIdRequired)),
    );
  });

  test('repository failures pass through unchanged', () async {
    repository.failure = const NetworkFailure();
    final result = await GetTasksUseCase(repository)(const NoParams());
    expect(result, const Left<Failure, Never>(NetworkFailure()));
  });
}
