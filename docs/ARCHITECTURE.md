# Pulse architecture

This document is for engineers working on the Pulse Flutter app. It covers
how the code is organised, why it is organised that way, and the rules that
keep it consistent.

## 1. Overview

Pulse uses **feature-first Clean Architecture** with **Riverpod** for state
management and dependency injection.

- Each feature owns three layers: `data`, `domain` and `presentation`.
- Anything shared by several features lives in `core/`.
- All extensions and helpers live in `core/` (`core/extensions`,
  `core/helpers`), so features hold only their layers.
- The foundation of `core/` (errors, network, notifications, storage, theme,
  utils, widgets, helpers) never imports a feature. Where it needs something
  a feature provides, it declares an interface (a *port*), and the feature
  implements it; the two are wired together in `main.dart`.
- Two parts of `core/` are app-level glue and may reference feature types:
  `core/routing` (the router builds the feature pages) and the feature-type
  extensions in `core/extensions` (labels, icons and colours for task and
  settings enums).

```text
                ┌──────────────────────────────┐
  presentation  │ pages · widgets · controllers│  Flutter + Riverpod
                └──────────────┬───────────────┘
                               │ calls use cases
                ┌──────────────▼───────────────┐
  domain        │ entities · use cases ·       │  pure Dart
                │ repository interfaces        │  (no Flutter, no Dio)
                └──────────────▲───────────────┘
                               │ implements
                ┌──────────────┴───────────────┐
  data          │ DTOs · datasources ·         │  Dio, JSON
                │ repository implementations   │
                └──────────────────────────────┘
```

## 2. Folder structure

```text
lib/
├── main.dart                      # bootstrap only
├── app/pulse_app.dart             # root widget
├── core/
│   ├── config/app_env.dart        # API_BASE_URL, ENABLE_HTTP_LOGS
│   ├── constants/                 # design + content tokens (see §6)
│   ├── errors/                    # AppException → Failure → user message
│   ├── extensions/                # context, DateTime, String, animation, and
│   │                              # task / settings presentation (labels, icons…)
│   ├── helpers/                   # ActionFeedback (Either → snack bar glue)
│   ├── network/                   # Dio factory + provider, endpoints
│   ├── notifications/             # push flow behind interfaces (see §5)
│   ├── routing/                   # routes, router, navigation, resolver
│   ├── storage/                   # SharedPreferences provider
│   ├── theme/                     # AppTheme, AppTypography, AppSemanticColors
│   ├── usecase/usecase.dart       # UseCase<Result, Params>
│   ├── utils/                     # logger, clock, responsive, entrance tracker
│   └── widgets/                   # UI kit (see §6)
└── features/
    ├── task/
    │   ├── data/                  # TaskDto, datasource (+impl), repository impl
    │   ├── domain/                # TaskEntity, TaskStats, enums, TaskValidator, use cases
    │   └── presentation/
    │       ├── models/            # TaskFilter
    │       ├── providers/         # DI, controllers, selectors
    │       ├── pages/             # list, details, form
    │       └── widgets/           # card, badge, summary, skeletons…
    ├── device/                    # push-token registration
    ├── settings/                  # appearance mode + settings page
    └── shell/                     # bottom-nav shell + FadeIndexedStack
```

### File conventions

- One public class or widget per file. Small private helper widgets used
  only by that file (`_Header`, `_ChoicePill`) may live alongside it.
- Interfaces and their implementations live in separate files, for example
  `task_remote_datasource.dart` and `task_remote_datasource_impl.dart`.
- Always use package imports. Use plain names with no `custom_` prefixes.
- A widget moves to `core/widgets` only when it is feature-agnostic and
  reusable.

## 3. Layers and their rules

### Domain (pure Dart)

- **Entities** (`TaskEntity`) are immutable `Equatable` classes. Business
  rules that belong to the data itself live on the entity:
  - `TaskEntity.draft` builds a new, unsaved task.
  - `withStatus` keeps `completedAt` consistent with the status.
  - `copyWith` takes `completedAt` as a function, so the field can be
    cleared explicitly.
- **Validation** lives in `TaskValidator`, and the form fields and the use
  cases share the same rules. Messages are user-facing strings from
  `AppStrings`.
- **Use cases** perform one action per class. They validate first, then
  delegate to the repository interface and return `Either<Failure, T>`.
- Domain code never imports Flutter, Dio or Riverpod.

### Data

- **Datasources** call Dio and wrap every call in
  `AppErrorGuard.guardThrowing`, which turns Dio and parse errors into
  `AppException`s.
- **Repositories** map DTOs to entities and wrap calls in
  `AppErrorGuard.guardEither`, which turns `AppException`s into `Failure`s.
  Repositories never throw.
- **DTOs** own the wire format. Enums travel as their `name`, and dates as
  ISO-8601.

### Presentation

- Widgets are dumb: they render state and forward user intent. They contain
  no API calls, parsing or business rules.
- Controllers (`Notifier` / `AsyncNotifier`) call use cases and own the
  screen state.
- Dependencies come from providers. Nothing is constructed inside widgets.

