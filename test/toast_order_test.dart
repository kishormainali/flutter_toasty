import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_toasty/flutter_toasty.dart';
import 'package:flutter_toasty/src/_toast_manager.dart';
import 'package:flutter_toasty/src/widgets/toast_widget.dart';

void main() {
  testWidgets('newest toast is on top and dismissed first', (tester) async {
    await tester.pumpWidget(
      const ToastyProvider(
        child: MaterialApp(home: Scaffold(body: SizedBox())),
      ),
    );
    final manager = ToastManager.i;
    manager.dismissAll();

    FlutterToasty.info('first', dismissDuration: const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 500));
    FlutterToasty.info('second', dismissDuration: const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 400));

    // Newest is last in the list, i.e. painted on top of the stack.
    expect(manager.toasts.value.map((t) => t.message), ['first', 'second']);
    // Tree order == paint order: the last widget is drawn on top.
    final widgets = tester.widgetList<ToastWidget>(find.byType(ToastWidget));
    expect(widgets.map((w) => w.item.message), ['first', 'second']);
    expect(widgets.map((w) => w.isActive), [false, true]);

    // Newest dismisses after its own duration; older stays.
    await tester.pump(const Duration(seconds: 3));
    expect(manager.toasts.value.map((t) => t.message), ['first']);

    // Older resumes with its remaining time and then goes.
    await tester.pump(const Duration(seconds: 3));
    expect(manager.toasts.value, isEmpty);
    await tester.pumpAndSettle();
  });
}
