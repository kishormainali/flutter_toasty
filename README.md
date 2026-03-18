# Flutter Toasty

A customizable toast notification library for Flutter.

## Features

- Info, Success, Warning, Error, and Custom toasts
- Progress bar support
- Actions and callbacks
- Accessibility announcements
- Highly configurable appearance and behavior

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

Customize all toasts via `ToastyProvider`:

```dart
MaterialApp(
  home: const HomePage(),
  builder: (context, child) => ToastyProvider(
    options: ToastyOptions(
      position: ToastPosition.topCenter,
      pauseOnHover: true,
      closeOnClick: true,
      dismissDuration: const Duration(seconds: 5),
    ),
    maxToasts: 3,
    child: child!,
  ),
)
```

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
