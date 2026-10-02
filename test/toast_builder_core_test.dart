import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_toasty/flutter_toasty.dart';
import 'package:flutter_toasty/src/_toast_manager.dart';
import 'package:flutter_toasty/src/widgets/toast_widget.dart';

Widget _app({int? maxToasts, ToastyOptions? options}) => MaterialApp(
  theme: ThemeData(
    extensions: [
      ToastyTheme(
        builder: (context, data) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('built:${data.message}'),
            TextButton(
              key: ValueKey('close-${data.message}'),
              onPressed: data.dismiss,
              child: const Text('x'),
            ),
          ],
        ),
      ),
    ],
  ),
  builder: (context, child) =>
      ToastyProvider(maxToasts: maxToasts, options: options, child: child!),
  home: const Scaffold(body: SizedBox()),
);

List<String> _shown() =>
    ToastManager.i.toasts.value.map((t) => t.message).toList();

void main() {
  setUp(() => ToastManager.i.dismissAll());

  testWidgets('timers, order and burst behave as without a builder', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    for (final m in ['a', 'b', 'c']) {
      FlutterToasty.info(m);
    }
    await tester.pump();
    final widgets = tester.widgetList<ToastWidget>(find.byType(ToastWidget));
    expect(widgets.map((w) => w.isActive), [false, false, true]);
    await tester.pump(const Duration(milliseconds: 2900));
    expect(_shown(), ['a', 'b', 'c']);
    await tester.pump(const Duration(milliseconds: 200));
    expect(_shown(), ['a', 'b']);
    await tester.pump(const Duration(seconds: 3));
    expect(_shown(), ['a']);
    await tester.pump(const Duration(seconds: 3));
    expect(_shown(), isEmpty);
    await tester.pumpAndSettle();
  });

  testWidgets('autoDismiss false stays; progress bar still shown', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    FlutterToasty.info('sticky', autoDismiss: false, showProgressBar: true);
    await tester.pump();
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(seconds: 10));
    expect(_shown(), ['sticky']);
  });

  testWidgets('tap fires onClick and closeOnClick dismisses', (tester) async {
    await tester.pumpWidget(_app());
    var clicked = 0;
    FlutterToasty.info('tap', onClick: () => clicked++);
    await tester.pump();
    await tester.tap(find.text('built:tap'));
    await tester.pump();
    expect(clicked, 1);
    expect(_shown(), isEmpty); // closeOnClick defaults to true
    await tester.pumpAndSettle();
  });

  testWidgets('data.dismiss from builder content dismisses', (tester) async {
    await tester.pumpWidget(_app());
    FlutterToasty.info('d', autoDismiss: false);
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('close-d')));
    await tester.pump();
    expect(_shown(), isEmpty);
    await tester.pumpAndSettle();
  });

  testWidgets('maxToasts overflow calls onClose of evicted toast', (
    tester,
  ) async {
    await tester.pumpWidget(_app(maxToasts: 2));
    var closed = <String>[];
    for (final m in ['1', '2', '3']) {
      FlutterToasty.info(m, autoDismiss: false, onClose: () => closed.add(m));
    }
    await tester.pump();
    expect(_shown(), ['2', '3']);
    expect(closed, ['1']);
  });

  testWidgets('hover pauses the active toast timer', (tester) async {
    await tester.pumpWidget(_app());
    FlutterToasty.info('h');
    await tester.pump();
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    await gesture.moveTo(tester.getCenter(find.text('built:h')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 10));
    expect(_shown(), ['h']);
    await gesture.moveTo(const Offset(1, 1));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3, milliseconds: 100));
    expect(_shown(), isEmpty);
    await tester.pumpAndSettle();
  });

  testWidgets('custom child and message-less builder coexist', (tester) async {
    await tester.pumpWidget(_app());
    FlutterToasty.custom(child: const Text('mine'));
    await tester.pump();
    expect(find.text('mine'), findsOneWidget);
    ToastManager.i.dismissAll();
    FlutterToasty.custom(message: 'msg');
    await tester.pump();
    expect(find.text('built:msg'), findsOneWidget);
  });

  testWidgets('throwing builder falls back to default content', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: [
            ToastyTheme(builder: (context, data) => throw StateError('boom')),
          ],
        ),
        builder: (context, child) => ToastyProvider(child: child!),
        home: const Scaffold(body: SizedBox()),
      ),
    );
    FlutterToasty.info('safe');
    await tester.pump();
    expect(find.text('safe'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(seconds: 4));
    expect(_shown(), isEmpty);
    await tester.pumpAndSettle();
  });
}
