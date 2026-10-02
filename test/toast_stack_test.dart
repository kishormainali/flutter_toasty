import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_toasty/flutter_toasty.dart';
import 'package:flutter_toasty/src/_toast_manager.dart';
import 'package:flutter_toasty/src/widgets/toast_widget.dart';

void main() {
  for (final pos in [ToastPosition.bottomCenter, ToastPosition.topCenter]) {
    testWidgets('older toasts peek out behind the newest (${pos.name})', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => ToastyProvider(child: child!),
          home: const Scaffold(body: SizedBox()),
        ),
      );
      ToastManager.i.dismissAll();
      // Older toasts are taller than, and shorter than, the newest one.
      FlutterToasty.success(
        'A long message that wraps over several lines so it is taller ' * 3,
        title: 'first',
        autoDismiss: false,
        position: pos,
      );
      FlutterToasty.error('short', autoDismiss: false, position: pos);
      FlutterToasty.info(
        'newest',
        title: 'n',
        autoDismiss: false,
        position: pos,
      );
      await tester.pumpAndSettle();

      Rect cardOf(int i) => tester.getRect(
        find
            .descendant(
              of: find.byType(ToastWidget).at(i),
              matching: find.byType(Material),
            )
            .first,
      );
      final front = cardOf(2);
      for (final i in [0, 1]) {
        final back = cardOf(i);
        final depth = 2 - i;
        if (pos.isBottom) {
          expect(back.top, lessThan(front.top), reason: 'toast $i peeks above');
          expect(back.bottom, closeTo(front.bottom, 0.5));
        } else {
          expect(
            back.bottom,
            greaterThan(front.bottom),
            reason: 'toast $i peeks below',
          );
          expect(back.top, closeTo(front.top, 0.5));
        }
        expect(
          back.width,
          lessThan(front.width),
          reason: 'depth $depth narrower',
        );
      }
      // Deeper toasts peek out further than shallower ones.
      expect(
        pos.isBottom
            ? cardOf(0).top < cardOf(1).top
            : cardOf(0).bottom > cardOf(1).bottom,
        isTrue,
      );
    });
  }
}
