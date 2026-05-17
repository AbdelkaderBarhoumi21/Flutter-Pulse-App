# Flutter App — FCM Integration Guide

> Integrate **Firebase Cloud Messaging** into a Flutter task app using **Clean Architecture (MVVM)**, **Riverpod** for state management, **GoRouter** for navigation, **Dio** for the HTTP client, and **flutter_local_notifications** for foreground alerts. Includes notification icon setup and tests.

---

## Table of Contents

1. [Architecture Overview (MVVM + Clean Architecture)](#1-architecture-overview)
2. [Project Folder Structure](#2-project-folder-structure)
3. [Step 1 — Add Dependencies](#step-1--add-dependencies)
4. [Step 2 — Firebase Project Setup](#step-2--firebase-project-setup)
5. [Step 3 — Android Native Configuration](#step-3--android-native-configuration)
6. [Step 4 — iOS Native Configuration](#step-4--ios-native-configuration)
7. [Step 5 — Notification Icons (Status Bar)](#step-5--notification-icons-status-bar)
8. [Step 6 — App Bootstrap (`main.dart`)](#step-6--app-bootstrap)
9. [Step 7 — API Endpoints & Dio Client](#step-7--api-endpoints--dio-client)
10. [Step 8 — Domain Layer](#step-8--domain-layer)
11. [Step 9 — Data Layer (DataSource + Repository)](#step-9--data-layer)
12. [Step 10 — FCM Service (Remote Push)](#step-10--fcm-service-remote-push)
13. [Step 11 — Local Notification Service](#step-11--local-notification-service)
14. [Step 12 — Riverpod Providers (DI)](#step-12--riverpod-providers)
15. [Step 13 — ViewModel (MVVM)](#step-13--viewmodel-mvvm)
16. [Step 14 — GoRouter with Notification Deep Link](#step-14--gorouter-with-notification-deep-link)
17. [Step 15 — Views (UI Layer)](#step-15--views-ui-layer)
18. [Step 16 — Tests](#step-16--tests)
19. [Step 17 — Verifying End-to-End](#step-17--verifying-end-to-end)

---

## 1. Architecture Overview

We use **MVVM** layered on top of **Clean Architecture**, with explicit **error boundaries** between layers:

```
┌──────────────────────────────────────────────────────────────────────────┐
│ Presentation (View)         ─ Widgets, screens                           │
│   ↕ ref.watch / ref.read                                                 │
│ Presentation (ViewModel)    ─ AsyncNotifier — reads Either<Failure, T>   │
│   ↕ calls                                                                │
│ Domain (UseCases)           ─ Future<Either<Failure, T>>                 │
│   ↕ calls                                                                │
│ Domain (Repository abstract)─ Future<Either<Failure, T>>                 │
│   ↕ implemented by                                                       │
│ Data (Repository impl)      ─ try { ... } catch (AppException) → Left()  │
│   ↕ calls                                                                │
│ Data (DataSource)           ─ throws AppException, returns DTO/raw       │
│   ↕ uses                                                                 │
│ Core (Dio client, Endpoints, FCM, Router, Failures, Exceptions, UseCase) │
└──────────────────────────────────────────────────────────────────────────┘
```

**The error-handling contract — read this once and never debug it again:**

| Layer            | What it returns / throws                                  | Why                                                       |
|------------------|-----------------------------------------------------------|-----------------------------------------------------------|
| **DataSource**   | Returns `DTO`. **Throws `AppException`** on any error.    | Closest to the wire — knows what went wrong concretely.   |
| **Repository**   | Returns `Future<Either<Failure, Entity>>`. **Never throws.** | Catches `AppException`, maps to `Failure`, returns `Left`. Maps DTO → Entity on success.|
| **UseCase**      | Returns `Future<Either<Failure, T>>`. **Never throws.**   | Thin pass-through; encodes business intent as a verb.     |
| **ViewModel**    | Reads `Either`, folds into `AsyncValue` state for the UI. | UI never sees exceptions — only typed state.              |
| **View**         | Renders `AsyncValue.when(data:, loading:, error:)`.       | Pure declarative UI.                                      |

**Why two parallel hierarchies (`AppException` and `Failure`)?**
- `AppException` is a **data-layer concern** (HTTP error, no internet, parse error). It carries technical detail and is `throw`n.
- `Failure` is a **domain-layer concern** (something the user / business cares about: "server down", "no connection"). It is `return`ed via `Either.Left`.
- The repository is the **only** place that translates between them. This isolation is what makes the domain layer pure Dart with no `try/catch` noise.

**Why `Either<Failure, T>` instead of throwing through the stack?**
- Exceptions are invisible in the type signature — `Future<List<Task>>` lies about its real return shape. `Future<Either<Failure, List<Task>>>` tells the truth.
- ViewModels can pattern-match without `try/catch`, so error handling becomes uniform and testable.
- We use the `dartz` package for `Either`.

This way, when you swap Dio for `http`, or REST for GraphQL, only the data layer changes — and when a new failure type appears (e.g. `CacheFailure`), the compiler tells you every place that needs to handle it.

---

## 2. Project Folder Structure

```
lib/
├── main.dart
├── firebase_options.dart                          # generated by flutterfire configure
├── core/
│   ├── app/
│   │   └── app.dart                               # MaterialApp.router root
│   ├── errors/
│   │   ├── exceptions.dart                        # AppException + subclasses (thrown by data layer)
│   │   └── failures.dart                          # Failure + subclasses (returned by domain layer)
│   ├── network/
│   │   ├── app_api_endpoints.dart                 # All URLs in one place
│   │   └── app_dio_client.dart                    # Singleton Dio factory + interceptors
│   ├── notifications/
│   │   ├── fcm_service.dart                       # Remote push (FCM)
│   │   ├── local_notification_service.dart
│   │   └── notification_payload.dart              # parses {type, taskId, route}
│   ├── router/
│   │   ├── app_router.dart                        # GoRouter config (Riverpod provider)
│   │   ├── app_routes_names.dart                  # route name constants
│   │   └── app_routes_path.dart                   # route path constants
│   ├── usecase/
│   │   └── usecase.dart                           # UseCase<Result, Params> + NoParams
│   └── utils/
│       └── enums/
│           └── task_enums.dart                    # TaskPriority, TaskStatus + fromApi()
├── features/
│   ├── task/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── remote/
│   │   │   │       └── task_remote_datasource.dart  # throws AppException
│   │   │   ├── models/
│   │   │   │   └── task_dto.dart                    # JSON ↔ DTO ↔ Entity
│   │   │   └── repositories/
│   │   │       └── task_repository_impl.dart        # catches → Left(Failure)
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── task_entity.dart                 # pure Dart
│   │   │   ├── repositories/
│   │   │   │   └── task_repository.dart             # abstract, Either<Failure, T>
│   │   │   └── usecases/
│   │   │       ├── get_tasks.dart
│   │   │       ├── get_task_by_id.dart
│   │   │       ├── add_task.dart
│   │   │       ├── update_task.dart
│   │   │       └── delete_task.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── task_providers.dart              # Riverpod DI
│   │       ├── viewmodels/
│   │       │   ├── tasks_list_viewmodel.dart
│   │       │   └── task_details_viewmodel.dart
│   │       └── views/
│   │           ├── tasks_list_view.dart
│   │           └── task_details_view.dart
│   └── devices/
│       └── data/
│           └── datasources/
│               └── remote/
│                   └── device_remote_datasource.dart  # POST /devices
test/
├── core/
│   └── notifications/
│       └── notification_payload_test.dart
├── features/
│   └── task/
│       ├── data/
│       │   └── task_repository_impl_test.dart       # tests exception → Failure mapping
│       ├── domain/
│       │   └── usecases/
│       │       └── get_tasks_test.dart
│       └── presentation/
│           └── tasks_list_viewmodel_test.dart
└── widget/
    └── tasks_list_view_test.dart
```

---

## Step 1 — Add Dependencies

Edit `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State management
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # Networking
  dio: ^5.7.0

  # Routing
  go_router: ^14.6.2

  # Firebase / FCM
  firebase_core: ^3.6.0
  firebase_messaging: ^15.1.3

  # Local notifications (foreground + tap handling fallback)
  flutter_local_notifications: ^17.2.3

  # Functional error handling (Either<Failure, T>)
  dartz: ^0.10.1

  # Utilities
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0
  equatable: ^2.0.5

dev_dependencies:
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.4
  build_runner: ^2.4.13
  freezed: ^2.5.7
  json_serializable: ^6.8.0
  riverpod_generator: ^2.4.3
  custom_lint: ^0.6.4
  riverpod_lint: ^2.3.13
```

Then:
```bash
flutter pub get
```

**Why each one:**
- **`flutter_riverpod`** — DI + reactive state, our backbone for MVVM.
- **`dio`** — interceptors, cancellation, FormData; richer than `http`.
- **`go_router`** — declarative routing with deep-link support — exactly what we need to redirect from a tapped notification to a specific screen.
- **`firebase_messaging`** — receives FCM pushes.
- **`flutter_local_notifications`** — FCM does **not** show a banner when the app is in the **foreground**; we render those ourselves with this package.
- **`dartz`** — gives us `Either<L, R>`. The repository returns `Either<Failure, T>` instead of throwing, so the type signature itself documents the error path. ViewModels then `fold` over the result — no `try/catch` in the domain or presentation layers.
- **`equatable`** — value equality for entities and failures (used in `==` and in tests).
- **`freezed`** — concise immutable models with `copyWith` for ViewModel states.
- **`mocktail`** — mocking without code generation, for tests.

---

## Step 2 — Firebase Project Setup

1. Use the **same Firebase project** as the Rust backend.
2. Run the FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   This generates `lib/firebase_options.dart` and adds platform config files.
3. Confirm it added:
   - **Android:** `android/app/google-services.json`
   - **iOS:** `ios/Runner/GoogleService-Info.plist`

---

## Step 3 — Android Native Configuration

### `android/build.gradle`
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.2'
    }
}
```

### `android/app/build.gradle`
```gradle
plugins {
    id "com.android.application"
    id "com.google.gms.google-services" // ← add this
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
}

android {
    defaultConfig {
        minSdkVersion 21   // FCM requires ≥ 19; 21+ is safe
    }
}
```

### `android/app/src/main/AndroidManifest.xml`
Inside `<application>`:

```xml
<!-- Default notification icon (status bar) -->
<meta-data
    android:name="com.google.firebase.messaging.default_notification_icon"
    android:resource="@drawable/ic_notification" />

<!-- Default notification color (tinting on Android 5+) -->
<meta-data
    android:name="com.google.firebase.messaging.default_notification_color"
    android:resource="@color/notification_color" />

<!-- Default channel for system-displayed notifications -->
<meta-data
    android:name="com.google.firebase.messaging.default_notification_channel_id"
    android:value="task_updates" />
```

> The `channel_id = "task_updates"` **must match** the channel ID the Rust backend sets in its FCM payload (`android.notification.channel_id`). They must also match the channel we create in Dart with `flutter_local_notifications`.

Also ensure `INTERNET` and `POST_NOTIFICATIONS` permissions:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

### Define the color
`android/app/src/main/res/values/colors.xml`:
```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="notification_color">#2196F3</color>
</resources>
```

---

## Step 4 — iOS Native Configuration

1. Open `ios/Runner.xcworkspace` in Xcode.
2. **Signing & Capabilities** → **+ Capability** → add:
   - **Push Notifications**
   - **Background Modes** → check **Remote notifications**.
3. Upload your **APNs Auth Key** to the Firebase console (Project Settings → Cloud Messaging → Apple app config).
4. Edit `ios/Runner/Info.plist` to add a notification permission rationale (optional but recommended for App Store).

> iOS uses the **app icon** for the notification by default (you can't override the small icon like on Android). For a custom **large icon** in the expanded notification, see Step 5.

---

## Step 5 — Notification Icons (Status Bar)

This is the part that catches everyone out. Two distinct icons matter:

### A) The **system-pushed** notification icon (when FCM displays it directly)

- **Android requirement:** the small icon in the status bar **must be a white-on-transparent silhouette**. Anything with color will render as a white square.
- Generate it from a 1024×1024 PNG with the [Android Asset Studio — Notification icons](https://romannurik.github.io/AndroidAssetStudio/icons-notification.html).
- Drop the generated `ic_notification.png` files into:
  ```
  android/app/src/main/res/drawable-mdpi/ic_notification.png    (24×24)
  android/app/src/main/res/drawable-hdpi/ic_notification.png    (36×36)
  android/app/src/main/res/drawable-xhdpi/ic_notification.png   (48×48)
  android/app/src/main/res/drawable-xxhdpi/ic_notification.png  (72×72)
  android/app/src/main/res/drawable-xxxhdpi/ic_notification.png (96×96)
  ```
- The manifest entry from Step 3 (`@drawable/ic_notification`) makes Android use it for **all** FCM-rendered notifications.

### B) The **local** notification icon (for in-app foreground alerts)

When the app is in the foreground, FCM does **not** show a banner. We render one ourselves with `flutter_local_notifications` — and it can use a **different icon**:

```dart
const androidDetails = AndroidNotificationDetails(
  'task_updates',
  'Task Updates',
  channelDescription: 'Notifications about task changes',
  importance: Importance.max,
  priority: Priority.high,
  icon: 'ic_notification_local',     // ← different drawable, optional
  color: Color(0xFF2196F3),
  largeIcon: DrawableResourceAndroidBitmap('ic_launcher'), // expanded large icon
);
```

If you want the local-only icon to differ from the FCM one, generate `ic_notification_local.png` the same way and place it under `android/app/src/main/res/drawable-*/`. Otherwise reuse `ic_notification`.

> **iOS:** local notifications use the **app icon**. The `largeIcon`/`icon` fields are Android-only.

---

## Step 6 — App Bootstrap

`lib/main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/notifications/local_notification_service.dart';
import 'firebase_options.dart';

/// MUST be a top-level function (not a method) and annotated.
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Background isolate has no UI — keep this minimal. We rely on the system
  // tray notification (FCM payload's `notification` block) to be shown by Android.
  // No need to call flutter_local_notifications here unless you want custom UI.
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
  await LocalNotificationService.instance.init();

  runApp(const ProviderScope(child: TaskApp()));
}
```

`lib/app.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';

class TaskApp extends ConsumerWidget {
  const TaskApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Tasks',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      routerConfig: router,
    );
  }
}
```

**Why `ProviderScope` at the very top?** Riverpod requires it to host all providers. Anything deeper can `ref.watch` / `ref.read` freely.

---

## Step 7 — API Endpoints & Dio Client

### `lib/core/network/app_api_endpoints.dart`

```dart
class AppApiEndpoints {
  AppApiEndpoints._();
  static const String baseUrl =
      'http://10.0.2.2:3000'; // localhost for Android emulator

  static const String getTasks = '$baseUrl/tasks';
  static const String createTask = '$baseUrl/tasks';
  static String getTasksById(String id) => '$baseUrl/tasks/$id';
  static String deleteTask(String id) => '$baseUrl/tasks/$id';
  static String updateTask(String id) => '$baseUrl/tasks/$id';

  // Device registration for FCM
  static const String registerDevice = '$baseUrl/devices';
}
```

> All endpoints live in **one** file. If the backend renames `/tasks` → `/v2/tasks`, you change one constant. Never hardcode a URL inside a datasource.

### `lib/core/network/app_dio_client.dart`

A **private-constructor singleton** that builds a configured `Dio` instance. Datasources don't reach for it directly — they receive a `Dio` via constructor injection, so tests can pass a mocked one.

```dart
import 'package:dio/dio.dart';

class AppDioClient {
  AppDioClient._();
  static final instance = AppDioClient._();

  Dio create() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
        headers: {'content-type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true),
    );
    return dio;
  }
}
```

> **Common mistakes (read these — they will save you 20 minutes):**
> - `AppDioClient.instance` returns the singleton; `instance.create()` returns the **`Dio`**. The datasource holds the `Dio`, not the `AppDioClient`.
> - `instance` is a **static** member — access it through the **class** (`AppDioClient.instance`), never through an instance variable. `someAppDioClient.instance` is a compile error: *"The static getter 'instance' can't be accessed through an instance."*
> - `AppDioClient` has **no** `.get()` / `.post()` methods of its own. HTTP verbs live on `Dio`, not on the factory. Call `create().get(...)` once and store the returned `Dio`, then call `dio.get(...)` from there.

We expose the `Dio` via a Riverpod provider (see Step 12) so the rest of the app gets it through DI:

```dart
final dioProvider = Provider<Dio>((ref) => AppDioClient.instance.create());
```

---

## Step 8 — Core Building Blocks (Errors + UseCase base)

Before the domain layer, we set up three core files used everywhere downstream.

### `lib/core/errors/exceptions.dart` — what the DataSource throws

```dart
/// Base exception class for all custom exceptions.
/// Implemented (not extended) because Exception is a marker interface.
abstract class AppException implements Exception {
  const AppException(this.message);
  final String message;
}

/// Thrown when the server returns an error response (non-2xx).
class ServerException extends AppException {
  const ServerException([super.message = 'Server error occurred']);
}

/// Thrown when there is no internet connection / DNS / socket error.
class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection']);
}

/// Thrown when payload validation fails (e.g. missing required field on parse).
class ValidationException extends AppException {
  const ValidationException([super.message = 'Validation failed']);
}
```

### `lib/core/errors/failures.dart` — what the Repository returns

```dart
import 'package:equatable/equatable.dart';

/// Base failure class — extends Equatable for value equality in tests.
abstract class Failure extends Equatable {
  const Failure(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error occurred']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation failed']);
}

/// Catch-all for anything we did not anticipate.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Unexpected error occurred']);
}
```

**The pairing is intentional**: every `XxxException` thrown by the data layer has an `XxxFailure` it maps to in the repository. Adding a new error case is a two-file change.

### `lib/core/usecase/usecase.dart` — the generic UseCase contract

```dart
import 'package:dartz/dartz.dart';
import 'package:flutter_pulse_app/core/errors/failures.dart';

/// Base class for all use cases.
/// [Result] is the success type. [Params] is the input.
abstract class UseCase<Result, Params> {
  Future<Either<Failure, Result>> call(Params params);
}

/// Sentinel for usecases that take no input (e.g. GetTasks).
class NoParams {
  const NoParams();
}
```

> **Why a base class?** It enforces the same shape everywhere (`Future<Either<Failure, T>>`), and lets you write higher-order helpers (logging decorators, retry wrappers) generically.

---

## Step 8b — Domain Layer

### Entity — `lib/features/task/domain/entities/task_entity.dart`

The entity is **pure Dart**. No `dart:io`, no Dio, no JSON. It's what the ViewModel and View see.

```dart
import 'package:equatable/equatable.dart';
import 'package:flutter_pulse_app/core/utils/enums/task_enums.dart';

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
  List<Object?> get props =>
      [id, title, description, priority, status, createdAt, completedAt];
}
```

### Enums — `lib/core/utils/enums/task_enums.dart`

The wire format is a String; the domain wants a typed enum. The enum owns the `fromApi` parsing because **the enum is the only place that knows its valid values** — keeping it here means a new variant is a one-file change.

```dart
enum TaskPriority {
  low, medium, high;

  static TaskPriority fromApi(String value) {
    switch (value) {
      case 'low':    return TaskPriority.low;
      case 'medium': return TaskPriority.medium;
      case 'high':   return TaskPriority.high;
      default: throw ArgumentError('Unknown priority: $value');
    }
  }
}

enum TaskStatus {
  pending, inProgress, completed;

  static TaskStatus fromApi(String value) {
    switch (value) {
      case 'pending':    return TaskStatus.pending;
      case 'inProgress': return TaskStatus.inProgress;
      case 'completed':  return TaskStatus.completed;
      default: throw ArgumentError('Unknown status: $value');
    }
  }
}
```

> The `ArgumentError` from `fromApi` is caught in the repository and mapped to `ValidationFailure` — an unknown enum value coming from the backend is a contract violation, not a user-visible bug.

### Repository contract — `lib/features/task/domain/repositories/task_repository.dart`

The contract is `Either<Failure, T>`. The domain layer **never** sees an exception.

```dart
import 'package:dartz/dartz.dart';
import 'package:flutter_pulse_app/core/errors/failures.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_entity.dart';

abstract class TaskRepository {
  Future<Either<Failure, List<TaskEntity>>> getTasks();
  Future<Either<Failure, TaskEntity>> getTaskById(String id);
  Future<Either<Failure, TaskEntity>> addTask(TaskEntity task);
  Future<Either<Failure, TaskEntity>> updateTask(TaskEntity task);
  Future<Either<Failure, void>> deleteTask(String id);
}
```

### UseCases

Each usecase is one verb. The ViewModel calls `GetTasks()(NoParams())` instead of reaching into the repository — this is what lets the ViewModel be tested without ever knowing about a `TaskRepository` (just stub the usecase).

`lib/features/task/domain/usecases/get_tasks.dart`:

```dart
import 'package:dartz/dartz.dart';
import 'package:flutter_pulse_app/core/errors/failures.dart';
import 'package:flutter_pulse_app/core/usecase/usecase.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_entity.dart';
import 'package:flutter_pulse_app/features/task/domain/repositories/task_repository.dart';

class GetTasks implements UseCase<List<TaskEntity>, NoParams> {
  final TaskRepository repository;
  GetTasks(this.repository);

  @override
  Future<Either<Failure, List<TaskEntity>>> call(NoParams params) {
    return repository.getTasks();
  }
}
```

`lib/features/task/domain/usecases/get_task_by_id.dart`:

```dart
import 'package:dartz/dartz.dart';
import 'package:flutter_pulse_app/core/errors/failures.dart';
import 'package:flutter_pulse_app/core/usecase/usecase.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_entity.dart';
import 'package:flutter_pulse_app/features/task/domain/repositories/task_repository.dart';

class GetTaskById implements UseCase<TaskEntity, String> {
  final TaskRepository repository;
  GetTaskById(this.repository);

  @override
  Future<Either<Failure, TaskEntity>> call(String id) {
    return repository.getTaskById(id);
  }
}
```

`lib/features/task/domain/usecases/add_task.dart`:

```dart
import 'package:dartz/dartz.dart';
import 'package:flutter_pulse_app/core/errors/failures.dart';
import 'package:flutter_pulse_app/core/usecase/usecase.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_entity.dart';
import 'package:flutter_pulse_app/features/task/domain/repositories/task_repository.dart';

class AddTask implements UseCase<TaskEntity, TaskEntity> {
  final TaskRepository repository;
  AddTask(this.repository);

  @override
  Future<Either<Failure, TaskEntity>> call(TaskEntity task) {
    return repository.addTask(task);
  }
}
```

`lib/features/task/domain/usecases/update_task.dart`:

```dart
import 'package:dartz/dartz.dart';
import 'package:flutter_pulse_app/core/errors/failures.dart';
import 'package:flutter_pulse_app/core/usecase/usecase.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_entity.dart';
import 'package:flutter_pulse_app/features/task/domain/repositories/task_repository.dart';

class UpdateTask implements UseCase<TaskEntity, TaskEntity> {
  final TaskRepository repository;
  UpdateTask(this.repository);

  @override
  Future<Either<Failure, TaskEntity>> call(TaskEntity task) {
    return repository.updateTask(task);
  }
}
```

`lib/features/task/domain/usecases/delete_task.dart`:

```dart
import 'package:dartz/dartz.dart';
import 'package:flutter_pulse_app/core/errors/failures.dart';
import 'package:flutter_pulse_app/core/usecase/usecase.dart';
import 'package:flutter_pulse_app/features/task/domain/repositories/task_repository.dart';

class DeleteTask implements UseCase<void, String> {
  final TaskRepository repository;
  DeleteTask(this.repository);

  @override
  Future<Either<Failure, void>> call(String id) {
    return repository.deleteTask(id);
  }
}
```

> **Are usecases overkill?** For a 5-screen CRUD app, you could call the repository directly from the ViewModel. We keep them because (a) they make the ViewModel test-stub one-liner instead of a full repository mock, and (b) they give business operations a name (`MarkTaskCompleted` reads better than `repo.updateTask(id, status: completed)`).

---

## Step 9 — Data Layer

The data layer's job is to talk to the wire and translate. It has **two strict rules**:

1. **The DataSource is allowed to throw `AppException`**. It is the ONLY place in the codebase that knows about HTTP status codes, socket errors, and JSON parsing.
2. **The Repository never throws and never returns a DTO.** It catches every `AppException`, maps it to a `Failure`, maps DTOs to entities, and returns `Either<Failure, Entity>`.

### DTO — `lib/features/task/data/models/task_dto.dart`

The DTO is a wire-format mirror. It owns `fromJson` / `toJson` and `toEntity`. The entity has **no** awareness of JSON — that asymmetry is the whole point.

```dart
import 'package:flutter_pulse_app/core/utils/enums/task_enums.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_entity.dart';

class TaskDto {
  final String id;
  final String title;
  final String description;
  final String priority;   // "low" | "medium" | "high"
  final String status;     // "pending" | "inProgress" | "completed"
  final String createdAt;  // ISO string
  final String? completedAt;

  TaskDto({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.createdAt,
    this.completedAt,
  });

  factory TaskDto.fromJson(Map<String, dynamic> json) => TaskDto(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        priority: json['priority'] as String,
        status: json['status'] as String,
        createdAt: json['createdAt'] as String,
        completedAt: json['completedAt'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'priority': priority,
        'status': status,
        'createdAt': createdAt,
        'completedAt': completedAt,
      };

  TaskEntity toEntity() => TaskEntity(
        id: id,
        title: title,
        description: description,
        priority: TaskPriority.fromApi(priority),
        status: TaskStatus.fromApi(status),
        createdAt: DateTime.parse(createdAt),
        completedAt: completedAt != null ? DateTime.parse(completedAt!) : null,
      );
}
```

> The Rust backend serializes JSON with `camelCase` (per `PROJECT_OVERVIEW.md`), so it's `createdAt` / `completedAt`, **not** `created_at`.

### DataSource — `lib/features/task/data/datasources/remote/task_remote_datasource.dart`

The interface is split from the implementation so the repository depends on the abstraction, and tests can swap in a mock without touching Dio.

```dart
import 'package:dio/dio.dart';
import 'package:flutter_pulse_app/core/errors/exceptions.dart';
import 'package:flutter_pulse_app/core/network/app_api_endpoints.dart';
import 'package:flutter_pulse_app/features/task/data/models/task_dto.dart';

abstract class TaskRemoteDataSource {
  Future<List<TaskDto>> getTasks();
  Future<TaskDto> getTaskById(String id);
  Future<TaskDto> createTask(TaskDto task);
  Future<TaskDto> updateTask(String id, TaskDto task);
  Future<void> deleteTask(String id);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final Dio dio;
  TaskRemoteDataSourceImpl(this.dio);

  @override
  Future<List<TaskDto>> getTasks() async {
    try {
      final res = await dio.get(AppApiEndpoints.getTasks);
      return (res.data as List)
          .map((e) => TaskDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapDioError(e);
    } catch (_) {
      throw const ValidationException('Failed to parse tasks response');
    }
  }

  @override
  Future<TaskDto> getTaskById(String id) async {
    try {
      final res = await dio.get(AppApiEndpoints.getTasksById(id));
      return TaskDto.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioError(e);
    } catch (_) {
      throw const ValidationException('Failed to parse task response');
    }
  }

  @override
  Future<TaskDto> createTask(TaskDto task) async {
    try {
      final res = await dio.post(AppApiEndpoints.createTask, data: task.toJson());
      return TaskDto.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioError(e);
    } catch (_) {
      throw const ValidationException('Failed to parse create response');
    }
  }

  @override
  Future<TaskDto> updateTask(String id, TaskDto task) async {
    try {
      final res = await dio.put(AppApiEndpoints.updateTask(id), data: task.toJson());
      return TaskDto.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioError(e);
    } catch (_) {
      throw const ValidationException('Failed to parse update response');
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    try {
      await dio.delete(AppApiEndpoints.deleteTask(id));
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  /// Translate Dio's error taxonomy into our [AppException] hierarchy.
  /// This is the only place that knows what a DioException is.
  AppException _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.badResponse:
        return ServerException(
          'Server error: ${e.response?.statusCode ?? "unknown"}',
        );
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return ServerException(e.message ?? 'Unknown server error');
    }
  }
}
```

> **The pattern:** `try` → call Dio → on `DioException`, translate to our domain-friendly `AppException`. **Never** let a `DioException` escape the data layer — that would force every layer above to import Dio.

### Repository impl — `lib/features/task/data/repositories/task_repository_impl.dart`

This is where exceptions become failures. Notice: **zero** awareness of HTTP, Dio, or JSON. It just calls the datasource, catches by exception type, maps to the matching failure, and folds DTOs into entities.

```dart
import 'package:dartz/dartz.dart';
import 'package:flutter_pulse_app/core/errors/exceptions.dart';
import 'package:flutter_pulse_app/core/errors/failures.dart';
import 'package:flutter_pulse_app/core/utils/enums/task_enums.dart';
import 'package:flutter_pulse_app/features/task/data/datasources/remote/task_remote_datasource.dart';
import 'package:flutter_pulse_app/features/task/data/models/task_dto.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_entity.dart';
import 'package:flutter_pulse_app/features/task/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;
  TaskRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<TaskEntity>>> getTasks() async {
    return _guard(() async {
      final dtos = await remoteDataSource.getTasks();
      return dtos.map((d) => d.toEntity()).toList();
    });
  }

  @override
  Future<Either<Failure, TaskEntity>> getTaskById(String id) async {
    return _guard(() async {
      final dto = await remoteDataSource.getTaskById(id);
      return dto.toEntity();
    });
  }

  @override
  Future<Either<Failure, TaskEntity>> addTask(TaskEntity task) async {
    return _guard(() async {
      final dto = await remoteDataSource.createTask(_toDto(task));
      return dto.toEntity();
    });
  }

  @override
  Future<Either<Failure, TaskEntity>> updateTask(TaskEntity task) async {
    return _guard(() async {
      final dto = await remoteDataSource.updateTask(task.id, _toDto(task));
      return dto.toEntity();
    });
  }

  @override
  Future<Either<Failure, void>> deleteTask(String id) async {
    return _guard(() => remoteDataSource.deleteTask(id));
  }

  /// Single source of truth for exception → failure mapping.
  /// Every public method runs through this — no duplicated try/catch.
  Future<Either<Failure, T>> _guard<T>(Future<T> Function() body) async {
    try {
      final result = await body();
      return Right(result);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  /// Bridge from domain entity → wire DTO when sending writes.
  TaskDto _toDto(TaskEntity t) => TaskDto(
        id: t.id,
        title: t.title,
        description: t.description,
        priority: t.priority.name,
        status: t.status.name,
        createdAt: t.createdAt.toIso8601String(),
        completedAt: t.completedAt?.toIso8601String(),
      );
}
```

> **Why the `_guard` helper?** Five methods with identical try/catch blocks is five places to forget a case when a new exception type is added. With `_guard`, adding `CacheException → CacheFailure` is one new `on` clause.

### Device datasource — `lib/features/devices/data/datasources/remote/device_remote_datasource.dart`

Same pattern, smaller surface — used by the FCM service to register the push token.

```dart
import 'package:dio/dio.dart';
import 'package:flutter_pulse_app/core/errors/exceptions.dart';
import 'package:flutter_pulse_app/core/network/app_api_endpoints.dart';

abstract class DeviceRemoteDataSource {
  Future<void> register({required String token, required String platform});
}

class DeviceRemoteDataSourceImpl implements DeviceRemoteDataSource {
  final Dio dio;
  DeviceRemoteDataSourceImpl(this.dio);

  @override
  Future<void> register({required String token, required String platform}) async {
    try {
      await dio.post(
        AppApiEndpoints.registerDevice,
        data: {'token': token, 'platform': platform},
      );
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Device registration failed');
    }
  }
}
```

---

## Step 10 — FCM Service (Remote Push)

`lib/core/notifications/notification_payload.dart`:

```dart
class NotificationPayload {
  final String? type;
  final String? taskId;
  final String? route;

  NotificationPayload({this.type, this.taskId, this.route});

  factory NotificationPayload.fromMap(Map<String, dynamic> data) {
    return NotificationPayload(
      type: data['type'] as String?,
      taskId: data['taskId'] as String?,
      route: data['route'] as String?,
    );
  }
}
```

`lib/core/notifications/fcm_service.dart`:

```dart
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../features/devices/data/device_remote_datasource.dart';
import 'local_notification_service.dart';
import 'notification_payload.dart';

typedef NotificationTapHandler = void Function(NotificationPayload payload);

class FcmService {
  final FirebaseMessaging _messaging;
  final DeviceRemoteDataSource _devices;
  final LocalNotificationService _local;

  FcmService({
    required FirebaseMessaging messaging,
    required DeviceRemoteDataSource devices,
    required LocalNotificationService local,
  })  : _messaging = messaging,
        _devices = devices,
        _local = local;

  /// Call once after the app starts and the user is "ready" for push.
  Future<void> bootstrap({required NotificationTapHandler onTap}) async {
    // 1. Ask permission (iOS + Android 13+)
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    // 2. Get the FCM token and register it on the backend.
    final token = await _messaging.getToken();
    if (token != null) {
      await _registerToken(token);
    }
    _messaging.onTokenRefresh.listen(_registerToken);

    // 3. Foreground messages → render via local notifications.
    FirebaseMessaging.onMessage.listen((msg) {
      final n = msg.notification;
      if (n != null) {
        _local.show(
          title: n.title ?? 'Update',
          body: n.body ?? '',
          payload: NotificationPayload.fromMap(msg.data),
        );
      }
    });

    // 4. Tap on a notification while app is in background and brought back.
    FirebaseMessaging.onMessageOpenedApp.listen((msg) {
      onTap(NotificationPayload.fromMap(msg.data));
    });

    // 5. App opened from a terminated state by tapping a push.
    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      onTap(NotificationPayload.fromMap(initial.data));
    }

    // 6. Local notification tap (foreground case from step 3).
    _local.onTap = onTap;
  }

  Future<void> _registerToken(String token) async {
    try {
      final platform = Platform.isAndroid ? 'android' : Platform.isIOS ? 'ios' : 'web';
      await _devices.register(token: token, platform: platform);
    } catch (e) {
      debugPrint('FCM token registration failed: $e');
    }
  }
}
```

**The four notification states explained:**

| State                        | Who shows the banner?           | How we know about it                       |
|------------------------------|---------------------------------|--------------------------------------------|
| App in **foreground**        | **We do** (local notif)         | `onMessage`                                |
| App in **background**, tapped| OS shows it from FCM payload    | `onMessageOpenedApp`                       |
| App **terminated**, tapped   | OS shows it from FCM payload    | `getInitialMessage` (called on startup)    |
| App **terminated**, not tapped| OS shows it from FCM payload   | We never get notified — that's normal      |

---

## Step 11 — Local Notification Service

`lib/core/notifications/local_notification_service.dart`:

```dart
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'notification_payload.dart';

class LocalNotificationService {
  LocalNotificationService._();
  static final instance = LocalNotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  void Function(NotificationPayload payload)? onTap;

  Future<void> init() async {
    const android = AndroidInitializationSettings('ic_notification_local');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (resp) {
        if (resp.payload == null) return;
        final map = jsonDecode(resp.payload!) as Map<String, dynamic>;
        onTap?.call(NotificationPayload.fromMap(map));
      },
    );

    // Create the channel — must match `task_updates` used by FCM payload.
    const channel = AndroidNotificationChannel(
      'task_updates',
      'Task Updates',
      description: 'Notifications about task changes',
      importance: Importance.high,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> show({
    required String title,
    required String body,
    required NotificationPayload payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'task_updates',
      'Task Updates',
      channelDescription: 'Notifications about task changes',
      importance: Importance.max,
      priority: Priority.high,
      icon: 'ic_notification_local',     // local in-app icon
    );
    const iosDetails = DarwinNotificationDetails();

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: jsonEncode({
        'type': payload.type,
        'taskId': payload.taskId,
        'route': payload.route,
      }),
    );
  }
}
```

> **Channel-ID rule of three:** the Rust backend, the AndroidManifest.xml `default_notification_channel_id`, and this `AndroidNotificationChannel('task_updates', ...)` must all be the string `task_updates`. Mismatches silently route notifications to the wrong (or no) channel.

---

## Step 12 — Riverpod Providers (Dependency Injection)

Providers are how Clean Architecture's "the outer layers depend on the inner ones" actually happens at runtime. Each provider wires a concrete impl into the abstraction the layer above asks for.

`lib/features/task/presentation/providers/task_providers.dart`:

```dart
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_pulse_app/core/network/app_dio_client.dart';
import 'package:flutter_pulse_app/core/notifications/fcm_service.dart';
import 'package:flutter_pulse_app/core/notifications/local_notification_service.dart';

import 'package:flutter_pulse_app/features/devices/data/datasources/remote/device_remote_datasource.dart';
import 'package:flutter_pulse_app/features/task/data/datasources/remote/task_remote_datasource.dart';
import 'package:flutter_pulse_app/features/task/data/repositories/task_repository_impl.dart';
import 'package:flutter_pulse_app/features/task/domain/repositories/task_repository.dart';
import 'package:flutter_pulse_app/features/task/domain/usecases/add_task.dart';
import 'package:flutter_pulse_app/features/task/domain/usecases/delete_task.dart';
import 'package:flutter_pulse_app/features/task/domain/usecases/get_task_by_id.dart';
import 'package:flutter_pulse_app/features/task/domain/usecases/get_tasks.dart';
import 'package:flutter_pulse_app/features/task/domain/usecases/update_task.dart';

// ─── Core ────────────────────────────────────────────────────────────────────
final dioProvider = Provider<Dio>((ref) => AppDioClient.instance.create());

// ─── Task — data layer ───────────────────────────────────────────────────────
final taskRemoteDataSourceProvider = Provider<TaskRemoteDataSource>(
  (ref) => TaskRemoteDataSourceImpl(ref.watch(dioProvider)),
);

final taskRepositoryProvider = Provider<TaskRepository>(
  (ref) => TaskRepositoryImpl(
    remoteDataSource: ref.watch(taskRemoteDataSourceProvider),
  ),
);

// ─── Task — usecases ─────────────────────────────────────────────────────────
final getTasksUseCaseProvider = Provider(
  (ref) => GetTasks(ref.watch(taskRepositoryProvider)),
);
final getTaskByIdUseCaseProvider = Provider(
  (ref) => GetTaskById(ref.watch(taskRepositoryProvider)),
);
final addTaskUseCaseProvider = Provider(
  (ref) => AddTask(ref.watch(taskRepositoryProvider)),
);
final updateTaskUseCaseProvider = Provider(
  (ref) => UpdateTask(ref.watch(taskRepositoryProvider)),
);
final deleteTaskUseCaseProvider = Provider(
  (ref) => DeleteTask(ref.watch(taskRepositoryProvider)),
);

// ─── Devices ─────────────────────────────────────────────────────────────────
final deviceRemoteDataSourceProvider = Provider<DeviceRemoteDataSource>(
  (ref) => DeviceRemoteDataSourceImpl(ref.watch(dioProvider)),
);

// ─── FCM ─────────────────────────────────────────────────────────────────────
final fcmServiceProvider = Provider<FcmService>((ref) {
  return FcmService(
    messaging: FirebaseMessaging.instance,
    devices: ref.watch(deviceRemoteDataSourceProvider),
    local: LocalNotificationService.instance,
  );
});
```

> **The dependency chain is one-way:** ViewModels watch usecases, usecases hold a repository, the repository holds a datasource, the datasource holds a `Dio`. To mock for tests, you `override` any provider in this chain — the layers above will transparently receive the mock.

---

## Step 13 — ViewModel (MVVM)

The ViewModel is the **error-handling boundary on the UI side**. It calls a usecase (which returns `Either<Failure, T>`), then folds the `Either` into Riverpod's `AsyncValue<T>` so the View can use `.when(data:, loading:, error:)` without ever seeing a `Failure`.

`lib/features/task/presentation/viewmodels/tasks_list_viewmodel.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pulse_app/core/usecase/usecase.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_entity.dart';
import 'package:flutter_pulse_app/features/task/presentation/providers/task_providers.dart';

class TasksListViewModel extends AsyncNotifier<List<TaskEntity>> {
  @override
  Future<List<TaskEntity>> build() async => _load();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> addTask(TaskEntity task) async {
    final result = await ref.read(addTaskUseCaseProvider).call(task);
    // fold(onLeft, onRight) — Left is Failure, Right is the new TaskEntity.
    result.fold(
      (failure) => state = AsyncError(failure, StackTrace.current),
      (_) => refresh(),
    );
  }

  Future<void> markCompleted(TaskEntity task) async {
    final updated = TaskEntity(
      id: task.id,
      title: task.title,
      description: task.description,
      priority: task.priority,
      status: TaskStatus.completed,
      createdAt: task.createdAt,
      completedAt: DateTime.now(),
    );
    final result = await ref.read(updateTaskUseCaseProvider).call(updated);
    result.fold(
      (failure) => state = AsyncError(failure, StackTrace.current),
      (_) => refresh(),
    );
  }

  Future<void> delete(String id) async {
    final result = await ref.read(deleteTaskUseCaseProvider).call(id);
    result.fold(
      (failure) => state = AsyncError(failure, StackTrace.current),
      (_) => refresh(),
    );
  }

  /// Single helper that converts `Either<Failure, T>` to a Future<T>
  /// (throwing the failure for AsyncValue.guard to catch).
  Future<List<TaskEntity>> _load() async {
    final result = await ref.read(getTasksUseCaseProvider).call(const NoParams());
    return result.fold(
      (failure) => throw failure,
      (tasks) => tasks,
    );
  }
}

final tasksListViewModelProvider =
    AsyncNotifierProvider<TasksListViewModel, List<TaskEntity>>(
  TasksListViewModel.new,
);
```

**Reading the fold pattern:**
- `Right(value)` → success path → update state to `AsyncData` or trigger a refresh.
- `Left(failure)` → failure path → either `throw` it (so `AsyncValue.guard` catches it into `AsyncError`) or set `AsyncError` directly.

The `Failure` itself ends up in `AsyncError.error`, so the View can `switch` on its runtime type to render different copy ("No internet" vs "Server is down") instead of one generic error message.

`lib/features/task/presentation/viewmodels/task_details_viewmodel.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_entity.dart';
import 'package:flutter_pulse_app/features/task/presentation/providers/task_providers.dart';

final taskDetailsViewModelProvider =
    FutureProvider.family<TaskEntity, String>((ref, id) async {
  final result = await ref.watch(getTaskByIdUseCaseProvider).call(id);
  return result.fold(
    (failure) => throw failure,
    (task) => task,
  );
});
```

**Why `AsyncNotifier` for the list and `FutureProvider.family` for details?** The list needs imperative methods (`addTask`, `delete`, `refresh`); `AsyncNotifier` exposes those. The details view is pure read-by-id; `FutureProvider.family` is a one-liner for that pattern.

---

## Step 14 — GoRouter with Notification Deep Link

`lib/core/router/app_routes.dart`:

```dart
class AppRoutes {
  static const tasksList = '/';
  static const taskDetails = '/task-details';   // ← matches backend payload's `route`
}
```

`lib/core/router/app_router.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/tasks/presentation/views/task_details_view.dart';
import '../../features/tasks/presentation/views/tasks_list_view.dart';
import '../notifications/fcm_service.dart';
import '../notifications/notification_payload.dart';
import '../../features/tasks/presentation/providers/task_providers.dart';
import 'app_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.tasksList,
    routes: [
      GoRoute(
        path: AppRoutes.tasksList,
        builder: (_, __) => const TasksListView(),
      ),
      GoRoute(
        path: AppRoutes.taskDetails,
        builder: (_, state) {
          final id = state.uri.queryParameters['id']!;
          return TaskDetailsView(taskId: id);
        },
      ),
    ],
  );

  // Bootstrap FCM ONCE the router exists, so taps can navigate.
  ref.read(fcmServiceProvider).bootstrap(
    onTap: (NotificationPayload p) {
      final route = p.route;
      final id = p.taskId;
      if (route == null) return;
      if (id != null) {
        router.go('$route?id=$id');
      } else {
        router.go(route);
      }
    },
  );

  return router;
});
```

**Deep-link flow when a notification is tapped:**

1. Backend sends `data: { route: "/task-details", taskId: "uuid", ... }`.
2. Flutter receives it via `onMessageOpenedApp` (or `getInitialMessage` if cold-started).
3. The `onTap` callback in `appRouterProvider` calls `router.go('/task-details?id=<uuid>')`.
4. GoRouter renders `TaskDetailsView(taskId: '<uuid>')`, which uses `taskDetailsViewModelProvider(id)` to fetch & display.

The router and FCM are **decoupled** — FCM only knows "call this callback with a payload", and the router decides what to do.

---

## Step 15 — Views (UI Layer)

`lib/features/tasks/presentation/views/tasks_list_view.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../viewmodels/tasks_list_viewmodel.dart';

class TasksListView extends ConsumerWidget {
  const TasksListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tasksListViewModelProvider);
    final vm = ref.read(tasksListViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: state.when(
        data: (tasks) => RefreshIndicator(
          onRefresh: vm.refresh,
          child: ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (_, i) {
              final t = tasks[i];
              return ListTile(
                title: Text(t.title),
                subtitle: Text('${t.priority.name} · ${t.status.name}'),
                onTap: () => context.go('${AppRoutes.taskDetails}?id=${t.id}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => vm.delete(t.id),
                ),
              );
            },
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
```

`lib/features/tasks/presentation/views/task_details_view.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/task_details_viewmodel.dart';

class TaskDetailsView extends ConsumerWidget {
  final String taskId;
  const TaskDetailsView({super.key, required this.taskId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(taskDetailsViewModelProvider(taskId));
    return Scaffold(
      appBar: AppBar(title: const Text('Task Details')),
      body: state.when(
        data: (t) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(t.description),
              const SizedBox(height: 8),
              Text('Priority: ${t.priority.name}'),
              Text('Status: ${t.status.name}'),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
```

---

## Step 16 — Tests

We test three layers: pure logic (payload parsing), data layer (repository), and ViewModel.

### 16.1 Payload parsing — `test/core/notifications/notification_payload_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:task_app/core/notifications/notification_payload.dart';

void main() {
  group('NotificationPayload', () {
    test('parses all fields', () {
      final p = NotificationPayload.fromMap({
        'type': 'task_created',
        'taskId': 'abc-123',
        'route': '/task-details',
      });
      expect(p.type, 'task_created');
      expect(p.taskId, 'abc-123');
      expect(p.route, '/task-details');
    });

    test('handles missing fields gracefully', () {
      final p = NotificationPayload.fromMap({});
      expect(p.type, isNull);
      expect(p.taskId, isNull);
      expect(p.route, isNull);
    });
  });
}
```

### 16.2 Repository — `test/features/task/data/task_repository_impl_test.dart`

This is the **most important test in the whole stack** — it verifies the contract that exceptions thrown by the datasource become the correct typed failures.

```dart
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_pulse_app/core/errors/exceptions.dart';
import 'package:flutter_pulse_app/core/errors/failures.dart';
import 'package:flutter_pulse_app/features/task/data/datasources/remote/task_remote_datasource.dart';
import 'package:flutter_pulse_app/features/task/data/models/task_dto.dart';
import 'package:flutter_pulse_app/features/task/data/repositories/task_repository_impl.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_entity.dart';

class MockRemote extends Mock implements TaskRemoteDataSource {}

void main() {
  late MockRemote remote;
  late TaskRepositoryImpl repo;

  setUp(() {
    remote = MockRemote();
    repo = TaskRepositoryImpl(remoteDataSource: remote);
  });

  group('getTasks', () {
    test('maps DTOs to entities on success (Right)', () async {
      when(() => remote.getTasks()).thenAnswer((_) async => [
            TaskDto(
              id: '1',
              title: 't',
              description: 'd',
              priority: 'high',
              status: 'pending',
              createdAt: '2025-01-01T00:00:00Z',
            ),
          ]);

      final result = await repo.getTasks();

      expect(result, isA<Right<Failure, List<TaskEntity>>>());
      result.fold(
        (_) => fail('Expected Right'),
        (tasks) {
          expect(tasks, hasLength(1));
          expect(tasks.first.priority.name, 'high');
          expect(tasks.first.status.name, 'pending');
        },
      );
    });

    test('returns NetworkFailure when datasource throws NetworkException', () async {
      when(() => remote.getTasks()).thenThrow(const NetworkException());

      final result = await repo.getTasks();

      expect(result, equals(const Left<Failure, List<TaskEntity>>(NetworkFailure())));
    });

    test('returns ServerFailure when datasource throws ServerException', () async {
      when(() => remote.getTasks()).thenThrow(const ServerException('500'));

      final result = await repo.getTasks();

      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('returns UnexpectedFailure for any other throwable', () async {
      when(() => remote.getTasks()).thenThrow(Exception('boom'));

      final result = await repo.getTasks();

      result.fold(
        (failure) => expect(failure, isA<UnexpectedFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });
}
```

> **What this test actually defends:** the *mapping table*. If someone refactors `_guard` and forgets the `on NetworkException` clause, this test fails — which is exactly when you want it to.

### 16.2b UseCase — `test/features/task/domain/usecases/get_tasks_test.dart`

UseCase tests are trivial because the class is trivial — but they pin down the contract that "calling the usecase delegates to the repository". If you ever decorate usecases (logging, retry, analytics), this is where the regression shows up.

```dart
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_pulse_app/core/errors/failures.dart';
import 'package:flutter_pulse_app/core/usecase/usecase.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_entity.dart';
import 'package:flutter_pulse_app/features/task/domain/repositories/task_repository.dart';
import 'package:flutter_pulse_app/features/task/domain/usecases/get_tasks.dart';

class MockRepo extends Mock implements TaskRepository {}

void main() {
  test('GetTasks delegates to repository.getTasks', () async {
    final repo = MockRepo();
    final usecase = GetTasks(repo);
    when(() => repo.getTasks())
        .thenAnswer((_) async => const Right<Failure, List<TaskEntity>>([]));

    final result = await usecase(const NoParams());

    expect(result.isRight(), isTrue);
    verify(() => repo.getTasks()).called(1);
  });
}
```

### 16.3 ViewModel — `test/features/tasks/presentation/tasks_list_viewmodel_test.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_app/features/tasks/domain/entities/task.dart';
import 'package:task_app/features/tasks/domain/repositories/task_repository.dart';
import 'package:task_app/features/tasks/presentation/providers/task_providers.dart';
import 'package:task_app/features/tasks/presentation/viewmodels/tasks_list_viewmodel.dart';

class MockRepo extends Mock implements TaskRepository {}

void main() {
  late MockRepo repo;
  late ProviderContainer container;

  setUp(() {
    repo = MockRepo();
    container = ProviderContainer(
      overrides: [taskRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
  });

  test('loads tasks on build', () async {
    when(() => repo.getTasks()).thenAnswer((_) async => [
          Task(
            id: '1',
            title: 't',
            description: 'd',
            priority: TaskPriority.high,
            status: TaskStatus.pending,
            createdAt: DateTime.utc(2025),
          ),
        ]);

    final state = await container.read(tasksListViewModelProvider.future);
    expect(state, hasLength(1));
    verify(() => repo.getTasks()).called(1);
  });

  test('create then refresh calls getTasks twice', () async {
    when(() => repo.getTasks()).thenAnswer((_) async => []);
    when(() => repo.createTask(
          title: any(named: 'title'),
          description: any(named: 'description'),
          priority: any(named: 'priority'),
        )).thenAnswer((_) async => Task(
              id: '1',
              title: 't',
              description: 'd',
              priority: TaskPriority.low,
              status: TaskStatus.pending,
              createdAt: DateTime.utc(2025),
            ));

    await container.read(tasksListViewModelProvider.future);
    await container
        .read(tasksListViewModelProvider.notifier)
        .create(title: 't', description: 'd', priority: TaskPriority.low);

    verify(() => repo.getTasks()).called(2); // initial build + refresh
  });
}
```

### 16.4 Widget — `test/widget/tasks_list_view_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_app/features/tasks/domain/entities/task.dart';
import 'package:task_app/features/tasks/domain/repositories/task_repository.dart';
import 'package:task_app/features/tasks/presentation/providers/task_providers.dart';
import 'package:task_app/features/tasks/presentation/views/tasks_list_view.dart';

class MockRepo extends Mock implements TaskRepository {}

void main() {
  testWidgets('renders task titles', (tester) async {
    final repo = MockRepo();
    when(() => repo.getTasks()).thenAnswer((_) async => [
          Task(
            id: '1',
            title: 'Buy milk',
            description: '',
            priority: TaskPriority.medium,
            status: TaskStatus.pending,
            createdAt: DateTime.utc(2025),
          ),
        ]);

    await tester.pumpWidget(ProviderScope(
      overrides: [taskRepositoryProvider.overrideWithValue(repo)],
      child: const MaterialApp(home: TasksListView()),
    ));
    await tester.pump(); // resolve async build

    expect(find.text('Buy milk'), findsOneWidget);
  });
}
```

Run all tests:
```bash
flutter test
```

---

## Step 17 — Verifying End-to-End

1. **Start the Rust backend** (`cargo run`) — confirm logs show `listening on http://0.0.0.0:3000`.
2. **Run the app on Android emulator** (`flutter run`) — `10.0.2.2` in `app_api_endpoints.dart` resolves to host `localhost`.
3. App startup → permission dialog → token registered → check Postgres:
   ```sql
   SELECT id, platform, created_at FROM devices;
   ```
4. Trigger a task creation:
   ```bash
   curl -X POST http://localhost:3000/tasks \
     -H "Content-Type: application/json" \
     -d '{"title":"Hello","description":"From curl","priority":"high"}'
   ```
5. **App in foreground** → you'll see a local notification banner with `ic_notification_local`.
6. **App in background** → a system notification with `ic_notification` appears.
7. **Tap it** → app navigates to `/task-details?id=<uuid>` via GoRouter.

If anything fails, check this checklist:
- Did `task_updates` channel get created? (Settings → Apps → Task App → Notifications.)
- Is the small icon white-on-transparent? (Color icons render as a white square.)
- Did the device row appear in Postgres? (If not, network / permission problem.)
- Did the backend log a successful FCM POST? (If 404 INVALID_ARGUMENT, the token rotated — re-register.)

---

**Done.** You have a Clean-Architecture Flutter app with MVVM, Dio-backed REST, GoRouter deep-linking, and full FCM coverage across all four notification states — all properly tested.
