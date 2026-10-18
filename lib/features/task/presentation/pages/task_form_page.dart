import 'package:flutter/material.dart';
import 'package:flutter_pulse_app/core/constants/app_strings.dart';
import 'package:flutter_pulse_app/core/widgets/async_value_view.dart';
import 'package:flutter_pulse_app/features/task/presentation/providers/task_details_controller.dart';
import 'package:flutter_pulse_app/features/task/presentation/widgets/task_form.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// New task (no [taskId]) or edit an existing one. The task is loaded by id,
/// so the edit screen also works from a deep link.
class TaskFormPage extends ConsumerWidget {
  const TaskFormPage({this.taskId, super.key});

  final String? taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = taskId;

    return Scaffold(
      appBar: AppBar(
        title: Text(id == null ? AppStrings.newTask : AppStrings.editTaskTitle),
      ),
      body: id == null
          ? const TaskForm()
          : AsyncValueView(
              value: ref.watch(taskDetailsControllerProvider(id)),
              loading: const Center(child: CircularProgressIndicator()),
              onRetry: () => ref.invalidate(taskDetailsControllerProvider(id)),
              // Keyed by id: later updates of the task don't reset the form.
              data: (task) => TaskForm(key: ValueKey(task.id), initial: task),
            ),
    );
  }
}
