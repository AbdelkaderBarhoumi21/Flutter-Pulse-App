# Pulse

A modern Flutter task manager with real-time push notifications.

Pulse is the mobile client for the `task_api` Rust backend. You can create,
edit, complete and delete tasks, track your progress at a glance, and get a
push notification (via Firebase Cloud Messaging) whenever a task changes.
Tapping the notification opens that task.

## Features

- **Tasks:** create, edit, complete and reopen, and delete (swipe or the
  details screen, always with a confirmation).
- **Progress at a glance:** a gradient summary card with a completion ring and
  counts per status.
- **Filters:** All, To do, In progress and Done, each with a live count.
- **Optimistic updates:** completing or deleting a task updates the list
  instantly and rolls back if the server refuses.
- **Polished states:** shimmer skeletons while loading, friendly empty
  states, and error states with a retry button. Raw errors are never shown.
- **Light, dark and system themes:** switch them in Settings; the choice is
  saved.
- **Push notifications:** foreground banners, background and cold-start
  taps, and deep links to the task (`/task-details` and the legacy
  `/taskDetails` are both accepted).
- **Smooth, subtle motion:** staggered list entrances (played once per item),
  press-to-shrink feedback, cross-fading tabs that keep their state, a Hero
  from card to details, and animated badges, counts and buttons.
- **Responsive:** scales from 360 dp phones to tablets. Content is capped at
  720 px, and the design canvas flips in landscape.

## Screenshots

> Coming soon. Run the app with Firebase configured and the backend running,
> then add light and dark screenshots of the Tasks, Details, Form and
> Settings screens to `docs/screenshots/`.

## Tech stack

| Concern           | Package                                                              |
| ----------------- | -------------------------------------------------------------------- |
| State management  | `flutter_riverpod` (Notifier / AsyncNotifier, no codegen)            |
| Navigation        | `go_router` (`StatefulShellRoute` for the bottom tabs)               |
| Networking        | `dio`                                                                |
| Errors            | `dartz` (`Either<Failure, T>`), `equatable`                          |
| Push              | `firebase_core`, `firebase_messaging`, `flutter_local_notifications` |
| Responsive UI     | `flutter_screenutil`                                                 |
| Motion            | `flutter_animate` + implicit animations                              |
| Loading skeletons | `skeletonizer`                                                       |
| Storage           | `shared_preferences` (theme preference)                              |
| Formatting / info | `intl`, `package_info_plus`                                          |
| Testing           | `flutter_test`, `mocktail`                                           |

The font is **Plus Jakarta Sans**, bundled in `assets/fonts` under the SIL
Open Font License (see `assets/fonts/OFL.txt`).

## Architecture

The app uses feature-first Clean Architecture with Riverpod:

```text
lib/
├── main.dart          # bootstrap: Firebase, prefs, DI bindings, runApp
├── app/               # PulseApp: ScreenUtil, themes, router, push wiring
├── core/              # shared, feature-agnostic code
│   ├── config/        # AppEnv (compile-time environment)
│   ├── constants/     # colors, gradients, spacing, radius, icons, durations, curves, layout, strings, limits
│   ├── errors/        # exceptions, failures, guards, friendly messages
│   ├── extensions/    # all extensions (context, DateTime, String, animation, task & settings UI)
│   ├── helpers/       # ActionFeedback: action result → snack bar
│   ├── network/       # Dio client, endpoints
│   ├── notifications/ # push + local notifications behind interfaces
│   ├── routing/       # routes, router, navigation helpers, notification resolver
│   ├── storage/       # SharedPreferences provider
│   ├── theme/         # Material 3 light/dark, typography, semantic colours
│   ├── usecase/       # UseCase base contract
│   ├── utils/         # logger, clock, responsive design, entrance tracker
│   └── widgets/       # reusable UI kit
└── features/
    ├── task/          # data / domain / presentation
    ├── device/        # push-token registration (implements a core port)
    ├── settings/      # theme preference + settings screen
    └── shell/         # bottom-navigation shell
```

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for the layering rules, data
flow, state management conventions and design system.

## Getting started

### Prerequisites

- Flutter stable with Dart 3.11+ (see `pubspec.yaml`)
- The `task_api` backend running locally (default `http://localhost:3000`)
- A Firebase project for push notifications (optional; the app runs without
  push if Firebase isn't configured)

### Setup

```bash
flutter pub get

# Environment (compiled in at build time, never commit .env)
cp .env.example .env

# Firebase: generates lib/firebase_options.dart and the platform files
# (android/app/google-services.json, ios/Runner/GoogleService-Info.plist)
dart pub global activate flutterfire_cli
flutterfire configure
```

### Run

```bash
flutter run --dart-define-from-file=.env
```

`API_BASE_URL` defaults to `http://10.0.2.2:3000`, which is your machine as
seen from the Android emulator. On a real device, point it at your machine's
LAN IP.

### Quality checks

```bash
flutter analyze   # zero issues expected
flutter test      # unit, widget and app-level tests
```

## Documentation

- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md): architecture and design
  system
- [docs/FLUTTER_APP_FCM_INTEGRATION.md](docs/FLUTTER_APP_FCM_INTEGRATION.md):
  FCM setup
- [docs/notifications/NOTIFICATION_PAYLOAD.md](docs/notifications/NOTIFICATION_PAYLOAD.md):
  push payload contract
- [docs/api/api.md](docs/api/api.md): HTTP notes
