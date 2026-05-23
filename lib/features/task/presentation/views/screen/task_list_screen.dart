import 'package:flutter/material.dart';
import 'package:flutter_pulse_app/core/router/app_routes_names.dart';
import 'package:flutter_pulse_app/core/utils/enums/task_enums.dart';
import 'package:flutter_pulse_app/features/task/presentation/viemodels/task_list_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tasksListViewModelProvider);
    final notifier = ref.watch(tasksListViewModelProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks List')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed(AppRoutesNames.taskForm),
        child: const Icon(Icons.add),
      ),
      body: state.when(
        data: (tasks) => RefreshIndicator(
          onRefresh: () => notifier.refresh(),
          child: ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              final isDone = task.status == TaskStatus.completed;
              return ListTile(
                leading: Checkbox(
                  value: isDone,
                  onChanged: isDone
                      ? null
                      : (_) => notifier.markCompleted(task),
                ),
                title: Text(
                  task.title,
                  style: TextStyle(
                    decoration: isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: Text('${task.priority.name} · ${task.status.name}'),
                trailing: IconButton(
                  onPressed: () => notifier.delete(task.id),
                  icon: const Icon(Icons.delete),
                ),
                onTap: () => context.pushNamed(
                  AppRoutesNames.taskDetails,
                  queryParameters: {'id': task.id},
                ),
              );
            },
          ),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
