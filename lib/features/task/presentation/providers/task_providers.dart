import 'package:flutter_pulse_app/core/network/network_providers.dart';
import 'package:flutter_pulse_app/features/task/data/datasources/task_remote_datasource.dart';
import 'package:flutter_pulse_app/features/task/data/datasources/task_remote_datasource_impl.dart';
import 'package:flutter_pulse_app/features/task/data/repositories/task_repository_impl.dart';
import 'package:flutter_pulse_app/features/task/domain/repositories/task_repository.dart';
import 'package:flutter_pulse_app/features/task/domain/usecases/add_task_usecase.dart';
import 'package:flutter_pulse_app/features/task/domain/usecases/delete_task_usecase.dart';
import 'package:flutter_pulse_app/features/task/domain/usecases/get_task_by_id_usecase.dart';
import 'package:flutter_pulse_app/features/task/domain/usecases/get_tasks_usecase.dart';
import 'package:flutter_pulse_app/features/task/domain/usecases/update_task_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Dependency wiring for the task feature. Each provider exposes an
// abstraction, so tests can override any layer.

// ─── Data ────────────────────────────────────────────────────────────────────
final taskRemoteDataSourceProvider = Provider<TaskRemoteDataSource>(
  (ref) => TaskRemoteDataSourceImpl(ref.watch(dioProvider)),
);

final taskRepositoryProvider = Provider<TaskRepository>(
  (ref) => TaskRepositoryImpl(ref.watch(taskRemoteDataSourceProvider)),
);

// ─── Use cases ───────────────────────────────────────────────────────────────
final getTasksUseCaseProvider = Provider<GetTasksUseCase>(
  (ref) => GetTasksUseCase(ref.watch(taskRepositoryProvider)),
);

final getTaskByIdUseCaseProvider = Provider<GetTaskByIdUseCase>(
  (ref) => GetTaskByIdUseCase(ref.watch(taskRepositoryProvider)),
);

final addTaskUseCaseProvider = Provider<AddTaskUseCase>(
  (ref) => AddTaskUseCase(ref.watch(taskRepositoryProvider)),
);

final updateTaskUseCaseProvider = Provider<UpdateTaskUseCase>(
  (ref) => UpdateTaskUseCase(ref.watch(taskRepositoryProvider)),
);

final deleteTaskUseCaseProvider = Provider<DeleteTaskUseCase>(
  (ref) => DeleteTaskUseCase(ref.watch(taskRepositoryProvider)),
);
