# Flutter Clean Architecture — Project Template

This document describes the folder structure, layering rules, and naming
conventions used in **flutter_pulse_app**, so the same pattern can be
reproduced in other Flutter projects. It is derived directly from this
codebase — copy the structure, not just the idea.

---

## 1. Tech stack

| Concern              | Package                                    |
|-----------------------|---------------------------------------------|
| State management      | `flutter_riverpod` (+ `riverpod_annotation`) |
| Routing               | `go_router`                                  |
| Networking            | `dio`                                        |
| Functional error type | `dartz` (`Either<Failure, T>`)               |
| Value equality        | `equatable`                                  |
| Push notifications    | `firebase_core`, `firebase_messaging`, `flutter_local_notifications` |
| Codegen (optional)    | `freezed`, `json_serializable`, `riverpod_generator` |

Riverpod providers are plain top-level `Provider`/`AsyncNotifierProvider`
declarations (no `injectable`/`get_it`) — DI is just "one provider per
dependency," wired in `lib/core/di/`.

---

## 2. Top-level folder structure

```
lib/
├── core/                     # Shared, feature-agnostic building blocks
│   ├── app/                  # Root MaterialApp widget
│   ├── di/                   # Riverpod provider wiring (composition root)
│   ├── errors/                # Exceptions, Failures, and the guard that bridges them
│   ├── network/               # Dio client factory + API endpoint constants
│   ├── notifications/         # FCM / local notification services
│   ├── router/                # go_router setup, route names, route paths
│   ├── usecase/               # Base UseCase<Result, Params> contract
│   └── utils/
│       ├── constants/         # App-wide constant values
│       ├── enums/             # Shared enums (feature-specific enums can live in core if reused)
│       ├── helpers/
│       ├── typedef/           # Shared function-signature typedefs
│       └── validators/        # Pure validation functions
│
├── features/
│   └── <feature_name>/        # e.g. task, auth, device
│       ├── data/
│       │   ├── datasources/
│       │   │   ├── remote/    # API-backed data sources
│       │   │   └── locale/    # Local/cache data sources (optional, spelled "locale" here — see note)
│       │   ├── models/        # DTOs: fromJson/toJson + fromEntity/toEntity mappers
│       │   └── repositories/  # Repository *implementations*
│       ├── domain/
│       │   ├── entities/      # Plain business objects (Equatable, no JSON)
│       │   ├── repositories/  # Repository *interfaces* (abstract contracts)
│       │   └── usecases/      # One class per business operation
│       └── presentation/
│           ├── providers/     # Riverpod DI wiring scoped to this feature
│           ├── viemodels/     # AsyncNotifier/Notifier view models (see naming note below)
│           └── views/
│               ├── screen/    # Full-page widgets (route destinations)
│               └── widgets/   # Reusable widgets local to this feature
│
├── firebase_options.dart
└── main.dart
```

> **Naming inconsistencies preserved from this project — fix in new projects:**
> - `presentation/viemodels/` is a typo of `viewmodels/`. Use `viewmodels/` in new projects.
> - `datasources/locale/` should be `datasources/local/` (`locale` means language/region, not local storage).
> - Keep these called out here so a future clone of this doc doesn't propagate the typo on purpose.

---

## 3. Layer responsibilities (dependency direction)

```
presentation  →  domain  ←  data
```

- **domain** has zero dependencies on `data` or `presentation`. It only
  defines entities, repository *interfaces*, and use cases.
- **data** implements the domain's repository interfaces, talking to
  datasources and mapping DTOs ↔ entities.
- **presentation** depends only on `domain` (entities + usecases), never
  directly on `data`.
