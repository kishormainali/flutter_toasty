import 'package:auto_route/auto_route.dart';
import 'package:example/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_toasty/flutter_toasty.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Toasty'),
        actions: [
          IconButton(
            tooltip: 'Dismiss all',
            onPressed: FlutterToasty.dismissAll,
            icon: const Icon(Icons.clear_all),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _Section('Show toast'),
          const _ToastButtons(),
          const _Section('Position'),
          const _PositionPicker(),
          const _Section('Behavior'),
          const _BehaviorControls(),
          const _Section('Theme & customization'),
          const _ThemeControls(),
          const _Section('Overlay checks'),
          const _OverlayChecks(),
        ],
      ),
    );
  }
}

/// Rebuilds [builder] whenever [DemoSettings] changes. The controls use this
/// themselves, because `const` widgets are skipped by a parent's rebuild.
class _Reactive extends StatelessWidget {
  const _Reactive(this.builder);
  final Widget Function(BuildContext context, DemoSettings settings) builder;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: DemoSettings.i,
    builder: (context, _) => builder(context, DemoSettings.i),
  );
}

class _Section extends StatelessWidget {
  const _Section(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 8),
    child: Text(title, style: Theme.of(context).textTheme.titleMedium),
  );
}

/// Shows a toast of [type] using the current demo settings.
void _show(ToastType type) {
  final s = DemoSettings.i;
  final title = s.showTitle
      ? '${type.name[0].toUpperCase()}${type.name.substring(1)}'
      : null;
  final duration = Duration(milliseconds: (s.durationSeconds * 1000).round());
  const message = 'Something happened in your app.';

  switch (type) {
    case ToastType.info:
      FlutterToasty.info(
        message,
        title: title,
        autoDismiss: s.autoDismiss,
        dismissDuration: duration,
        showProgressBar: s.showProgressBar,
        position: s.position,
      );
    case ToastType.success:
      FlutterToasty.success(
        message,
        title: title,
        autoDismiss: s.autoDismiss,
        dismissDuration: duration,
        showProgressBar: s.showProgressBar,
        position: s.position,
      );
    case ToastType.warning:
      FlutterToasty.warning(
        message,
        title: title,
        autoDismiss: s.autoDismiss,
        dismissDuration: duration,
        showProgressBar: s.showProgressBar,
        position: s.position,
      );
    case ToastType.error:
      FlutterToasty.error(
        message,
        title: title,
        autoDismiss: s.autoDismiss,
        dismissDuration: duration,
        showProgressBar: s.showProgressBar,
        position: s.position,
      );
    case ToastType.custom:
      FlutterToasty.custom(
        title: title,
        // Without a builder the child is shown; with one, a message-only
        // custom toast is rendered by the builder too.
        message: s.useCustomBuilder ? message : null,
        child: s.useCustomBuilder ? null : const _CustomChild(),
        position: s.position,
      );
  }
}

class _CustomChild extends StatelessWidget {
  const _CustomChild();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7C4DFF), Color(0xFF00B0FF)],
        ),
      ),
      child: const Row(
        children: [
          Icon(Icons.rocket_launch, color: Colors.white),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Fully custom child via FlutterToasty.custom',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToastButtons extends StatelessWidget {
  const _ToastButtons();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final type in ToastType.values)
          FilledButton.tonal(
            onPressed: () => _show(type),
            child: Text(type == ToastType.custom ? 'Custom' : type.name),
          ),
        OutlinedButton.icon(
          icon: const Icon(Icons.layers),
          onPressed: () {
            for (final t in [
              ToastType.info,
              ToastType.success,
              ToastType.error,
            ]) {
              _show(t);
            }
          },
          label: const Text('Burst of 3'),
        ),
        OutlinedButton.icon(
          icon: const Icon(Icons.push_pin),
          onPressed: () => FlutterToasty.info(
            'Stays until you dismiss it',
            title: 'Sticky',
            autoDismiss: false,
            position: DemoSettings.i.position,
          ),
          label: const Text('Sticky'),
        ),
      ],
    );
  }
}

