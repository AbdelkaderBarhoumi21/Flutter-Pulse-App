import 'package:flutter/material.dart';
import 'package:flutter_pulse_app/core/constants/app_strings.dart';
import 'package:flutter_pulse_app/core/theme/app_semantic_colors.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_status.dart';

/// UI presentation of [TaskStatus] (label, icon, colour).
extension TaskStatusX on TaskStatus {
  String get label => switch (this) {
    TaskStatus.pending => AppStrings.statusPending,
    TaskStatus.inProgress => AppStrings.statusInProgress,
    TaskStatus.completed => AppStrings.statusCompleted,
  };

  IconData get icon => switch (this) {
    TaskStatus.pending => Icons.radio_button_unchecked_rounded,
    TaskStatus.inProgress => Icons.timelapse_rounded,
    TaskStatus.completed => Icons.check_circle_rounded,
  };

  Color colorOf(AppSemanticColors colors) => switch (this) {
    TaskStatus.pending => colors.textSecondary,
    TaskStatus.inProgress => colors.info,
    TaskStatus.completed => colors.success,
  };
}