- Only `core/di` (or a feature's `presentation/providers`) is allowed to
  import a concrete `data` class and hand it to a `domain` interface.

### Data flow for a write (e.g. add task)

```
Screen (widget)
  → ViewModel.addTask()
    → ref.read(addTaskUseCaseProvider).call(Params)
      → UseCase validates input, calls TaskRepository (interface)
        → TaskRepositoryImpl (data layer)
          → AppErrorGuard.guardEither(() => datasource call)
            → TaskRemoteDataSource (Dio call)
              → AppErrorGuard.guardThrowing(() => dio.post(...))
```

Errors thrown as `AppException` at the datasource boundary are converted to
`Either<Failure, T>` at the repository boundary. Nothing above the
repository ever throws — it's `Either` all the way up to the ViewModel,
which unwraps with `.fold(...)`.

---

## 4. Naming conventions

### Files (snake_case, suffix identifies the role)

| Role                    | File suffix                | Example                              |
|--------------------------|-----------------------------|----------------------------------------|
| Entity                   | `_entity.dart`              | `task_entity.dart`                    |
| DTO / model              | `_dto.dart`                 | `task_dto.dart`                       |
| Repository interface      | `_repository.dart`          | `task_repository.dart`                |
| Repository implementation | `_repository_impl.dart`     | `task_repository_impl.dart`           |
| Use case                 | `_usecase.dart`             | `add_task_usecase.dart`               |
| Data source               | `_datasource.dart`           | `task_remote_datasource.dart`         |
| View model                | `_viewmodel.dart`            | `task_list_viewmodel.dart`            |
| Riverpod provider wiring  | `_providers.dart`            | `task_providers.dart`                 |
| Screen (route destination)| `_screen.dart`               | `task_list_screen.dart`               |
| Enum bucket               | `_enums.dart`                | `task_enums.dart`                     |

### Classes (PascalCase, suffix mirrors the file role)

| Role                  | Class pattern                          | Example                     |
|------------------------|------------------------------------------|-------------------------------|
| Entity                 | `<Feature>Entity`                        | `TaskEntity`                 |
| DTO                    | `<Feature>Dto`                           | `TaskDto`                    |
| Repository interface    | `<Feature>Repository`                    | `TaskRepository`             |
| Repository impl         | `<Feature>RepositoryImpl`                | `TaskRepositoryImpl`         |
| Use case                | `<Verb><Feature>UseCase`                 | `AddTaskUseCase`, `GetTasksUseCase` |
| Use case params          | `<Verb><Feature>Params`                  | `AddTaskParams`, `DeleteTaskParams` |
| Data source interface    | `<Feature>RemoteDataSource`              | `TaskRemoteDataSource`       |
| Data source impl         | `<Feature>RemoteDataSourceImpl`          | `TaskRemoteDataSourceImpl`  |
| ViewModel (Riverpod)     | `<Feature(s)><Purpose>` extends `AsyncNotifier<T>` | `TasksListViewModel` |
| ViewModel provider       | `<featureName><Purpose>Provider`         | `tasksListViewModelProvider` |
| Screen widget            | `<Feature><Purpose>Screen`               | `TaskListScreen`, `TaskDetailsScreen` |

### Riverpod provider variables (camelCase, `Provider` suffix)

```dart
final taskRemoteDataSourceProvider = Provider<TaskRemoteDataSource>((ref) => ...);
final taskRepositoryProvider        = Provider<TaskRepository>((ref) => ...);
final addTaskUseCaseProvider        = Provider((ref) => AddTaskUseCase(...));
final tasksListViewModelProvider    = AsyncNotifierProvider<TasksListViewModel, List<TaskEntity>>(...);
```

Rule of thumb: **provider is always typed against the abstract interface**,
never the concrete impl (`Provider<TaskRepository>`, not
`Provider<TaskRepositoryImpl>`) — this is what makes swapping/mock-testing
possible.

---

## 5. Reference implementation (copy these patterns verbatim)

### 5.1 Entity — `domain/entities/task_entity.dart`

```dart
class TaskEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;

  const TaskEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.createdAt,
    this.completedAt,
  });

  @override
  List<Object?> get props => [id, title, description, priority, status, createdAt, completedAt];
}
```

### 5.2 DTO — `data/models/task_dto.dart`

Wire format lives entirely in the DTO. `fromEntity`/`toEntity` are the only
place enum ↔ string and `DateTime` ↔ ISO-string conversions happen.

```dart
class TaskDto {
  final String id;
  final String title;
  final String description;
  final String priority; // wire string, not the enum
  final String status;
  final String createdAt; // ISO string
  final String? completedAt;

  TaskDto({required this.id, /* ... */});

  factory TaskDto.fromJson(Map<String, dynamic> json) => TaskDto(/* ... */);
  factory TaskDto.fromEntity(TaskEntity t) => TaskDto(/* .name / .toIso8601String() */);
  Map<String, dynamic> toJson() => {/* ... */};
  TaskEntity toEntity() => TaskEntity(/* TaskPriority.fromApi(priority), DateTime.parse(createdAt) */);
}
```

### 5.3 Repository interface — `domain/repositories/task_repository.dart`

```dart
abstract class TaskRepository {
  Future<Either<Failure, List<TaskEntity>>> getTasks();
  Future<Either<Failure, TaskEntity>> getTaskById(String id);
  Future<Either<Failure, TaskEntity>> addTask(TaskEntity task);
  Future<Either<Failure, TaskEntity>> updateTask(TaskEntity task);
  Future<Either<Failure, void>> deleteTask(String id);
}
```

### 5.4 Repository implementation — `data/repositories/task_repository_impl.dart`

```dart
class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;
  TaskRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<TaskEntity>>> getTasks() {
    return AppErrorGuard.guardEither(() async {
      final dtos = await remoteDataSource.getTasks();
      return dtos.map((d) => d.toEntity()).toList();
    });
  }
  // ...other methods follow the same guardEither(...) shape
}
```

### 5.5 Use case — `domain/usecases/add_task_usecase.dart`

One class per operation. Params object even for a single field, so call
sites are self-documenting (`AddTaskParams(taskEntity: ...)` instead of a
bare positional arg). Business-rule validation (not wire validation) lives
here, before the repository is called.

```dart
class AddTaskParams {
  const AddTaskParams({required this.taskEntity});
  final TaskEntity taskEntity;
}

class AddTaskUseCase implements UseCase<TaskEntity, AddTaskParams> {
  const AddTaskUseCase(this._repository);
  final TaskRepository _repository;

  @override
  Future<Either<Failure, TaskEntity>> call(AddTaskParams params) async {
    final titleError = AppValidators.validateTitle(params.taskEntity.title);
    if (titleError != null) return Left(ValidationFailure(titleError));
    return _repository.addTask(params.taskEntity);
  }
}
```

Base contract — `core/usecase/usecase.dart`:

```dart
abstract class UseCase<Result, Params> {
  Future<Either<Failure, Result>> call(Params params);
}

class NoParams {
  const NoParams();
}
```

### 5.6 Data source — `data/datasources/remote/task_remote_datasource.dart`

```dart
abstract class TaskRemoteDataSource {
  Future<List<TaskDto>> getTasks();
  Future<TaskDto> getTaskById(String id);
  Future<TaskDto> createTask(TaskDto task);
  Future<TaskDto> updateTask(TaskDto task);
  Future<void> deleteTask(String id);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final Dio dio;
  TaskRemoteDataSourceImpl(this.dio);

  @override
  Future<List<TaskDto>> getTasks() {
    return AppErrorGuard.guardThrowing(() async {
      final response = await dio.get(AppApiEndpoints.getTasks);
      return (response.data as List).map((e) => TaskDto.fromJson(e)).toList();
    }, parseErrorMessage: 'Failed to parse tasks response');
  }
  // ...
}
```

### 5.7 ViewModel — `presentation/viemodels/task_list_viewmodel.dart`

`AsyncNotifier<T>` for anything backed by an async load. Mutations call a
use case, then `.fold()` into either `AsyncError` or a `refresh()`.

```dart
final tasksListViewModelProvider = AsyncNotifierProvider<TasksListViewModel, List<TaskEntity>>(
  TasksListViewModel.new,
);

class TasksListViewModel extends AsyncNotifier<List<TaskEntity>> {
  @override
  Future<List<TaskEntity>> build() async => _load();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _load());
  }

  Future<void> addTask(TaskEntity taskEntity) async {
    final result = await ref.read(addTaskUseCaseProvider).call(AddTaskParams(taskEntity: taskEntity));
    result.fold(
      (failure) => state = AsyncError(failure, StackTrace.current),
      (_) => refresh(),
    );
  }

  Future<List<TaskEntity>> _load() async {
    final result = await ref.read(getTasksUseCaseProvider).call(const NoParams());
    return result.fold((failure) => throw failure, (tasks) => tasks);
  }
}
```

### 5.7b ViewModel keyed by an argument — `.family` variant

When a screen needs data keyed by an id (e.g. task details), use
`AsyncNotifierProvider.family` + `FamilyAsyncNotifier<T, Arg>` instead of
plain `AsyncNotifier<T>`:

```dart
final taskDetailsViewModelProvider =
    AsyncNotifierProvider.family<TaskDetailsViewModel, TaskEntity, String>(
      TaskDetailsViewModel.new,
    );

class TaskDetailsViewModel extends FamilyAsyncNotifier<TaskEntity, String> {
  @override
  Future<TaskEntity> build(String id) async => _load(id);

  Future<TaskEntity> _load(String id) async {
    final result = await ref.read(getTaskByIdUseCaseProvider).call(GetTaskByIdParams(id));
    return result.fold((failure) => throw failure, (task) => task);
  }
}
```

Consumed as `ref.watch(taskDetailsViewModelProvider(taskId))`.

### 5.7c Form screen — stateful widget, not a ViewModel

Forms that need local, ephemeral UI state (`TextEditingController`s, a
dropdown selection, a submitting flag) are a `ConsumerStatefulWidget`, not
routed through a dedicated ViewModel — they call straight into an
*existing* ViewModel's mutation methods (e.g. the list ViewModel's
`addTask`/`editTask`) on submit:

