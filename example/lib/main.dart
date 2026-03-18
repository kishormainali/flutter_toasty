import 'package:example/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_toasty/flutter_toasty.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: AppRouter().config(),
      builder: (context, child) => ToastyProvider(child: child!),
    );
  }
}
