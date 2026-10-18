import 'package:flutter/material.dart';
import 'package:flutter_pulse_app/core/constants/app_limits.dart';
import 'package:flutter_pulse_app/core/constants/app_spacing.dart';
import 'package:flutter_pulse_app/core/constants/app_strings.dart';
import 'package:flutter_pulse_app/core/extensions/animate_extensions.dart';
import 'package:flutter_pulse_app/core/extensions/context_extensions.dart';
import 'package:flutter_pulse_app/core/extensions/task_priority_extensions.dart';
import 'package:flutter_pulse_app/core/extensions/task_status_extensions.dart';
import 'package:flutter_pulse_app/core/helpers/action_feedback.dart';
import 'package:flutter_pulse_app/core/widgets/app_button.dart';
import 'package:flutter_pulse_app/core/widgets/choice_chip_group.dart';
import 'package:flutter_pulse_app/core/widgets/section_label.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_entity.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_priority.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_status.dart';
import 'package:flutter_pulse_app/features/task/domain/validators/task_validator.dart';
import 'package:flutter_pulse_app/features/task/presentation/providers/task_list_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

/// Create (when [initial] is null) or edit form. Holds only ephemeral input
/// state; saving goes through [TaskListController]. Stays open with a
/// friendly message if saving fails.
class TaskForm extends ConsumerStatefulWidget {
  const TaskForm({this.initial, super.key});

  final TaskEntity? initial;

  @override
  ConsumerState<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends ConsumerState<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late TaskPriority _priority;
  late TaskStatus _status;
  bool _submitting = false;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _title = TextEditingController(text: initial?.title)
      ..addListener(_onChanged);
    _description = TextEditingController(text: initial?.description)
      ..addListener(_onChanged);
    _priority = initial?.priority ?? TaskPriority.medium;
    _status = initial?.status ?? TaskStatus.pending;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  bool get _isValid =>
      TaskValidator.validateTitle(_title.text) == null &&
      TaskValidator.validateDescription(_description.text) == null;

  bool get _hasChanges {
    final initial = widget.initial;
    if (initial == null) return _title.text.trim().isNotEmpty;
    return _title.text.trim() != initial.title ||
        _description.text.trim() != initial.description ||
        _priority != initial.priority ||
        _status != initial.status;
  }

  bool get _canSubmit => _isValid && _hasChanges && !_submitting;

  Future<void> _submit() async {
    context.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);

    final controller = ref.read(taskListControllerProvider.notifier);
    final title = _title.text.trim();
    final description = _description.text.trim();
    final initial = widget.initial;

    final saved = await ActionFeedback.run(
      context,
      initial == null
          ? controller.create(
              title: title,
              description: description,
              priority: _priority,
            )
          : controller.edit(
              initial,
              title: title,
              description: description,
              priority: _priority,
              status: _status,
            ),
      successMessage: (_) =>
          _isEdit ? AppStrings.taskUpdated : AppStrings.taskCreated,
    );

    if (!mounted) return;
    setState(() => _submitting = false);
    if (saved) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final gap = SizedBox(height: AppSpacing.xl.h);

    final fields = <Widget>[
      const SectionLabel(AppStrings.titleLabel),
      TextFormField(
        controller: _title,
        autofocus: !_isEdit,
        textCapitalization: TextCapitalization.sentences,
        textInputAction: TextInputAction.next,
        maxLength: AppLimits.maxTitleLength,
        decoration: const InputDecoration(
          hintText: AppStrings.titleHint,
          counterText: '',
        ),
        validator: TaskValidator.validateTitle,
      ),
      gap,
      const SectionLabel(AppStrings.descriptionLabel),
      TextFormField(
        controller: _description,
        textCapitalization: TextCapitalization.sentences,
        minLines: 4,
        maxLines: 8,
        maxLength: AppLimits.maxDescriptionLength,
        decoration: const InputDecoration(hintText: AppStrings.descriptionHint),
        validator: TaskValidator.validateDescription,
      ),
      gap,
      const SectionLabel(AppStrings.priorityLabel),
      ChoiceChipGroup<TaskPriority>(
        options: TaskPriority.values,
        selected: _priority,
        onSelected: (p) => setState(() => _priority = p),
        labelOf: (p) => p.label,
        iconOf: (p) => p.icon,
        colorOf: (p) => p.colorOf(colors),
      ),
      if (_isEdit) ...[
        gap,
        const SectionLabel(AppStrings.statusLabel),
        ChoiceChipGroup<TaskStatus>(
          options: TaskStatus.values,
          selected: _status,
          onSelected: (s) => setState(() => _status = s),
          labelOf: (s) => s.label,
          iconOf: (s) => s.icon,
          colorOf: (s) => s.colorOf(colors),
        ),
      ],
    ];

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: context.pagePadding.copyWith(
                top: AppSpacing.md.h,
                bottom: AppSpacing.xl.h,
              ),
              itemCount: fields.length,
              itemBuilder: (_, index) => fields[index],
            ).entrance(),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: context.pagePadding.copyWith(
                top: AppSpacing.sm.h,
                bottom: AppSpacing.sm.h,
              ),
              child: AppButton(
                expand: true,
                label: _isEdit ? AppStrings.save : AppStrings.createTask,
                icon: _isEdit ? Icons.check_rounded : Icons.add_rounded,
                isLoading: _submitting,
                onPressed: _canSubmit || _submitting ? _submit : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