```dart
class TaskFormScreen extends ConsumerStatefulWidget {
  const TaskFormScreen({this.existing, super.key});
  final TaskEntity? existing; // non-null → edit mode, null → create mode

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  bool _submitting = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existing?.title ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final notifier = ref.read(tasksListViewModelProvider.notifier);
    // build entity, call notifier.addTask(...) or notifier.editTask(...)
    if (!mounted) return;
    context.pop();
  }
  // build() renders a Form with TextFormField.validator: AppValidators.x
}
```

Rule of thumb: **read-only screens** (`TaskListScreen`, `TaskDetailsScreen`)
are `ConsumerWidget`s backed by a ViewModel. **Screens that collect user
input** (`TaskFormScreen`) are `ConsumerStatefulWidget`s that own their
local form state and delegate the actual mutation to an existing
ViewModel's method — they don't get their own ViewModel just to hold
`TextEditingController`s.

### 5.8 DI wiring — `presentation/providers/task_providers.dart`

Every feature gets one `<feature>_providers.dart` that wires datasource →
repository → usecases, always typed against interfaces:

```dart
final taskRemoteDataSourceProvider = Provider<TaskRemoteDataSource>((ref) {
  return TaskRemoteDataSourceImpl(ref.read(dioProvider));
});

final taskRepositoryProvider = Provider<TaskRepository>(
  (ref) => TaskRepositoryImpl(remoteDataSource: ref.read(taskRemoteDataSourceProvider)),
);

final getTasksUseCaseProvider = Provider((ref) => GetTasksUseCase(ref.watch(taskRepositoryProvider)));
final addTaskUseCaseProvider  = Provider((ref) => AddTaskUseCase(ref.watch(taskRepositoryProvider)));
```

