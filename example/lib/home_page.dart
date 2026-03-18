import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_toasty/flutter_toasty.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (_) => Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('This is a bottom sheet'),
                            SizedBox(height: 8),
                            Text('It should not interfere with toasts'),
                            ElevatedButton(
                              onPressed: () {
                                FlutterToasty.info(
                                  'This is a toast from bottom sheet!',
                                );
                              },
                              child: Text('Show'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: const Text('Show Custom Toast'),
                );
              },
            ),
            Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('This is a dialog'),
                        content: const Text(
                          'It should not interfere with toasts',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => FlutterToasty.info(
                              'This is a toast from dialog!',
                            ),
                            child: const Text('Show'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('Show Custom Toast'),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {
            FlutterToasty.info('This is a bottom toast!', autoDismiss: false);
          },
          child: const Text('Show Bottom Toast'),
        ),
      ),
    );
  }
}
