import 'package:flutter_pulse_app/core/constants/app_limits.dart';
import 'package:flutter_pulse_app/core/constants/app_strings.dart';
import 'package:flutter_pulse_app/core/extensions/string_extensions.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_entity.dart';

/// Task business rules. Each method returns `null` when valid, otherwise a
/// user-facing message — so the same rules drive form fields and use cases.
abstract final class TaskValidator {
  static String? validateTitle(String? value) {
    final title = value?.trim() ?? '';
    if (title.isEmpty) return AppStrings.titleRequired;
    if (title.length < AppLimits.minTitleLength) {
      return AppStrings.titleTooShort;
    }
    if (title.length > AppLimits.maxTitleLength) {
      return AppStrings.titleTooLong;
    }
    return null;
  }

  static String? validateDescription(String? value) {
    final description = value?.trim() ?? '';
    if (description.length > AppLimits.maxDescriptionLength) {
      return AppStrings.descriptionTooLong;
    }
    return null;
  }

  static String? validateId(String id) =>
      id.isBlank ? AppStrings.taskIdRequired : null;

  /// First content error of [task], if any.
  static String? validateContent(TaskEntity task) =>
      validateTitle(task.title) ?? validateDescription(task.description);
}
