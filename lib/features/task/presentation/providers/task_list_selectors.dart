import 'package:flutter_pulse_app/features/task/domain/entities/task_entity.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_stats.dart';
import 'package:flutter_pulse_app/features/task/presentation/providers/task_filter_controller.dart';
import 'package:flutter_pulse_app/features/task/presentation/providers/task_list_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tasks matching the selected filter. Empty until the list has loaded.
final visibleTasksProvider = Provider<List<TaskEntity>>((ref) {
  final filter = ref.watch(taskFilterControllerProvider);
  final tasks = ref.watch(taskListControllerProvider).valueOrNull ?? const [];
  return tasks.where(filter.matches).toList(growable: false);
});

/// Per-status counts of all tasks (ignores the filter).
final taskStatsProvider = Provider<TaskStats>((ref) {
  final tasks = ref.watch(taskListControllerProvider).valueOrNull ?? const [];
  return TaskStats.fromTasks(tasks);
});
