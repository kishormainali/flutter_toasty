# flutter_toasty example

A playground for the [`flutter_toasty`](..) package.

```bash
flutter run
```

## What you can try

- **Show toast:** info, success, warning, error and custom, a burst of three (to see the stack), and a sticky toast that never auto-dismisses. The app bar button dismisses everything.
- **Position:** pick any of the six positions. It is used as the provider default and passed on each call.
- **Behavior:** title, progress bar, auto dismiss and duration. These apply to the next toast you show.
- **Theme & customization:**
  - Light / System / Dark mode.
  - *ToastyTheme colors & icons* registers separate light and dark per-state options.
  - *Custom builder* turns on `ToastyTheme.builder`, one layout for every state with no `.custom` call.
  - Toasts already on screen update as you flip these.
- **Overlay checks:** show toasts above a bottom sheet and a dialog.

## Where things are

| File | What it shows |
| --- | --- |
| [`lib/main.dart`](lib/main.dart) | `ToastyProvider` in `MaterialApp.router`'s `builder`, `ToastyOptions`, light/dark themes |
| [`lib/toasty_styles.dart`](lib/toasty_styles.dart) | `ToastyTheme` per brightness and the custom builder |
| [`lib/home_page.dart`](lib/home_page.dart) | Calling `FlutterToasty.*` with positions and options |
| [`lib/settings.dart`](lib/settings.dart) | Demo settings shared by the app and the controls |

Run the tests with `flutter test`.
