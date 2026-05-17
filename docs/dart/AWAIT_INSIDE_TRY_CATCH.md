# Why `await` is mandatory inside a `try` block

> Applies to any `try`/`catch` that wraps async work — especially the `guardThrowing` / `guardEither` helpers in [`lib/core/errors/app_error_guard.dart`](../lib/core/errors/app_error_guard.dart).

A `Future` is a promise that work will happen *later*. When you call an async function like `body()`, three things happen in order:

1. **`body()` STARTS the async work and IMMEDIATELY returns a `Future<T>`.**
   It does NOT wait for the work to finish. At this point no exception has been thrown yet — the HTTP call hasn't even completed.

2. **The `try` block sees a value (the Future) being returned** — no exception, all good — **and EXITS cleanly.**

3. **LATER** (milliseconds later, after the `try` block is long gone), the HTTP call finishes and the Future resolves. If it resolves with an error, that error has nowhere to go — the `try`/`catch` already finished its job.

---

## Visualized — WITHOUT `await` (BROKEN)

```dart
try {                       // ← enter try
  return body();            // ← Future returned immediately, no error yet
} catch { ... }             // ← try exits cleanly — catch is disarmed
// ─────────── time passes ────────────
// 💥 Future rejects with DioException → propagates up the call stack,
//                                       NOT caught here
```

The `catch` clause never fires. The exception escapes the function and surfaces somewhere upstream — usually as an unhandled error or in a place that has no idea how to handle it.

---

## Visualized — WITH `await` (CORRECT)

```dart
try {                       // ← enter try
  return await body();      // ← PAUSE here until the Future resolves
// ─────────── time passes ────────────
// 💥 Future rejects → await throws DioException INSIDE the try
} catch (DioException) { ... }   // ← caught ✅
```

`await` is the only operator in Dart that:

- Converts `Future<T>` into `T` at the point where it's written.
- Converts a **rejected** Future into a **thrown** exception at the point where it's written.

That second property is what makes `try`/`catch` work for async code. Without `await`, the error materializes *after* the `try` block has already exited.

---

## The Rule

> **If a Future is created inside a `try` block and you care about its errors, `await` it inside the same try. Otherwise the try block is just decorative.**

### A subtle trap in generic helpers

It looks especially tempting in pass-through helpers like `guardThrowing` where the types match without `await`:

```dart
Future<T> guardThrowing<T>(Future<T> Function() body) async {
  try {
    return body();      // ← compiles fine! Future<T> matches Future<T>.
  } on DioException catch (e) { ... }   // ← silently never fires
}
```

The compiler **won't warn you**. The bug only shows up at runtime when a network error mysteriously bypasses your mapper and surfaces as a raw `DioException` somewhere upstream.

### What `await` actually does

| Without `await` | With `await` |
|---|---|
| The function returns the **still-sealed box** (Future). | The function **opens the box** and works with the value inside (`T`). |
| Errors materialize in whoever eventually awaits — *somewhere else, later*. | Errors materialize **right here**, inside the `try` block. |
| `try`/`catch` is decorative — it caught nothing. | `try`/`catch` actually catches async failures. |

---

## One-line mental model

> **`await`** = *"pause here, open the box, give me what's inside (or throw what's inside)."*
>
> **No `await`** = *"hand me the still-sealed box, I don't care what's in it."*

The `try`/`catch` only catches things that happen **while the function is paused inside the `try` block**. No `await` = no pause = no chance to catch.
