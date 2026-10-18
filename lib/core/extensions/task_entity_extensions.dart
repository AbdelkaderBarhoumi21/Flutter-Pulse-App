import 'package:flutter_pulse_app/core/constants/app_strings.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_entity.dart';

extension TaskEntityX on TaskEntity {
  /// Snack-bar text after this task's completion was toggled.
  String get toggledMessage =>
      isCompleted ? AppStrings.taskCompleted : AppStrings.taskReopened;
}
