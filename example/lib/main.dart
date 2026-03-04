import 'package:flutter/material.dart';
import 'package:flutter_toasty/flutter_toasty.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ToastyProvider(
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('Flutter Toasty Example')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: .center,
              crossAxisAlignment: .stretch,
              spacing: 12,
              children: [
                ElevatedButton(
                  onPressed: () {
                    FlutterToasty.info(
                      'Hello, World!',
                      title: 'Hello',
                      autoDismiss: false,
                    );
                  },
                  child: const Text('Show Info Toast'),
                ),
                ElevatedButton(
                  onPressed: () {
                    FlutterToasty.success('Hello, World!', title: 'Hello');
                  },
                  child: const Text('Show Success Toast'),
                ),
                ElevatedButton(
                  onPressed: () {
                    FlutterToasty.warning('Hello, World!');
                  },
                  child: const Text('Show Warning Toast'),
                ),
                ElevatedButton(
                  onPressed: () {
                    FlutterToasty.error('Hello, World!', showProgressBar: true);
                  },
                  child: const Text('Show Error Toast'),
                ),
                ElevatedButton(
                  onPressed: () {
                    FlutterToasty.custom(child: Text('Hello, World!'));
                  },
                  child: const Text('Show Custom Toast'),
                ),
              ],
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                FlutterToasty.info(
                  'This is a bottom toast!',
                  autoDismiss: false,
                );
              },
              child: const Text('Show Bottom Toast'),
            ),
          ),
        ),
      ),
    );
  }
}
