import 'package:flutter/material.dart';
import 'package:flutter_pulse_app/core/extensions/context_extensions.dart';
import 'package:flutter_pulse_app/core/extensions/task_filter_extensions.dart';
import 'package:flutter_pulse_app/core/widgets/choice_chip_group.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_stats.dart';
import 'package:flutter_pulse_app/features/task/presentation/models/task_filter.dart';

/// Horizontally scrolling filter pills with live counts.
class TaskFilterBar extends StatelessWidget {
  const TaskFilterBar({
    required this.selected,
    required this.stats,
    required this.onSelected,
    super.key,
  });

  final TaskFilter selected;
  final TaskStats stats;
  final ValueChanged<TaskFilter> onSelected;

  int _countOf(TaskFilter filter) {
    final status = filter.status;
    return status == null ? stats.total : stats.countOf(status);
  }

  @override
  Widget build(BuildContext context) {
    return ChoiceChipGroup<TaskFilter>(
      scrollable: true,
      padding: context.pagePadding,
      options: TaskFilter.values,
      selected: selected,
      onSelected: onSelected,
      labelOf: (filter) => '${filter.label}  ${_countOf(filter)}',
    );
  }
}
