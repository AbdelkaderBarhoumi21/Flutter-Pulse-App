import 'package:flutter/material.dart';
import 'package:flutter_pulse_app/core/router/app_routes_path.dart';
import 'package:flutter_pulse_app/core/utils/enums/task_enums.dart';
import 'package:flutter_pulse_app/features/task/presentation/viemodels/task_details_viewmodel.dart';
import 'package:flutter_pulse_app/features/task/presentation/viemodels/task_list_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TaskDetailsScreen extends ConsumerWidget {
  const TaskDetailsScreen({required this.taskId, super.key});

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(taskDetailsViewModelProvider(taskId));
    final listNotifier = ref.read(tasksListViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          state.maybeWhen(
            data: (t) => Row(
              children: [
                if (t.status != TaskStatus.completed)
                  IconButton(
                    tooltip: 'Mark complete',
                    icon: const Icon(Icons.check),
                    onPressed: () async {
                      await listNotifier.markCompleted(t);
                      ref.invalidate(taskDetailsViewModelProvider(taskId));
                    },
                  ),
                IconButton(
                  tooltip: 'Edit',
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    await context.push(AppRoutesPath.taskForm, extra: t);
                    ref.invalidate(taskDetailsViewModelProvider(taskId));
                  },
                ),
                IconButton(
                  tooltip: 'Delete',
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    await listNotifier.delete(t.id);
                    if (context.mounted) context.pop();
                  },
                ),
              ],
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: state.when(
        data: (t) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(t.description),
              const SizedBox(height: 8),
              Text('Priority: ${t.priority.name}'),
              Text('Status: ${t.status.name}'),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
