import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_pulse_app/core/constants/app_spacing.dart';
import 'package:flutter_pulse_app/core/constants/app_strings.dart';
import 'package:flutter_pulse_app/core/extensions/animate_extensions.dart';
import 'package:flutter_pulse_app/core/extensions/context_extensions.dart';
import 'package:flutter_pulse_app/core/extensions/date_time_extensions.dart';
import 'package:flutter_pulse_app/core/extensions/task_dialog_extensions.dart';
import 'package:flutter_pulse_app/core/extensions/task_entity_extensions.dart';
import 'package:flutter_pulse_app/core/helpers/action_feedback.dart';
import 'package:flutter_pulse_app/core/routing/app_navigation.dart';
import 'package:flutter_pulse_app/core/utils/entrance_tracker.dart';
import 'package:flutter_pulse_app/core/widgets/page_header.dart';
import 'package:flutter_pulse_app/core/widgets/state_message_view.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_entity.dart';
import 'package:flutter_pulse_app/features/task/presentation/providers/task_filter_controller.dart';
import 'package:flutter_pulse_app/features/task/presentation/providers/task_list_controller.dart';
import 'package:flutter_pulse_app/features/task/presentation/providers/task_list_selectors.dart';
import 'package:flutter_pulse_app/features/task/presentation/widgets/new_task_button.dart';
import 'package:flutter_pulse_app/features/task/presentation/widgets/progress_summary_card.dart';
import 'package:flutter_pulse_app/features/task/presentation/widgets/task_filter_bar.dart';
import 'package:flutter_pulse_app/features/task/presentation/widgets/task_list_item.dart';
import 'package:flutter_pulse_app/features/task/presentation/widgets/task_list_skeleton.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TaskListPage extends ConsumerStatefulWidget {
  const TaskListPage({super.key});

  @override
  ConsumerState<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends ConsumerState<TaskListPage> {
  final _scrollController = ScrollController();
  final _entranceTracker = EntranceTracker();
  bool _fabExtended = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Collapse the FAB while scrolling down, expand it again on the way up.
  void _onScroll() {
    final direction = _scrollController.position.userScrollDirection;
    final extended = switch (direction) {
      ScrollDirection.reverse => false,
      ScrollDirection.forward => true,
      ScrollDirection.idle => _fabExtended,
    };
    if (extended != _fabExtended) setState(() => _fabExtended = extended);
  }

  Future<void> _refresh() async {
    final result = await ref
        .read(taskListControllerProvider.notifier)
        .refresh();
    if (!mounted) return;
    result.fold(context.showError, (_) {});
  }

  Future<void> _toggleCompleted(TaskEntity task) => ActionFeedback.run(
    context,
    ref.read(taskListControllerProvider.notifier).toggleCompleted(task),
    successMessage: (updated) => updated.toggledMessage,
  );

  Future<void> _delete(TaskEntity task) => ActionFeedback.run(
    context,
    ref.read(taskListControllerProvider.notifier).delete(task.id),
    successMessage: (_) => AppStrings.taskDeleted,
  );

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(taskListControllerProvider);

    return Scaffold(
      floatingActionButton: tasks.hasValue
          ? NewTaskButton(
              extended: _fabExtended,
              onPressed: context.pushNewTask,
            ).entrance()
          : null,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              PageHeader(
                title: AppStrings.tasksTitle,
                eyebrow: DateTime.now().headline,
              ),
              if (tasks.hasValue)
                ..._contentSlivers()
              else if (tasks.hasError)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: StateMessageView.error(
                    error: tasks.error!,
                    onRetry: _refresh,
                  ),
                )
              else
                const SliverToBoxAdapter(child: TaskListSkeleton()),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _contentSlivers() {
    final stats = ref.watch(taskStatsProvider);
    final filter = ref.watch(taskFilterControllerProvider);
    final visible = ref.watch(visibleTasksProvider);

    return [
      SliverPadding(
        padding: context.pagePadding,
        sliver: SliverToBoxAdapter(
          child: ProgressSummaryCard(stats: stats).entrance(),
        ),
      ),
      SliverPadding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md.h),
        sliver: SliverToBoxAdapter(
          child: TaskFilterBar(
            selected: filter,
            stats: stats,
            onSelected: ref.read(taskFilterControllerProvider.notifier).select,
          ).entrance(index: 1),
        ),
      ),
      if (visible.isEmpty)
        SliverFillRemaining(
          hasScrollBody: false,
          child: _EmptyTasks(
            hasAnyTask: stats.total > 0,
            onCreate: context.pushNewTask,
          ),
        )
      else
        SliverPadding(
          padding: context.pagePadding.copyWith(
            bottom: AppSpacing.fabClearance.h,
          ),
          sliver: _taskList(visible),
        ),
    ];
  }

  Widget _taskList(List<TaskEntity> tasks) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final task = tasks[index];
          return TaskListItem(
            key: ValueKey(task.id),
            task: task,
            index: index,
            entranceTracker: _entranceTracker,
            onTap: () => context.pushTaskDetails(task.id),
            onToggleCompleted: () => _toggleCompleted(task),
            confirmDelete: context.confirmTaskDelete,
            onDeleted: () => _delete(task),
          );
        },
        childCount: tasks.length,
        // Keeps each item's state (and its "already animated" flag) attached
        // to the right task when items are inserted, removed or reordered.
        findChildIndexCallback: (key) {
          final id = (key as ValueKey<String>).value;
          final index = tasks.indexWhere((t) => t.id == id);
          return index < 0 ? null : index;
        },
      ),
    );
  }
}

class _EmptyTasks extends StatelessWidget {
  const _EmptyTasks({required this.hasAnyTask, required this.onCreate});

  /// `true` when tasks exist but none match the current filter.
  final bool hasAnyTask;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    if (hasAnyTask) {
      return const StateMessageView(
        icon: Icons.filter_alt_off_rounded,
        title: AppStrings.emptyFilterTitle,
        message: AppStrings.emptyFilterMessage,
      );
    }
    return StateMessageView(
      icon: Icons.task_alt_rounded,
      title: AppStrings.emptyTasksTitle,
      message: AppStrings.emptyTasksMessage,
      actionLabel: AppStrings.newTask,
      actionIcon: Icons.add_rounded,
      onAction: onCreate,
    );
  }
}
