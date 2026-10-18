import 'package:flutter/material.dart';
import 'package:flutter_pulse_app/core/constants/app_strings.dart';
import 'package:flutter_pulse_app/core/widgets/confirm_dialog.dart';

extension TaskDialogX on BuildContext {
  /// Asks before deleting a task. Resolves to `true` only on confirm.
  Future<bool> confirmTaskDelete() {
    return showConfirmDialog(
      this,
      title: AppStrings.deleteTaskTitle,
      message: AppStrings.deleteTaskMessage,
      confirmLabel: AppStrings.delete,
      icon: Icons.delete_outline_rounded,
      destructive: true,
    );
  }
}
