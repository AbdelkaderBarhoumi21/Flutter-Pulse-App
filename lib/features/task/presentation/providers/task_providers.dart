import 'package:flutter_pulse_app/core/di/network_providers.dart';
import 'package:flutter_pulse_app/features/device/data/datasources/device_remote_datasource.dart';
import 'package:flutter_pulse_app/features/task/data/datasources/remote/task_remote_datasource.dart';
import 'package:flutter_pulse_app/features/task/data/repositories/task_repository_impl.dart';
import 'package:flutter_pulse_app/features/task/domain/repositories/task_repository.dart';
import 'package:flutter_pulse_app/features/task/domain/usecases/add_task_usecase.dart';
import 'package:flutter_pulse_app/features/task/domain/usecases/delete_task_usecase.dart';
import 'package:flutter_pulse_app/features/task/domain/usecases/get_task_by_id_usecase.dart';
import 'package:flutter_pulse_app/features/task/domain/usecases/get_tasks_usecase.dart';
import 'package:flutter_pulse_app/features/task/domain/usecases/update_task_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── Task — data layer ───────────────────────────────────────────────────────
//  <TaskRemoteDataSource> => It tells Riverpod (and the rest of your code) that this provider
// exposes the abstract interface TaskRemoteDataSource, not the concrete TaskRemoteDataSourceImpl
final taskRemoteDataSourceProvider = Provider<TaskRemoteDataSource>((ref) {
  return TaskRemoteDataSourceImpl(ref.read(dioProvider));
});

final taskRepositoryProvider = Provider<TaskRepository>(
  (ref) => TaskRepositoryImpl(
    remoteDataSource: ref.read(taskRemoteDataSourceProvider),
  ),
);

// ─── Task — usecases ─────────────────────────────────────────────────────────
final getTasksUseCaseProvider = Provider(
  (ref) => GetTasksUseCase(ref.watch(taskRepositoryProvider)),
);
final getTaskByIdUseCaseProvider = Provider(
  (ref) => GetTaskByIdUseCase(ref.watch(taskRepositoryProvider)),
);
final addTaskUseCaseProvider = Provider(
  (ref) => AddTaskUseCase(ref.watch(taskRepositoryProvider)),
);
final updateTaskUseCaseProvider = Provider(
  (ref) => UpdateTaskUseCase(ref.watch(taskRepositoryProvider)),
);
final deleteTaskUseCaseProvider = Provider(
  (ref) => DeleteTaskUseCase(ref.watch(taskRepositoryProvider)),
);

// ─── Devices ─────────────────────────────────────────────────────────────────
final deviceRemoteDataSourceProvider = Provider<DeviceRemoteDataSource>(
  (ref) => DeviceRemoteDataSourceImpl(ref.watch(dioProvider)),
);