## 4. State management (Riverpod)

The project uses plain providers with no code generation.

| Provider                                    | Kind                               | Lifetime | Purpose                            |
| ------------------------------------------- | ---------------------------------- | -------- | ---------------------------------- |
| `taskListControllerProvider`                | `AsyncNotifier`                    | app      | Single source of truth for tasks   |
| `taskDetailsControllerProvider(id)`         | `AsyncNotifier.autoDispose.family` | screen   | One task, for details and edit     |
| `taskFilterControllerProvider`              | `Notifier`                         | app      | Selected list filter               |
| `visibleTasksProvider`, `taskStatsProvider` | `Provider`                         | derived  | Filtered list and counts           |
| `appearanceModeControllerProvider`          | `Notifier`                         | app      | Theme preference (persisted)       |
| `pushNotificationServiceProvider`           | `Provider`                         | app      | Push flow; disposed with the scope |

### Conventions

- **Mutations return `Either` and never put the list into an error state.**
  `TaskListController._mutate` applies an optional optimistic update, rolls
  back on failure, and returns the failure. Screens pass that `Either` to
  `ActionFeedback.run` (`core/helpers`), which shows the friendly error or
  the success snack bar.
- **Refreshes keep current data on screen.** A failed refresh returns the
  failure, and only the initial load can produce an error state. Concurrent
  refreshes share one in-flight request.
- **Details sync from the list.** The details controller serves the cached
  task immediately, which makes the Hero transition smooth, then revalidates
  in the background. It also listens to list changes, so edits and status
  changes show up everywhere without a reload.
- Use `ref.watch` in `build` and `ref.read` in callbacks. Never call
  `ref.read` inside `build` for reactive data.
- Time comes from `clockProvider`, so tests are deterministic.

## 5. Push notifications

```text
FirebaseInitializer (main) ─▶ firebaseAvailableProvider
                                   │
PulseApp.initState ─▶ PushNotificationService.start(onTap)
                         ├─ LocalNotificationService.init(onTap)    (foreground banners)
                         ├─ PushMessagingClient.requestPermission / getToken
                         ├─ PushTokenRegistrar.registerToken        (port → device feature)
                         ├─ onForegroundMessage → local.show
                         ├─ onNotificationOpened → onTap
                         └─ getInitialNotification → onTap          (cold start)

onTap ─▶ NotificationRouteResolver.resolve(payload) ─▶ router.go(location)
```

- `PushMessagingClient` (FCM implementation: `FirebasePushMessagingClient`)
  and `LocalNotificationService` (implementation:
  `FlutterLocalNotificationService`) are interfaces, so the whole flow is
  unit-tested with fakes.
- `PushTokenRegistrar` is a **core port**. `RegisterDeviceUseCase` in the
  device feature implements it, and `main.dart` binds it, so core never
  imports a feature.
- `start` is idempotent and never throws, because push is optional. All
  stream subscriptions are cancelled in `dispose`.
- If Firebase isn't configured, `FirebaseInitializer` returns `false` and
  the app runs without push.

## 6. Design system

Widgets never hard-code colours, sizes, durations or strings. They use these
tokens:

| Token file                                                   | Content                                                                                                                                                                      |
| ------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `app_colors.dart`                                            | Raw palette. Read it directly only for fixed brand surfaces (the gradient card).                                                                                             |
| `app_semantic_colors.dart`                                   | `ThemeExtension` with light and dark values: background, surface, border, text levels, success/warning/danger/info, priority colours, shadow. Read it with `context.colors`. |
| `app_theme.dart`                                             | Material 3 `ThemeData` for both modes, built from one recipe. Also provides the status-bar style and skeleton config.                                                        |
| `app_typography.dart`                                        | One type scale (Plus Jakarta Sans). Read it with `context.textTheme`.                                                                                                        |
| `app_spacing.dart`, `app_radius.dart`, `app_icon_sizes.dart` | Scales in design pixels. Apply `.w`/`.h` (spacing), `.r` (sizes, radius) and `.sp` (text) at the call site.                                                                  |
| `app_durations.dart`, `app_curves.dart`                      | Motion: 150 / 280 / 450 ms, ease-out curves, 45 ms stagger.                                                                                                                  |
| `app_layout.dart`                                            | Design canvases, tablet breakpoint, 720 px content cap, stagger limit.                                                                                                       |
| `app_strings.dart`                                           | Every user-facing string, ready to move to l10n.                                                                                                                             |

**Palette, "Pulse indigo".**

| Token          | Light               | Dark      |
| -------------- | ------------------- | --------- |
| Primary        | `#5B5BF6`           | `#8B8CFF` |
| Brand gradient | `#6366F1 → #8B5CF6` | same      |
| Background     | `#F6F7FB`           | `#0B0D14` |
| Surface        | `#FFFFFF`           | `#141824` |

- Priorities: low is teal, medium is amber, high is rose.
- Statuses: to do is neutral, in progress is sky, done is green.
- The error colour is reserved for destructive actions.

**UI kit (`core/widgets`).**

