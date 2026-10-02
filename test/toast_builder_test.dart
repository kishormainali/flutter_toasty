import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_toasty/flutter_toasty.dart';
import 'package:flutter_toasty/src/_toast_manager.dart';

void main() {
  _reactiveTests();
  testWidgets('builder styles every state without .custom', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: [
            ToastyTheme(
              builder: (context, data) =>
                  Text('${data.type.name}|${data.title}|${data.message}'),
            ),
          ],
        ),
        builder: (context, child) => ToastyProvider(child: child!),
        home: const Scaffold(body: SizedBox()),
      ),
    );
    ToastManager.i.dismissAll();
    FlutterToasty.success('ok', title: 'T');
    await tester.pump();
    expect(find.text('success|T|ok'), findsOneWidget);
    ToastManager.i.dismissAll();
    FlutterToasty.error('bad');
    await tester.pump();
    expect(find.text('error|null|bad'), findsOneWidget);

    FlutterToasty.custom(child: const Text('mine'));
    await tester.pump();
    expect(find.text('mine'), findsOneWidget);
    ToastManager.i.dismissAll();
    await tester.pumpAndSettle();
  });

  testWidgets('partial itemOptions keeps other defaults', (tester) async {
    await tester.pumpWidget(
      ToastyProvider(
        options: const ToastyOptions(
          // ignore: deprecated_member_use_from_same_package
          itemOptions: {ToastType.success: ToastItemOptions()},
        ),
        child: const MaterialApp(home: Scaffold(body: SizedBox())),
      ),
    );
    ToastManager.i.dismissAll();
    FlutterToasty.error('still works');
    await tester.pump();
    expect(find.text('still works'), findsOneWidget);
    ToastManager.i.dismissAll();
    await tester.pumpAndSettle();
  });

  testWidgets('theme follows light/dark mode', (tester) async {
    ToastyTheme themed(String label) =>
        ToastyTheme(builder: (context, data) => Text('$label:${data.message}'));
    final mode = ValueNotifier(ThemeMode.light);
    await tester.pumpWidget(
      ValueListenableBuilder(
        valueListenable: mode,
        builder: (_, m, _) => MaterialApp(
          themeMode: m,
          theme: ThemeData(extensions: [themed('light')]),
          darkTheme: ThemeData.dark().copyWith(extensions: [themed('dark')]),
          builder: (context, child) => ToastyProvider(child: child!),
          home: const Scaffold(body: SizedBox()),
        ),
      ),
    );
    ToastManager.i.dismissAll();
    FlutterToasty.info('x');
    await tester.pump();
    expect(find.text('light:x'), findsOneWidget);
    ToastManager.i.dismissAll();
    await tester.pumpAndSettle();

    mode.value = ThemeMode.dark;
    await tester.pumpAndSettle(); // theme change animates
    FlutterToasty.info('y');
    await tester.pump();
    expect(find.text('dark:y'), findsOneWidget);
    ToastManager.i.dismissAll();
    await tester.pumpAndSettle();
  });

  testWidgets('theme per-state options restyle states, explicit options win', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: const [
            ToastyTheme(
              success: ToastItemOptions(backgroundColor: Color(0xFF123456)),
              custom: ToastItemOptions(backgroundColor: Color(0xFF123456)),
            ),
          ],
        ),
        builder: (context, child) => ToastyProvider(child: child!),
        home: const Scaffold(body: SizedBox()),
      ),
    );
    ToastManager.i.dismissAll();
    FlutterToasty.success('themed');
    await tester.pump();
    Color bgOf(String text) => tester
        .widget<Material>(
          find
              .ancestor(of: find.text(text), matching: find.byType(Material))
              .first,
        )
        .color!;
    expect(bgOf('themed'), const Color(0xFF123456));
    ToastManager.i.dismissAll();
    FlutterToasty.custom(
      message: 'explicit',
      options: const ToastItemOptions(backgroundColor: Color(0xFFABCDEF)),
    );
    await tester.pump();
    expect(bgOf('explicit'), const Color(0xFFABCDEF));
    ToastManager.i.dismissAll();
    await tester.pumpAndSettle();
  });
}

void _reactiveTests() {
  testWidgets('visible toast updates when theme mode changes', (tester) async {
    ToastyTheme themed(String label) =>
        ToastyTheme(builder: (context, data) => Text('$label:${data.message}'));
    final mode = ValueNotifier(ThemeMode.light);
    await tester.pumpWidget(
      ValueListenableBuilder(
        valueListenable: mode,
        builder: (_, m, _) => MaterialApp(
          themeMode: m,
          theme: ThemeData(extensions: [themed('light')]),
          darkTheme: ThemeData.dark().copyWith(extensions: [themed('dark')]),
          builder: (context, child) => ToastyProvider(child: child!),
          home: const Scaffold(body: SizedBox()),
        ),
      ),
    );
    ToastManager.i.dismissAll();
    FlutterToasty.info('x', autoDismiss: false);
    await tester.pump();
    expect(find.text('light:x'), findsOneWidget);

    mode.value = ThemeMode.dark; // toast stays on screen
    await tester.pumpAndSettle();
    expect(find.text('dark:x'), findsOneWidget);
    expect(find.text('light:x'), findsNothing);
    ToastManager.i.dismissAll();
    await tester.pumpAndSettle();
  });

  testWidgets('visible toast updates when the theme builder changes', (
    tester,
  ) async {
    final label = ValueNotifier('one');
    await tester.pumpWidget(
      ValueListenableBuilder(
        valueListenable: label,
        builder: (_, l, _) => MaterialApp(
          theme: ThemeData(
            extensions: [
              ToastyTheme(
                builder: (context, data) => Text('$l:${data.message}'),
              ),
            ],
          ),
          builder: (context, child) => ToastyProvider(child: child!),
          home: const Scaffold(body: SizedBox()),
        ),
      ),
    );
    ToastManager.i.dismissAll();
    FlutterToasty.info('x', autoDismiss: false);
    await tester.pump();
    expect(find.text('one:x'), findsOneWidget);
    label.value = 'two';
    await tester.pumpAndSettle();
    expect(find.text('two:x'), findsOneWidget);
    ToastManager.i.dismissAll();
    await tester.pumpAndSettle();
  });
}
