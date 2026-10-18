import 'package:flutter/widgets.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_entity.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_priority.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_status.dart';
import 'package:flutter_pulse_app/features/task/presentation/widgets/task_details_view.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Shimmering placeholder of the details screen (deep links, cold starts).
class TaskDetailsSkeleton extends StatelessWidget {
  const TaskDetailsSkeleton({super.key});

  static final TaskEntity _placeholder = TaskEntity(
    id: 'placeholder',
    title: 'Loading the task title',
    description:
        'Loading the task description, which usually spans a couple of '
        'lines of text.',
    priority: TaskPriority.medium,
    status: TaskStatus.pending,
    createdAt: DateTime(2026),
  );

  @override
  Widget build(BuildContext context) {
    return HeroMode(
      enabled: false,
      child: Skeletonizer(child: TaskDetailsView(task: _placeholder)),
    );
  }
}
