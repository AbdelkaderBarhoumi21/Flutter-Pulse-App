import 'package:flutter/material.dart';
import 'package:flutter_pulse_app/core/constants/app_icon_sizes.dart';
import 'package:flutter_pulse_app/core/extensions/context_extensions.dart';
import 'package:flutter_pulse_app/core/extensions/task_priority_extensions.dart';
import 'package:flutter_pulse_app/core/widgets/icon_box.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_entity.dart';

/// The task's priority icon. A Hero, so it flies from the list card into
/// the details header.
class TaskPriorityIcon extends StatelessWidget {
  const TaskPriorityIcon({
    required this.task,
    this.iconSize = AppIconSizes.md,
    super.key,
  });

  final TaskEntity task;
  final double iconSize;

  static Object heroTag(String taskId) => 'task-priority-$taskId';

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag(task.id),
      // Scales the box smoothly between the two sizes during the flight.
      child: FittedBox(
        child: IconBox(
          icon: task.priority.icon,
          color: task.priority.colorOf(context.colors),
          iconSize: iconSize,
        ),
      ),
    );
  }
}
