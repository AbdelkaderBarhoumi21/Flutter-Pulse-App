import 'package:flutter/material.dart';
import 'package:flutter_pulse_app/features/task/presentation/viemodels/task_details_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaskDetailsScreen extends ConsumerWidget {
  const TaskDetailsScreen({required this.taskId, super.key});

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(taskDetailsViewModelProvider(taskId));
    return Scaffold(
      appBar: AppBar(title: const Text('Task Details')),
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
