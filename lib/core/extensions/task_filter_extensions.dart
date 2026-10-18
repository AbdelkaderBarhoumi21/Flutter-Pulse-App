import 'package:flutter_pulse_app/core/constants/app_strings.dart';
import 'package:flutter_pulse_app/core/extensions/task_status_extensions.dart';
import 'package:flutter_pulse_app/features/task/presentation/models/task_filter.dart';

extension TaskFilterX on TaskFilter {
  String get label => status?.label ?? AppStrings.filterAll;
}
