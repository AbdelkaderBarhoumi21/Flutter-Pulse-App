import 'package:flutter_pulse_app/features/task/presentation/models/task_filter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final taskFilterControllerProvider =
    NotifierProvider<TaskFilterController, TaskFilter>(
      TaskFilterController.new,
    );

class TaskFilterController extends Notifier<TaskFilter> {
  @override
  TaskFilter build() => TaskFilter.all;

  void select(TaskFilter filter) => state = filter;
}
