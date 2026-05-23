import 'package:flutter_pulse_app/features/task/domain/entities/task_entity.dart';
import 'package:flutter_pulse_app/features/task/domain/usecases/get_task_by_id_usecase.dart';
import 'package:flutter_pulse_app/features/task/presentation/providers/task_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final taskDetailsViewModelProvider =
    AsyncNotifierProvider.family<TaskDetailsViewModel, TaskEntity, String>(
      TaskDetailsViewModel.new,
    );

class TaskDetailsViewModel extends FamilyAsyncNotifier<TaskEntity, String> {
  @override
  Future<TaskEntity> build(String id) async => _load(id);

  /// Single helper that converts `Either<Failure, T>` to a Future<T>
  /// (throwing the failure for AsyncValue to catch).
  Future<TaskEntity> _load(String id) async {
    final result = await ref
        .read(getTaskByIdUseCaseProvider)
        .call(GetTaskByIdParams(id));
    return result.fold((failure) => throw failure, (task) => task);
  }
}
