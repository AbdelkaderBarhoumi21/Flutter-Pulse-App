# `NotificationPayload` — Typed Wrapper for FCM `data`

## What `NotificationPayload` represents

It's a **typed Dart wrapper around the `data` field of an FCM push** — the custom key/value bag the Rust backend attaches to every notification. Three fields the app cares about, parsed once into a real object instead of poking around in a raw `Map` every time.

```dart
class NotificationPayload {
  final String? type;     // what kind of notification ("task_created", "task_completed", ...)
  final String? taskId;   // which task the notification is about
  final String? route;    // where the app should navigate when tapped
}
```

All three are **nullable** because not every notification carries all three — and we don't want the app to crash if the backend forgot to include one.

---

## Concrete example — a notification arriving end-to-end

### 1. Rust backend sends an FCM message

```json
{
  "message": {
    "token": "eW7K_Lq...",
    "notification": {
      "title": "Task assigned to you",
      "body": "Review the Q1 report by Friday"
    },
    "android": {
      "notification": { "channel_id": "task_updates" }
    },
    "data": {
      "type": "task_assigned",
      "taskId": "550e8400-e29b-41d4-a716-446655440000",
      "route": "/task-details"
    }
  }
}
```

Note the split:

- **`notification`** block → what the OS displays (title, body, icon, sound).
- **`data`** block → custom payload **the app reads** — never shown to the user directly.

### 2. Firebase Messaging delivers it to the Flutter app

In `FcmService.bootstrap`, three hooks are registered. When the user taps the notification, one of them fires with a `RemoteMessage`:

```dart
FirebaseMessaging.onMessageOpenedApp.listen((msg) {
  // msg.data is the raw Map<String, dynamic>:
  // {
  //   'type': 'task_assigned',
  //   'taskId': '550e8400-e29b-41d4-a716-446655440000',
  //   'route': '/task-details',
  // }
});
```

### 3. `NotificationPayload.fromMap(msg.data)` turns the raw Map into a typed object

```dart
final payload = NotificationPayload.fromMap(msg.data);

// Now you have:
payload.type;     // 'task_assigned'
payload.taskId;   // '550e8400-e29b-41d4-a716-446655440000'
payload.route;    // '/task-details'
```

### 4. The router uses it to navigate

From the FCM doc's `appRouterProvider`:

```dart
ref.read(fcmServiceProvider).bootstrap(
  onTap: (NotificationPayload p) {
    final route = p.route;
    final id = p.taskId;
    if (route == null) return;
    if (id != null) {
      router.go('$route?id=$id');         // → '/task-details?id=550e8400-...'
    } else {
      router.go(route);
    }
  },
);
```

The user lands on the task details screen for that specific UUID. **Deep link complete.**

---

## Why a class instead of just using `Map<String, dynamic>` directly?

You could write:

```dart
final route = msg.data['route'] as String?;
final taskId = msg.data['taskId'] as String?;
```

…everywhere. But that has three problems the class solves:

### Problem 1 — Stringly-typed keys

```dart
msg.data['rotue']      // typo — silently returns null at runtime
msg.data['route ']     // extra space — silently null
msg.data['Route']      // wrong case — silently null
```

With the class:

```dart
payload.rotue          // compile error — typo caught immediately
```

The compiler knows the field names. The Map doesn't.

### Problem 2 — Repeated casts everywhere

`msg.data['taskId']` returns `Object?`. Every read site has to add `as String?`. With the class, the cast happens **once** inside `fromMap`, and every read site gets a strongly-typed `String?` for free.

### Problem 3 — The shape isn't documented

A `Map<String, dynamic>` could contain anything. A reader of the code has no way to know what keys to expect without grepping the backend or guessing. The class declares the contract:

> *"These are the three fields I care about. If the backend sends more, I ignore them. If the backend sends less, I get `null` and handle it gracefully."*

---

## Why all fields are nullable (the design choice)

Different notification types carry different fields. Example shapes:

```dart
// Task-related notifications — all three present
{ "type": "task_created", "taskId": "uuid-1", "route": "/task-details" }
{ "type": "task_completed", "taskId": "uuid-2", "route": "/task-details" }

// General announcement — no task, just navigate home
{ "type": "announcement", "route": "/" }

// Marketing push — nothing to do on tap
{ "type": "promo" }

// Misconfigured payload — completely empty
{ }
```

If `taskId` were `required`, the announcement case would crash `fromMap`. If `type` were `required`, an empty payload would crash. Marking everything nullable means **the parser never crashes on a malformed/sparse payload** — it just returns nulls and the navigation logic decides what to do (e.g., the `if (route == null) return;` line in the router).

This is the right tradeoff for code that runs on someone else's data. The cost is that callers have to null-check; the benefit is the app never crashes from a missing field.

---

## Where the class fits in the bigger picture

```
Rust backend
    │ builds FCM payload with `data: { type, taskId, route }`
    ▼
FCM (Google's servers)
    │ delivers to device
    ▼
firebase_messaging Flutter plugin
    │ wraps it as RemoteMessage with msg.data: Map<String, dynamic>
    ▼
FcmService.onMessage / onMessageOpenedApp / getInitialMessage
    │ calls NotificationPayload.fromMap(msg.data)
    ▼
NotificationPayload (typed Dart object)
    │ passed to the router's onTap callback
    ▼
GoRouter.go('/task-details?id=…')
    │
    ▼
TaskDetailsView opens
```

The class is the **single boundary** where untyped network data becomes typed app data. Same role `TaskDto` plays for HTTP responses — wire shape on one side, typed Dart on the other.

---

## TL;DR with a concrete example

Imagine the backend sends a push saying *"Your boss assigned you a task: Review Q1 report."* The actual payload looks like:

```dart
msg.data == {
  'type': 'task_assigned',
  'taskId': '550e8400-e29b-41d4-a716-446655440000',
  'route': '/task-details',
}
```

`NotificationPayload.fromMap(msg.data)` parses that into a typed object. The router reads `payload.route` and `payload.taskId`, then calls `router.go('/task-details?id=550e8400-…')`. The user taps the banner → app opens directly on the relevant task.

That's the **whole purpose** of the class: turn an opaque map into a typed contract so the deep-link logic is type-safe and unambiguous.
