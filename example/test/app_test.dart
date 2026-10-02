import 'package:example/main.dart';
import 'package:example/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_toasty/flutter_toasty.dart';

void main() {
  testWidgets('shows every toast type, positions and custom builder', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    for (final label in ['info', 'success', 'warning', 'error', 'Custom']) {
      FlutterToasty.dismissAll();
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, label));
      await tester.pump();
      expect(find.byType(ToastyProvider), findsOneWidget);
      expect(
        find.textContaining('Something happened').evaluate().isNotEmpty ||
            find.textContaining('Fully custom').evaluate().isNotEmpty,
        isTrue,
        reason: label,
      );
    }

    // Every position renders.
    for (final p in ToastPosition.values) {
      FlutterToasty.dismissAll();
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ChoiceChip, p.name));
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'info'));
      await tester.pump();
      expect(
        find.textContaining('Something happened'),
        findsOneWidget,
        reason: p.name,
      );
    }

    // Custom builder + dark mode.
    FlutterToasty.dismissAll();
    DemoSettings.i.update((s) {
      s.useCustomBuilder = true;
      s.themeMode = ThemeMode.dark;
    });
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'success'));
    await tester.pump();
    expect(find.textContaining('SUCCESS'), findsOneWidget);
    FlutterToasty.dismissAll();
    await tester.pumpAndSettle();
  });

  testWidgets('visible toast reacts to settings changes', (tester) async {
    tester.view.physicalSize = const Size(1000, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    DemoSettings.i.update((s) {
      s.useCustomBuilder = false;
      s.useToastyTheme = true;
      s.themeMode = ThemeMode.light;
      s.autoDismiss = false;
    });
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();
    FlutterToasty.dismissAll();

    await tester.tap(find.widgetWithText(FilledButton, 'success'));
    await tester.pump();
    expect(find.textContaining('SUCCESS'), findsNothing);

    // Builder switch applies to the toast that is already showing.
    DemoSettings.i.update((s) => s.useCustomBuilder = true);
    await tester.pumpAndSettle();
    expect(find.textContaining('SUCCESS'), findsOneWidget);

    // Theme mode switch re-colors it.
    Color cardColor() => tester
        .widget<Material>(
          find
              .ancestor(
                of: find.textContaining('SUCCESS'),
                matching: find.byType(Material),
              )
              .first,
        )
        .color!;
    final light = cardColor();
    DemoSettings.i.update((s) => s.themeMode = ThemeMode.dark);
    await tester.pumpAndSettle();
    expect(cardColor(), isNot(light));

    // Turning the themed colors off falls back to the built-in ones.
    final themed = cardColor();
    DemoSettings.i.update((s) => s.useToastyTheme = false);
    await tester.pumpAndSettle();
    expect(cardColor(), isNot(themed));

    FlutterToasty.dismissAll();
    await tester.pumpAndSettle();
    DemoSettings.i.update((s) => s.autoDismiss = true);
  });
}
