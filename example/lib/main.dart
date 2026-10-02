import 'package:example/router.dart';
import 'package:example/settings.dart';
import 'package:example/toasty_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_toasty/flutter_toasty.dart';

void main() {
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _router = AppRouter();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: DemoSettings.i,
      builder: (context, _) {
        final s = DemoSettings.i;
        ThemeData theme(Brightness b) => buildTheme(
          b,
          useToastyTheme: s.useToastyTheme,
          useCustomBuilder: s.useCustomBuilder,
        );
        return MaterialApp.router(
          title: 'Flutter Toasty',
          routerConfig: _router.config(),
          themeMode: s.themeMode,
          theme: theme(Brightness.light),
          darkTheme: theme(Brightness.dark),
          builder: (context, child) => ToastyProvider(
            // Where toasts appear when a call doesn't pass a position.
            options: ToastyOptions(position: s.position),
            child: child!,
          ),
        );
      },
    );
  }
}
