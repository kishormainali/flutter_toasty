import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_toasty/flutter_toasty.dart';
import 'package:flutter_toasty/src/_toast_manager.dart';
import 'package:flutter_toasty/src/widgets/toast_widget.dart';

void main() {
  testWidgets('bottom toasts sit above the keyboard', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 2;
    tester.view.viewInsets = const FakeViewPadding(bottom: 600);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => ToastyProvider(child: child!),
        home: const Scaffold(body: SizedBox()),
      ),
    );
    ToastManager.i.dismissAll();
    FlutterToasty.info(
      'hello',
      autoDismiss: false,
      position: ToastPosition.bottomCenter,
    );
    await tester.pumpAndSettle();

    // 600 physical px of keyboard at 2x = 300 logical px.
    final screenHeight = tester.view.physicalSize.height / 2;
    final bottom = tester.getRect(find.byType(ToastWidget)).bottom;
    expect(bottom, lessThanOrEqualTo(screenHeight - 300));
  });
}
