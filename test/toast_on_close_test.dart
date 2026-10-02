import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_toasty/flutter_toasty.dart';
import 'package:flutter_toasty/src/_toast_manager.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => ToastyProvider(child: child!),
        home: const Scaffold(body: SizedBox()),
      ),
    );
    ToastManager.i.dismissAll();
  }

  testWidgets('onClose fires once on auto dismiss', (tester) async {
    await pumpApp(tester);
    var closed = 0;
    FlutterToasty.info('a', onClose: () => closed++);
    await tester.pump();
    await tester.pump(const Duration(seconds: 4));
    expect(closed, 1);
    await tester.pumpAndSettle();
  });

  testWidgets('onClose fires once on dismiss(id), dismissAll and tap', (
    tester,
  ) async {
    await pumpApp(tester);
    final closed = <String>[];
    final id = FlutterToasty.info(
      'byId',
      autoDismiss: false,
      onClose: () => closed.add('byId'),
    );
    await tester.pump();
    FlutterToasty.dismiss(id);
    FlutterToasty.dismiss(id); // unknown now: no second call
    await tester.pump();

    FlutterToasty.info(
      'all',
      autoDismiss: false,
      onClose: () => closed.add('all'),
    );
    await tester.pump();
    FlutterToasty.dismissAll();
    await tester.pump();

    FlutterToasty.info(
      'tap',
      autoDismiss: false,
      onClose: () => closed.add('tap'),
    );
    await tester.pump();
    await tester.tap(find.text('tap'));
    await tester.pump();

    expect(closed, ['byId', 'all', 'tap']);
    await tester.pumpAndSettle();
  });
}
