import 'dart:async';

import 'package:flutter_pulse_app/features/task/domain/entities/task_entity.dart';
import 'package:flutter_pulse_app/features/task/domain/usecases/get_task_by_id_usecase.dart';
import 'package:flutter_pulse_app/features/task/presentation/providers/task_list_controller.dart';
import 'package:flutter_pulse_app/features/task/presentation/providers/task_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One task, by id. Disposed when its screen closes.
final taskDetailsControllerProvider = AsyncNotifierProvider.autoDispose
    .family<TaskDetailsController, TaskEntity, String>(
      TaskDetailsController.new,
    );

/// Shows the cached copy from the list instantly (smooth Hero transition),
/// then revalidates it from the server — important when opened from a push,
/// which means the task just changed. Also follows list mutations, so edits
/// and status changes show up here without a reload.
class TaskDetailsController
    extends AutoDisposeFamilyAsyncNotifier<TaskEntity, String> {
  bool _disposed = false;

  @override
  Future<TaskEntity> build(String id) async {
    _disposed = false;
    ref.onDispose(() => _disposed = true);

    ref.listen(
      taskListControllerProvider.select(
        (tasks) => tasks.valueOrNull?.where((t) => t.id == id).firstOrNull,
      ),
      (_, next) {
        if (next != null) state = AsyncData(next);
      },
    );

    final cached = ref
        .read(taskListControllerProvider)
        .valueOrNull
        ?.where((t) => t.id == id)
        .firstOrNull;
    if (cached != null) {
      unawaited(_revalidate(id));
      return cached;
    }
    return _fetch(id);
  }

  Future<TaskEntity> _fetch(String id) async {
    final result = await ref.read(getTaskByIdUseCaseProvider)(
      GetTaskByIdParams(id),
    );
    return result.fold((failure) => throw failure, (task) => task);
  }

  /// Silent background refresh; keeps the cached copy if it fails.
  Future<void> _revalidate(String id) async {
    final result = await ref.read(getTaskByIdUseCaseProvider)(
      GetTaskByIdParams(id),
    );
    if (_disposed) return;
    result.fold((_) {}, (task) => state = AsyncData(task));
  }
}