class _PositionPicker extends StatelessWidget {
  const _PositionPicker();

  @override
  Widget build(BuildContext context) {
    return _Reactive(
      (context, s) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final p in ToastPosition.values)
            ChoiceChip(
              label: Text(p.name),
              selected: s.position == p,
              onSelected: (_) => s.update((s) => s.position = p),
            ),
        ],
      ),
    );
  }
}

class _BehaviorControls extends StatelessWidget {
  const _BehaviorControls();

  @override
  Widget build(BuildContext context) {
    return _Reactive(
      (context, s) => Column(
        children: [
          SwitchListTile(
            title: const Text('Show title'),
            value: s.showTitle,
            onChanged: (v) => s.update((s) => s.showTitle = v),
          ),
          SwitchListTile(
            title: const Text('Progress bar'),
            value: s.showProgressBar,
            onChanged: (v) => s.update((s) => s.showProgressBar = v),
          ),
          SwitchListTile(
            title: const Text('Auto dismiss'),
            value: s.autoDismiss,
            onChanged: (v) => s.update((s) => s.autoDismiss = v),
          ),
          ListTile(
            title: Text('Duration: ${s.durationSeconds.toStringAsFixed(1)}s'),
            subtitle: Slider(
              min: 1,
              max: 8,
              divisions: 14,
              value: s.durationSeconds,
              onChanged: s.autoDismiss
                  ? (v) => s.update((s) => s.durationSeconds = v)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeControls extends StatelessWidget {
  const _ThemeControls();

  @override
  Widget build(BuildContext context) {
    return _Reactive(
      (context, s) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                value: ThemeMode.light,
                icon: Icon(Icons.light_mode),
                label: Text('Light'),
              ),
              ButtonSegment(
                value: ThemeMode.system,
                icon: Icon(Icons.brightness_auto),
                label: Text('System'),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                icon: Icon(Icons.dark_mode),
                label: Text('Dark'),
              ),
            ],
            selected: {s.themeMode},
            onSelectionChanged: (v) => s.update((s) => s.themeMode = v.first),
          ),
          SwitchListTile(
            title: const Text('ToastyTheme colors & icons'),
            subtitle: const Text('Separate light/dark options per state'),
            value: s.useToastyTheme,
            onChanged: (v) => s.update((s) => s.useToastyTheme = v),
          ),
          SwitchListTile(
            title: const Text('Custom builder'),
            subtitle: const Text('One design for every state, no .custom'),
            value: s.useCustomBuilder,
            onChanged: (v) => s.update((s) => s.useCustomBuilder = v),
          ),
        ],
      ),
    );
  }
}

class _OverlayChecks extends StatelessWidget {
  const _OverlayChecks();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        OutlinedButton(
          onPressed: () => showModalBottomSheet(
            context: context,
            builder: (_) => Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Toasts should show above this bottom sheet'),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => _show(ToastType.info),
                    child: const Text('Show toast'),
                  ),
                ],
              ),
            ),
          ),
          child: const Text('Bottom sheet'),
        ),
        OutlinedButton(
          onPressed: () => showDialog<void>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: const Text('Dialog'),
              content: const Text('Toasts should show above this dialog'),
              actions: [
                TextButton(
                  onPressed: () => _show(ToastType.success),
                  child: const Text('Show toast'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
          child: const Text('Dialog'),
        ),
        OutlinedButton(
          onPressed: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (sheetContext) => Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                24 + MediaQuery.viewInsetsOf(sheetContext).bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Focus to open the keyboard',
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Bottom toasts should show above the keyboard'),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => FlutterToasty.info(
                      'Visible above the keyboard',
                      position: ToastPosition.bottomCenter,
                    ),
                    child: const Text('Show bottom toast'),
                  ),
                ],
              ),
            ),
          ),
          child: const Text('Keyboard'),
        ),
      ],
    );
  }
}
