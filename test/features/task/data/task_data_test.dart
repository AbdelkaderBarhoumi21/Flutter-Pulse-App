import 'package:flutter_pulse_app/core/errors/app_error_guard.dart';
import 'package:flutter_pulse_app/core/errors/exceptions.dart';
import 'package:flutter_pulse_app/core/errors/failures.dart';
import 'package:flutter_pulse_app/features/task/data/datasources/task_remote_datasource.dart';
import 'package:flutter_pulse_app/features/task/data/models/task_dto.dart';
import 'package:flutter_pulse_app/features/task/data/repositories/task_repository_impl.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_priority.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/task_factory.dart';

class _MockRemote extends Mock implements TaskRemoteDataSource {}

const _json = <String, dynamic>{
  'id': '1',
  'title': 'Ship v2',
  'description': 'All the things',
  'priority': 'high',
  'status': 'inProgress',
  'createdAt': '2026-10-18T09:41:00.000Z',
  'completedAt': null,
};

void main() {
  group('TaskDto', () {
    test('parses JSON into an entity', () {
      final task = TaskDto.fromJson(_json).toEntity();
      expect(task.priority, TaskPriority.high);
      expect(task.status, TaskStatus.inProgress);
      expect(task.createdAt, DateTime.utc(2026, 10, 18, 9, 41));
      expect(task.completedAt, isNull);
    });

    test('a missing description becomes empty', () {
      final json = Map<String, dynamic>.of(_json)..remove('description');
      expect(TaskDto.fromJson(json).description, isEmpty);
    });

    test('round-trips entity → JSON → entity', () {
      final task = buildTask(
        status: TaskStatus.completed,
        completedAt: testNow,
      );
      final back = TaskDto.fromJson(
        TaskDto.fromEntity(task).toJson(),
      ).toEntity();
      expect(back, task);
    });

    test('unknown enum values surface as UnexpectedException', () async {
      final json = Map<String, dynamic>.of(_json)..['status'] = 'archived';
      await expectLater(
        AppErrorGuard.guardThrowing(
          () async => TaskDto.fromJson(json).toEntity(),
        ),
        throwsA(isA<UnexpectedException>()),
      );
    });
  });

  group('TaskRepositoryImpl', () {
    late _MockRemote remote;
    late TaskRepositoryImpl repository;

    setUp(() {
      remote = _MockRemote();
      repository = TaskRepositoryImpl(remote);
    });

    test('maps DTOs to entities', () async {
      when(remote.getTasks).thenAnswer((_) async => [TaskDto.fromJson(_json)]);
      final result = await repository.getTasks();
      expect(result.getOrElse(() => []).single.title, 'Ship v2');
    });

    test('turns exceptions into failures', () async {
      when(() => remote.deleteTask('1')).thenThrow(const NetworkException());
      final result = await repository.deleteTask('1');
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('expected a failure'),
      );
    });
  });
}
