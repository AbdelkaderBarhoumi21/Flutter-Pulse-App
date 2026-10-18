import 'package:flutter/material.dart';
import 'package:flutter_pulse_app/core/constants/app_strings.dart';
import 'package:flutter_pulse_app/core/theme/app_semantic_colors.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_priority.dart';

/// UI presentation of [TaskPriority] (label, icon, colour).
extension TaskPriorityX on TaskPriority {
  String get label => switch (this) {
    TaskPriority.low => AppStrings.priorityLow,
    TaskPriority.medium => AppStrings.priorityMedium,
    TaskPriority.high => AppStrings.priorityHigh,
  };

  IconData get icon => switch (this) {
    TaskPriority.low => Icons.spa_rounded,
    TaskPriority.medium => Icons.flag_rounded,
    TaskPriority.high => Icons.local_fire_department_rounded,
  };

  Color colorOf(AppSemanticColors colors) => switch (this) {
    TaskPriority.low => colors.priorityLow,
    TaskPriority.medium => colors.priorityMedium,
    TaskPriority.high => colors.priorityHigh,
  };
}
