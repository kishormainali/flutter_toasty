import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_toasty/flutter_toasty.dart';
import 'package:flutter_toasty/src/_toast_manager.dart';

void main() {
  testWidgets('burst of toasts dismisses one at a time', (tester) async {
    await tester.pumpWidget(
      const ToastyProvider(
        child: MaterialApp(home: Scaffold(body: SizedBox())),
      ),
    );
    ToastManager.i.dismissAll();
    for (final m in ['a', 'b', 'c']) {
      FlutterToasty.info(m);
    }
    List<String> shown() =>
        ToastManager.i.toasts.value.map((t) => t.message).toList();

    await tester.pump(); // build; timers start here
    expect(shown(), ['a', 'b', 'c']);
    await tester.pump(const Duration(milliseconds: 2900));
    expect(shown(), ['a', 'b', 'c']);
    await tester.pump(const Duration(milliseconds: 200)); // ~3.1s
    expect(shown(), ['a', 'b']);
    await tester.pump(const Duration(milliseconds: 2800)); // ~5.9s
    expect(shown(), ['a', 'b']);
    await tester.pump(const Duration(milliseconds: 300)); // ~6.2s
    expect(shown(), ['a']);
    await tester.pump(const Duration(milliseconds: 3000)); // ~9.2s
    expect(shown(), isEmpty);
    await tester.pumpAndSettle();
  });
}