Shared/cross-cutting providers (Dio client, Firebase instances) live in
`core/di/*_providers.dart` instead, and feature providers `ref.read`/`ref.watch`
them from there (see `dioProvider` in `core/di/network_providers.dart`).

---

## 6. Error handling pattern

Two-tier error system, converted at two fixed boundaries:

```
core/errors/
├── exceptions.dart       # AppException hierarchy — thrown by datasources
├── failures.dart          # Failure hierarchy — returned by repositories/usecases
├── dio_error_mapper.dart   # DioException → AppException
└── app_error_guard.dart    # The only place either conversion happens
```

- `AppErrorGuard.guardThrowing` wraps **datasource** calls: catches
  `DioException` (mapped via `DioErrorMapper`), rethrows `AppException`,
  and turns anything else into a `ValidationException` (parse failure).
- `AppErrorGuard.guardEither` wraps **repository** calls: catches every
  `AppException` subtype and returns the matching `Failure` as
  `Left(...)`, or `Right(result)` on success.
- Everything above the repository is `Either<Failure, T>` — no more
  try/catch after that point. ViewModels use `.fold(onError, onSuccess)`.

Mirror the exception ↔ failure pairs 1:1 when adding a new one
(`XException` in `exceptions.dart` needs a matching `XFailure` in
`failures.dart` and a case in both guard methods).

