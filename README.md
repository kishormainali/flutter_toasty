# Flutter Toasty

A customizable toast notification library for Flutter.

## Features

- Info, Success, Warning, Error, and Custom toasts at six screen positions
- Light/dark theming through a `ThemeExtension` (`ToastyTheme`)
- One custom builder that restyles every toast state, no `.custom` needed
- Stacked toasts: the newest is in front, older ones peek out behind it
- Progress bar, `onClick` / `onClose` callbacks, pause on hover
- Accessibility announcements
- Toasts on screen update live when the theme changes

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_toasty: ^latest
```

## Usage

Place `ToastyProvider` in the `builder` of your `MaterialApp`, `CupertinoApp`, or `WidgetsApp`. This approach works seamlessly with routing solutions like `go_router`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_toasty/flutter_toasty.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomePage(),
      builder: (context, child) => ToastyProvider(
        child: child!,
      ),
    );
  }
}
```

**With Routing Solutions (go_router, auto_route, etc.):**

```dart
return MaterialApp.router(
  routerConfig: router, // Your routing configuration
  builder: (context, child) => ToastyProvider(
    child: child!,
  ),
);
```

**IMPORTANT:** `ToastyProvider` MUST be placed:

- ✅ In the `builder` parameter of MaterialApp/CupertinoApp/WidgetsApp
- ✅ NOT as a wrapper around the app widget
- ✅ This ensures access to Material context (Theme, Localizations, Direction, MediaQuery)

❌ **WRONG:**

```dart
return ToastyProvider(
  child: MaterialApp(...),
);
```

✅ **CORRECT:**

```dart
return MaterialApp(
  home: const HomePage(),
  builder: (context, child) => ToastyProvider(child: child!),
);
```

Show a toast anywhere in your app:

```dart
FlutterToasty.info('This is an info toast!');
FlutterToasty.success('Operation successful!', title: 'Success');
FlutterToasty.warning('Be careful!', onClick: () => print('Toast clicked'));
FlutterToasty.error('Something went wrong.', onClose: () => print('Toast closed'));
```

Every call returns the toast's id, so you can close it yourself:

```dart
final id = FlutterToasty.info('Uploading...', autoDismiss: false);
FlutterToasty.dismiss(id);   // one toast
FlutterToasty.dismissAll();  // everything
```

`onClose` runs once per toast however it goes away: timer, close button, tap, `dismiss`, `dismissAll`, or being evicted by `maxToasts`.

## Toast Types and Positions

### Available Toast Types

- `info` - Informational message
- `success` - Success notification
- `warning` - Warning message
- `error` - Error notification
- `custom` - Fully customizable toast

### Available Positions

- `topLeft`, `topCenter`, `topRight`
- `bottomLeft`, `bottomCenter`, `bottomRight`

```dart
FlutterToasty.info(
  'Top center toast',
  position: ToastPosition.topCenter,
);

FlutterToasty.warning(
  'Bottom right warning',
  position: ToastPosition.bottomRight,
);
```

## Customization

### Global Configuration

Set behavior for all toasts via `ToastyProvider` (the dismiss duration is set per toast, see below):

```dart
MaterialApp(
  home: const HomePage(),
  builder: (context, child) => ToastyProvider(
    options: ToastyOptions(
      position: ToastPosition.topCenter,
      pauseOnHover: true,
      closeOnClick: true,
      width: 360,
    ),
    maxToasts: 3,
    child: child!,
  ),
)
```

### Theming (light / dark)

Style toasts with `ToastyTheme`, a `ThemeExtension`, so they follow your theme mode like any other widget:

