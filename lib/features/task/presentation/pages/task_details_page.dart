import 'package:flutter/material.dart';
import 'package:flutter_pulse_app/core/constants/app_strings.dart';
import 'package:flutter_pulse_app/core/extensions/context_extensions.dart';
import 'package:flutter_pulse_app/core/extensions/task_dialog_extensions.dart';
import 'package:flutter_pulse_app/core/extensions/task_entity_extensions.dart';
import 'package:flutter_pulse_app/core/helpers/action_feedback.dart';
import 'package:flutter_pulse_app/core/routing/app_navigation.dart';
import 'package:flutter_pulse_app/core/widgets/async_value_view.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_entity.dart';
import 'package:flutter_pulse_app/features/task/presentation/providers/task_details_controller.dart';
import 'package:flutter_pulse_app/features/task/presentation/providers/task_list_controller.dart';
import 'package:flutter_pulse_app/features/task/presentation/widgets/task_action_bar.dart';
import 'package:flutter_pulse_app/features/task/presentation/widgets/task_details_skeleton.dart';
import 'package:flutter_pulse_app/features/task/presentation/widgets/task_details_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TaskDetailsPage extends ConsumerStatefulWidget {
  const TaskDetailsPage({required this.taskId, super.key});

  final String taskId;

  @override
  ConsumerState<TaskDetailsPage> createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends ConsumerState<TaskDetailsPage> {
  bool _busy = false;

  Future<void> _toggleCompleted(TaskEntity task) async {
    setState(() => _busy = true);
    await ActionFeedback.run(
      context,
      ref.read(taskListControllerProvider.notifier).toggleCompleted(task),
      successMessage: (updated) => updated.toggledMessage,
    );
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _delete(TaskEntity task) async {
    if (!await context.confirmTaskDelete() || !mounted) return;
    final deleted = await ActionFeedback.run(
      context,
      ref.read(taskListControllerProvider.notifier).delete(task.id),
      successMessage: (_) => AppStrings.taskDeleted,
    );
    if (deleted && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final provider = taskDetailsControllerProvider(widget.taskId);
    final value = ref.watch(provider);
    final task = value.valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.taskDetailsTitle),
        actions: [
          if (task != null)
            IconButton(
              tooltip: AppStrings.delete,
              color: context.colors.danger,
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: _busy ? null : () => _delete(task),
            ),
        ],
      ),
      body: AsyncValueView(
        value: value,
        loading: const TaskDetailsSkeleton(),
        onRetry: () => ref.invalidate(provider),
        data: (task) => TaskDetailsView(task: task),
      ),
      bottomNavigationBar: task == null
          ? null
          : TaskActionBar(
              task: task,
              isBusy: _busy,
              onEdit: () => context.pushEditTask(task.id),
              onToggleCompleted: () => _toggleCompleted(task),
            ),
    );
  }
}