---

## 7. Routing pattern (`go_router`)

```
core/router/
├── app_routes_names.dart   # route *name* constants (used with pushNamed/goNamed)
├── app_routes_path.dart    # route *path* constants (used as GoRoute.path)
└── app_router.dart          # GoRouter instance, wired as a Riverpod provider
```

- Route **names** and **paths** are separate constant classes, both
  private-constructor "namespace" classes (`ClassName._()`), so they're
  never instantiated — just a bag of `static const`.
- Always navigate with `context.pushNamed(AppRoutesNames.x, ...)` /
  `router.goNamed(...)`, never with hardcoded path strings, so renaming a
  path never breaks a call site.
- The router itself is exposed via `appRouterProvider` (a
  `Provider<GoRouter>`), consumed once in `MaterialApp.router(routerConfig: ...)`.

---

## 8. Presentation folder split

```
presentation/
├── providers/    # DI wiring for this feature (see §5.8)
├── viewmodels/   # State + business-call orchestration (see §5.7)
└── views/
    ├── screen/    # One widget per route destination — reads a ViewModel via ref.watch
    └── widgets/   # Small reusable pieces local to this feature (not shared app-wide)
```

- Screens are `ConsumerWidget`s that only read state (`ref.watch(xProvider)`)
  and call ViewModel methods on user interaction — no business logic in
  the widget tree.
- Anything reusable **across features** goes in a top-level
  `lib/shared/widgets/` (or `core/widgets/`) instead of a feature's
  `views/widgets/`.

---

## 9. Checklist for adding a new feature

1. `features/<name>/domain/entities/<name>_entity.dart` — plain data class, `Equatable`.
2. `features/<name>/domain/repositories/<name>_repository.dart` — abstract interface returning `Either<Failure, T>`.
3. `features/<name>/domain/usecases/<verb>_<name>_usecase.dart` — one per operation, with a `Params` class.
4. `features/<name>/data/models/<name>_dto.dart` — `fromJson`/`toJson`/`fromEntity`/`toEntity`.
5. `features/<name>/data/datasources/remote/<name>_remote_datasource.dart` — interface + `Impl`, wrapped in `AppErrorGuard.guardThrowing`.
6. `features/<name>/data/repositories/<name>_repository_impl.dart` — implements the domain interface, wrapped in `AppErrorGuard.guardEither`.
7. `features/<name>/presentation/providers/<name>_providers.dart` — wire datasource → repository → usecases as Riverpod `Provider`s typed to interfaces.
8. `features/<name>/presentation/viewmodels/<name>_viewmodel.dart` — `AsyncNotifier` calling usecases, exposing a `<name>ViewModelProvider`.
9. `features/<name>/presentation/views/screen/<name>_screen.dart` — `ConsumerWidget` wired to the ViewModel.
10. Add route name + path constants in `core/router/`, register the `GoRoute` in `app_router.dart`.
11. If new failure/exception types are needed, add matching pairs in `core/errors/exceptions.dart` + `failures.dart`, and a case in both `AppErrorGuard` methods.