```dart
MaterialApp(
  theme: ThemeData(
    extensions: [
      ToastyTheme(
        success: ToastItemOptions(backgroundColor: Colors.green.shade600),
        error: ToastItemOptions(backgroundColor: Colors.red.shade600),
      ),
    ],
  ),
  darkTheme: ThemeData.dark().copyWith(
    extensions: [
      ToastyTheme(
        success: ToastItemOptions(backgroundColor: Colors.green.shade900),
        error: ToastItemOptions(backgroundColor: Colors.red.shade900),
      ),
    ],
  ),
  builder: (context, child) => ToastyProvider(child: child!),
)
```

**Where to configure what**

| What | Where |
| --- | --- |
| Look: colors, icon, text styles, shape, builder (light/dark aware) | `ToastyTheme` in `ThemeData.extensions` |
| Behavior: position, width, hover, close on click, max toasts | `ToastyProvider(options: ToastyOptions(...))` |
| Timing and callbacks for one toast | arguments of `FlutterToasty.info/success/...` |
| A one-off look for one toast | `options:` of `FlutterToasty.custom` |

A state you leave out of `ToastyTheme` keeps its default. `ToastyTheme.all(options)` applies one set of options to every state. `ToastyOptions.itemOptions` still works but is deprecated in favor of `ToastyTheme`.

#### One design for all states

Give the theme a `builder` and every toast (info, success, warning, error) uses it, with no need for `.custom`:

```dart
ToastyTheme(
  builder: (context, data) => Row(
    children: [
      data.options.icon,
      const SizedBox(width: 12),
      Expanded(child: Text(data.message, style: data.options.contentTextStyle)),
      IconButton(icon: const Icon(Icons.close), onPressed: data.dismiss),
    ],
  ),
)
```

`data.type` lets you vary the layout per state, and `data.options` carries the per-state colors, icon and text styles. The card (background, shape), progress bar and tap handling still come from the per-state options; a `child` passed to `FlutterToasty.custom` overrides the builder.

### How toasts stack

Toasts at the same position form a stack. The newest toast is in front at full size, and older ones show as cards peeking out behind it, whatever their height. Only the front toast's dismiss timer runs, so the newest toast goes first and each older one then gets its full `dismissDuration`. Each position has its own stack, and `maxToasts` limits a stack (the oldest toast is removed when it overflows).

### Per-Toast Customization

Customize individual toasts:

```dart
FlutterToasty.info(
  'Custom duration and progress',
  dismissDuration: Duration(seconds: 5),
  showProgressBar: true,
);

FlutterToasty.success(
  'Operation completed',
  title: 'Success',
  autoDismiss: false, // Manual dismissal only
);

FlutterToasty.custom(
  child: Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.blue,
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Text('Custom toast content'),
  ),
);
```

## Example app

The [`example/`](example) app is a playground for everything above: every toast type, all six positions, behavior switches (title, progress bar, auto dismiss, duration), a light/system/dark switch, `ToastyTheme` colors per mode and a custom builder. Run it with:

```bash
cd example
flutter run
```

## For AI agents

See [`llms.txt`](llms.txt) for a compact, accurate API summary and usage rules.

## Common Issues & Troubleshooting

### "No MaterialLocalizations found" error

**Cause:** `ToastyProvider` must be placed in the `builder` of `MaterialApp`, not as a wrapper around it.

**Solution:**

```dart
// ✅ Correct
return MaterialApp(
  home: const HomePage(),
  builder: (context, child) => ToastyProvider(child: child!),
);

// ❌ Wrong
return ToastyProvider(
  child: MaterialApp(...),
);
```

### Toasts not appearing

**Cause:** ToastyProvider may not be properly placed in the MaterialApp builder or context is unavailable.

**Solution:** Ensure ToastyProvider is in the `builder` parameter of your MaterialApp/CupertinoApp/WidgetsApp, not as a wrapper or home widget.

### Text field double-tap or modal sheet errors

**Cause:** Material context not properly inherited by overlay entries.

**Solution:** This is fixed in the latest version. `ToastyProvider` now properly manages Material context inheritance for all overlay entries, ensuring modals, text selections, and other Material features work correctly with toasts displayed.

## License

MIT
