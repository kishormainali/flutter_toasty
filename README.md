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

Wrap your app with `ToastyProvider`:

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
    return ToastyProvider(
      child: MaterialApp(
        home: HomePage(),
      ),
    );
  }
}
```

Show a toast anywhere in your app:

```dart
FlutterToasty.info('This is an info toast!');
FlutterToasty.success('Operation successful!', title: 'Success');
FlutterToasty.warning('Be careful!', onClick: () => print('Toast clicked'));
FlutterToasty.error('Something went wrong.', onClose: () => print('Toast closed'));
```

## Example

```dart
ElevatedButton(
  onPressed: () {
    FlutterToasty.info('Hello, World!');
  },
  child: const Text('Show Info Toast'),
)
```

See the `example/` folder for a complete demo app.

## Customization

You can customize toasts globally via `ToastyProvider` or per-toast using options:

```dart
FlutterToasty.info(
  'Custom duration and progress',
  dismissDuration: Duration(seconds: 5),
  showProgressBar: true,
);
```

## License

MIT
