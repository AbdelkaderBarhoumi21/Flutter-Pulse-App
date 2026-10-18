import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_pulse_app/core/errors/failures.dart';
import 'package:flutter_pulse_app/core/usecase/usecase.dart';
import 'package:flutter_pulse_app/core/utils/clock_provider.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_entity.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_priority.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_status.dart';
import 'package:flutter_pulse_app/features/task/domain/usecases/add_task_usecase.dart';
import 'package:flutter_pulse_app/features/task/domain/usecases/delete_task_usecase.dart';
import 'package:flutter_pulse_app/features/task/domain/usecases/update_task_usecase.dart';
import 'package:flutter_pulse_app/features/task/presentation/providers/task_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The app-wide task list. Lives as long as the app (the Tasks tab is kept
/// alive by the shell), and is the single source of truth other screens
/// sync from.
final taskListControllerProvider =
    AsyncNotifierProvider<TaskListController, List<TaskEntity>>(
      TaskListController.new,
    );

class TaskListController extends AsyncNotifier<List<TaskEntity>> {
  Future<Either<Failure, Unit>>? _refreshInFlight;

  @override
  Future<List<TaskEntity>> build() async {
    final result = await ref.read(getTasksUseCaseProvider)(const NoParams());
    return result.fold((failure) => throw failure, (tasks) => tasks);
  }

  /// Reloads from the server. Current data stays on screen while loading,
  /// and a failed refresh keeps it (the caller shows the failure). Calls
  /// made while a refresh is running share it instead of firing again.
  Future<Either<Failure, Unit>> refresh() {
    return _refreshInFlight ??= _refresh().whenComplete(
      () => _refreshInFlight = null,
    );
  }

  Future<Either<Failure, Unit>> _refresh() async {
    final hadData = state.hasValue;
    if (!hadData) state = const AsyncLoading();

    final result = await ref.read(getTasksUseCaseProvider)(const NoParams());
    result.fold((failure) {
      if (!hadData) state = AsyncError(failure, StackTrace.current);
    }, (tasks) => state = AsyncData(tasks));
    return result.map((_) => unit);
  }

  Future<Either<Failure, TaskEntity>> create({
    required String title,
    required String description,
    required TaskPriority priority,
  }) {
    final draft = TaskEntity.draft(
      title: title,
      description: description,
      priority: priority,
      now: ref.read(clockProvider)(),
    );
    return _mutate(
      request: () =>
          ref.read(addTaskUseCaseProvider)(AddTaskParams(task: draft)),
      onSuccess: _upsert,
    );
  }

  Future<Either<Failure, TaskEntity>> edit(
    TaskEntity original, {
    required String title,
    required String description,
    required TaskPriority priority,
    required TaskStatus status,
  }) {
    final updated = original
        .copyWith(title: title, description: description, priority: priority)
        .withStatus(status, now: ref.read(clockProvider)());
    return _save(updated);
  }

  /// Completes an open task, or reopens a completed one. Optimistic.
  Future<Either<Failure, TaskEntity>> toggleCompleted(TaskEntity task) {
    final next = task.isCompleted ? TaskStatus.pending : TaskStatus.completed;
    return _save(task.withStatus(next, now: ref.read(clockProvider)()));
  }

  /// Optimistic: the task disappears at once and comes back on failure.
  Future<Either<Failure, Unit>> delete(String id) {
    return _mutate(
      request: () =>
          ref.read(deleteTaskUseCaseProvider)(DeleteTaskParams(id: id)),
      optimistic: (tasks) => tasks.where((t) => t.id != id).toList(),
    );
  }

  Future<Either<Failure, TaskEntity>> _save(TaskEntity task) {
    return _mutate(
      request: () =>
          ref.read(updateTaskUseCaseProvider)(UpdateTaskParams(task: task)),
      optimistic: (tasks) => _upsert(tasks, task),
      onSuccess: _upsert,
    );
  }

  /// Runs [request] with an optional optimistic update that is rolled back
  /// on failure. The list never turns into an error state because of a
  /// failed mutation — the failure is returned for the UI to show.
  Future<Either<Failure, T>> _mutate<T>({
    required Future<Either<Failure, T>> Function() request,
    List<TaskEntity> Function(List<TaskEntity> tasks)? optimistic,
    List<TaskEntity> Function(List<TaskEntity> tasks, T value)? onSuccess,
  }) async {
    final snapshot = state.valueOrNull;
    if (snapshot != null && optimistic != null) {
      state = AsyncData(optimistic(snapshot));
    }

    final result = await request();

    result.fold(
      (_) {
        if (snapshot != null && optimistic != null) state = AsyncData(snapshot);
      },
      (value) {
        final current = state.valueOrNull;
        if (current != null && onSuccess != null) {
          state = AsyncData(onSuccess(current, value));
        }
      },
    );
    return result;
  }

  /// Replaces the task with the same id, or inserts it on top.
  static List<TaskEntity> _upsert(List<TaskEntity> tasks, TaskEntity task) {
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index < 0) return [task, ...tasks];
    return [...tasks]..[index] = task;
  }
}
