import 'package:flutter_pulse_app/core/usecase/usecase.dart';
import 'package:flutter_pulse_app/core/utils/enums/task_enums.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_entity.dart';
import 'package:flutter_pulse_app/features/task/domain/usecases/add_task_usecase.dart';
import 'package:flutter_pulse_app/features/task/domain/usecases/delete_task_usecase.dart';
import 'package:flutter_pulse_app/features/task/domain/usecases/update_task_usecase.dart';
import 'package:flutter_pulse_app/features/task/presentation/providers/task_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final tasksListViewModelProvider =
    AsyncNotifierProvider<TasksListViewModel, List<TaskEntity>>(
      TasksListViewModel.new,
    );

class TasksListViewModel extends AsyncNotifier<List<TaskEntity>> {
  @override
  Future<List<TaskEntity>> build() async => _load();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _load());
  }

  Future<void> addTask(TaskEntity taskEntity) async {
    final result = await ref
        .read(addTaskUseCaseProvider)
        .call(AddTaskParams(taskEntity: taskEntity));
    result.fold(
      (failure) => state = AsyncError(failure, StackTrace.current),
      (_) => refresh(),
    );
  }

  Future<void> editTask(TaskEntity taskEntity) async {
    final result = await ref
        .read(updateTaskUseCaseProvider)
        .call(UpdateTaskParams(taskEntity: taskEntity));
    result.fold(
      (failure) => state = AsyncError(failure, StackTrace.current),
      (_) => refresh(),
    );
  }

  Future<void> markCompleted(TaskEntity taskEntity) async {
    final updated = TaskEntity(
      id: taskEntity.id,
      title: taskEntity.title,
      description: taskEntity.description,
      priority: taskEntity.priority,
      status: TaskStatus.completed,
      createdAt: taskEntity.createdAt,
      completedAt: DateTime.now(),
    );

    final result = await ref
        .read(updateTaskUseCaseProvider)
        .call(UpdateTaskParams(taskEntity: updated));
    result.fold(
      (failure) => state = AsyncError(failure, StackTrace.current),
      (_) => refresh(),
    );
  }

  Future<void> delete(String id) async {
    final result = await ref
        .read(deleteTaskUseCaseProvider)
        .call(DeleteTaskParams(id: id));
    result.fold(
      (failure) => state = AsyncError(failure, StackTrace.current),
      (_) => refresh(),
    );
  }

  /// Single helper that converts `Either<Failure, T>` to a Future<T>
  /// (throwing the failure for AsyncValue.guard to catch).
  Future<List<TaskEntity>> _load() async {
    final result = await ref
        .read(getTasksUseCaseProvider)
        .call(const NoParams());
    return result.fold((failure) => throw failure, (tasks) => tasks);
  }
}