| Widget                             | Purpose                                                                                       |
| ---------------------------------- | --------------------------------------------------------------------------------------------- |
| `AppCard`                          | Rounded surface with hairline border and soft shadow; ripple and press feedback when tappable |
| `AppButton`                        | Primary / secondary / danger variants, with loading state and press feedback                  |
| `AppListTile`                      | Compact one-line row: icon, title, subtitle, trailing control                                 |
| `TileGroup`                        | Titled card that groups tiles with dividers                                                   |
| `IconBox`                          | Tinted rounded icon, the consistent icon style                                                |
| `ChoiceChipGroup<T>`               | Animated single-select pills (filters, priority, status)                                      |
| `StateMessageView`                 | One widget for empty, error and not-found states                                              |
| `AsyncValueView<T>`                | Loading skeleton, data, or friendly error with retry; cross-faded                             |
| `PageHeader`                       | Large page title with an eyebrow line                                                         |
| `PressableScale`                   | Press-to-shrink wrapper (raw pointer events, no gesture conflicts)                            |
| `EntranceOnce`                     | Entrance animation that plays only the first time an id appears                               |
| `showConfirmDialog`, `AppSnackBar` | Confirmation dialogs and toned snack bars                                                     |

**Context helpers.**

- `context.colors`, `context.colorScheme` and `context.textTheme` read the
  theme.
- `context.pagePadding` gives the responsive gutter and the content cap.
- `context.showSnack`, `context.showError` and `context.showComingSoon`
  give user feedback.
- `context.pushTaskDetails(id)` and the other navigation helpers avoid
  spelling out route strings.

## 7. Motion rules

- Entrances use a fade plus a slight slide-up (`Widget.entrance`). Only the
  first 10 items are staggered.
- List items use `EntranceOnce` with a shared `EntranceTracker`, stable
  `ValueKey(task.id)` keys and `findChildIndexCallback`. Items never
  re-animate on rebuild, scroll or reorder.
- Tabs cross-fade through `FadeIndexedStack`. The `AnimatedOpacity` sits
  **outside** each tab's `TickerMode`: a fade inside a disabled ticker would
  never finish, and the hidden tab would stay half visible. Hidden tabs also
  ignore input, are excluded from semantics, and have `HeroMode` off.
- The priority icon is a Hero from the list card to the details header.
  Skeletons disable `HeroMode` so their placeholder cards never take part in
  a flight.
- State changes animate implicitly: badges, check button, counts, the
  completed-date row, button labels and the loading spinner.

## 8. Responsiveness

- The design canvas is 390×844 on phones and 834×1194 on tablets (shortest
  side ≥ 600). It is flipped in landscape (`ResponsiveDesign.designSizeFor`).
- The root widget reads `MediaQuery.sizeOf`, so the keyboard opening doesn't
  trigger a rebuild.
- `context.pagePadding` caps content at 720 px on wide screens.
- Widget tests render the main screens on a 360×740 phone in light and dark
  mode, and on a tablet in landscape, checking for overflow.

## 9. Routing

```text
/tasks                 Tasks tab (shell branch 0)
/tasks/new             New task         – root navigator (full screen)
/tasks/:id             Task details     – root navigator
/tasks/:id/edit        Edit task        – root navigator, loads by id
/settings              Settings tab (shell branch 1)
```

- Unknown locations show `RouteNotFoundPage`.
- Notification routes go through `NotificationRouteResolver`. Anything it
  doesn't recognise falls back to `/tasks`.

## 10. Errors

```text
DioException / bad JSON ─▶ AppException (datasource) ─▶ Failure (repository)
                                                         └▶ FailureMessage.of → UI
```

`Failure` and `AppException` are `sealed`, so `switch` statements over them
are exhaustive. Only `ValidationFailure` messages reach users verbatim;
everything else maps to a friendly sentence.

## 11. Testing

| Folder                         | What it covers                                                                                                           |
| ------------------------------ | ------------------------------------------------------------------------------------------------------------------------ |
| `test/core`                    | Extensions, error guards, failure messages, route resolver, responsive helper, push service (with fakes), UI kit widgets |
| `test/features/*/domain`       | Validator, entity rules, stats, use cases                                                                                |
| `test/features/*/data`         | DTO mapping and repository error mapping                                                                                 |
| `test/features/*/presentation` | Controllers: optimistic updates, rollback, refresh de-duplication, details sync                                          |
| `test/app`                     | The real app (router, shell, pages) on a fake repository: flows, regressions, responsive layouts                         |

Shared helpers live in `test/helpers`: `FakeTaskRepository`, `buildTask`,
`pumpPulseApp` and `pumpThemed`.

## 12. Configuration

| Key                | Default                | Notes                                  |
| ------------------ | ---------------------- | -------------------------------------- |
| `API_BASE_URL`     | `http://10.0.2.2:3000` | Set via `--dart-define-from-file=.env` |
| `ENABLE_HTTP_LOGS` | `false`                | Ignored in release builds              |

`lib/firebase_options.dart` and the platform Firebase files are gitignored.
Generate them with `flutterfire configure`.
