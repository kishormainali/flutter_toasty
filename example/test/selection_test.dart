import 'package:example/main.dart';
import 'package:example/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_toasty/flutter_toasty.dart';

void main() {
  testWidgets('controls reflect the current selection', (tester) async {
    tester.view.physicalSize = const Size(1000, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    DemoSettings.i.update((s) {
      s.position = ToastPosition.bottomCenter;
      s.themeMode = ThemeMode.system;
      s.showTitle = true;
      s.showProgressBar = true;
      s.autoDismiss = true;
      s.useToastyTheme = true;
      s.useCustomBuilder = false;
      s.durationSeconds = 3;
    });
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    bool chipSelected(String name) => tester
        .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, name))
        .selected;
    bool switchOn(String title) => tester
        .widget<SwitchListTile>(find.widgetWithText(SwitchListTile, title))
        .value;

    // Position chips.
    expect(chipSelected('bottomCenter'), isTrue);
    await tester.tap(find.widgetWithText(ChoiceChip, 'topRight'));
    await tester.pumpAndSettle();
    expect(chipSelected('topRight'), isTrue);
    expect(chipSelected('bottomCenter'), isFalse);

    // Switches.
    for (final title in [
      'Show title',
      'Progress bar',
      'Auto dismiss',
      'Custom builder',
    ]) {
      final before = switchOn(title);
      await tester.tap(find.widgetWithText(SwitchListTile, title));
      await tester.pumpAndSettle();
      expect(switchOn(title), !before, reason: title);
    }

    // Theme mode segments.
    SegmentedButton<ThemeMode> seg() =>
        tester.widget(find.byType(SegmentedButton<ThemeMode>));
    expect(seg().selected, {ThemeMode.system});
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(seg().selected, {ThemeMode.dark});

    // Slider and its label.
    await tester.tap(find.widgetWithText(SwitchListTile, 'Auto dismiss'));
    await tester.pumpAndSettle();
    DemoSettings.i.update((s) => s.durationSeconds = 5);
    await tester.pumpAndSettle();
    expect(find.text('Duration: 5.0s'), findsOneWidget);
  });
}
