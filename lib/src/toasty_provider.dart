import 'package:flutter/material.dart';
import 'package:flutter_toasty/src/_toast_manager.dart';
import 'package:flutter_toasty/src/models/enums.dart';
import 'package:flutter_toasty/src/models/toasty_options.dart';

import 'models/toast_item.dart';
import 'widgets/toast_positioned.dart';

/// A helper widget that provides Material context to toast content
/// by inheriting Theme, MediaQuery, and Directionality from the app context
class _ToastContextProvider extends StatelessWidget {
  const _ToastContextProvider({
    required this.materialContext,
    required this.position,
    required this.toasts,
    required this.safeAreaMinimum,
  });

  final BuildContext materialContext;
  final ToastPosition position;
  final List<ToastItem> toasts;
  final EdgeInsets safeAreaMinimum;

  @override
  Widget build(BuildContext context) {
    // Inherit all Material theme data from the app context
    final theme = Theme.of(materialContext);
    final textDirection = Directionality.of(materialContext);

    return Theme(
      data: theme,
      child: Directionality(
        textDirection: textDirection,
        // Keep toasts clear of the status bar, notch, home indicator, etc.
        child: SafeArea(
          minimum: safeAreaMinimum,
          child: ToastPositioned(position: position, toasts: toasts),
        ),
      ),
    );
  }
}

/// {@template toasty_provider}
/// A provider widget that manages the display of toasts in the application.
/// It uses an [Overlay] to display toasts above the main content, and listens to changes in
/// the [ToastManager] to update the displayed toasts accordingly.
/// The provider should be placed near the root of the widget tree to ensure that toasts
/// can be displayed over all content.
/// It also handles the configuration of the [ToastManager] with the provided options
/// and maximum number of toasts.
/// {@endtemplate}
class ToastyProvider extends StatefulWidget {
  /// {@macro toasty_provider}
  const ToastyProvider({
    super.key,
    required this.child,
    this.options,
    this.maxToasts,
    this.safeAreaMinimum = EdgeInsets.zero,
  });

  /// The child widget that will be wrapped by the provider.
  /// This is typically the main content of the app, and the toasts
  /// will be displayed above this content using an [Overlay].
  final Widget child;

  /// Optional configuration options for the [ToastManager].
  /// This can include default styling, behavior, and other settings
  /// that will apply to all toasts managed by the provider.
  final ToastyOptions? options;

  /// The maximum number of toasts that can be displayed at once.
  /// If the limit is exceeded, the oldest toast will be dismissed to
  /// make room for new ones. This helps prevent overwhelming the user with too
  ///  many toasts and ensures a better user experience.
  final int? maxToasts;

  /// Minimum padding kept between the toasts and the screen edges, applied
  /// on top of the system insets (status bar, notch, home indicator).
  /// Each side uses whichever is larger: the system inset or this value.
  final EdgeInsets safeAreaMinimum;

  @override
  ToastyProviderState createState() => ToastyProviderState();
}

class ToastyProviderState extends State<ToastyProvider> {
  final GlobalKey<OverlayState> _overlayKey = GlobalKey<OverlayState>();
  late final OverlayEntry _childEntry;
  final Map<ToastPosition, OverlayEntry> _toasts = {};
  final Map<ToastPosition, List<ToastItem>> _lastToastsPerPosition = {};
  late final VoidCallback _listener;
  bool _contextValidated = false;
  late BuildContext _materialAppContext;

  @override
  void initState() {
    super.initState();

    /// configure the ToastManager with the provided options and maxToasts
    ToastManager.i.configure(
      options: widget.options,
      maxToasts: widget.maxToasts,
    );

    /// create the overlay entry for the child widget and capture its context
    _childEntry = OverlayEntry(
      builder: (context) {
        return Builder(
          builder: (innerContext) {
            _materialAppContext = innerContext;
            // Depend on the theme so toasts already on screen are rebuilt
            // whenever it changes (including each step of its animation).
            Theme.of(innerContext);
            _refreshToasts();
            return widget.child;
          },
        );
      },
    );

    /// Listen changes in the ToastManager and update the toasts accordingly
    _listener = ToastManager.i.addToastListener(_updateToasts);
  }

  @override
  void didUpdateWidget(covariant ToastyProvider oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The app rebuilt (theme mode, theme extensions...): rebuild toasts
    // that are already on screen so they pick up the new theme right away.
    _refreshToasts();
    if (widget.options != oldWidget.options ||
        widget.maxToasts != oldWidget.maxToasts) {
      ToastManager.i.configure(
        options: widget.options,
        maxToasts: widget.maxToasts,
      );
    }
  }

  bool _refreshScheduled = false;

  /// Rebuilds the toasts on screen after the current frame (entries can't be
  /// marked dirty while the tree is building).
  void _refreshToasts() {
    if (_refreshScheduled || _toasts.isEmpty) return;
    _refreshScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshScheduled = false;
      if (!mounted) return;
      for (final entry in _toasts.values) {
        entry.markNeedsBuild();
      }
    });
    WidgetsBinding.instance.scheduleFrame();
  }

  void _validateContext() {
    if (_contextValidated) return;

    try {
      // Check for required Material context dependencies
      MediaQuery.of(_materialAppContext);
      Theme.of(_materialAppContext);
      Directionality.of(_materialAppContext);
      _contextValidated = true;
    } catch (e) {
      throw FlutterError(
        'ToastyProvider must be placed inside a MaterialApp, CupertinoApp, or WidgetsApp.\n'
        'The context does not have access to required material/cupertino/widgets dependencies.\n'
        'Please ensure your app structure is:\n\n'
        'ToastyProvider(\n'
        '  child: MaterialApp(\n'
        '    home: Scaffold(...),\n'
        '  ),\n'
        ')\n\n'
        'Error details: $e',
      );
    }
  }

  @override
  void dispose() {
    ToastManager.i.removeToastListener(_listener);
    for (final entry in _toasts.values) {
      entry.remove();
    }

    _toasts.clear();
    _lastToastsPerPosition.clear();

    super.dispose();
  }

  void _updateToasts(List<ToastItem> toasts) {
    if (!mounted) return;

    /// Validate context on first toast display
    try {
      _validateContext();
    } catch (e) {
      debugPrintStack(label: 'ToastyProvider validation error: $e');
      return;
    }

    final grouped = <ToastPosition, List<ToastItem>>{};
    for (final toast in toasts) {
      grouped.putIfAbsent(toast.position, () => []).add(toast);
    }

    // Try to get overlay state from Material app context first (has proper Material context)
    OverlayState? overlayState;
    try {
      overlayState = Overlay.of(_materialAppContext);
    } catch (e) {
      try {
        // Fallback to global overlay key if Material context overlay is not available
        overlayState = _overlayKey.currentState;
      } catch (e) {
        debugPrintStack(label: 'ToastyProvider overlay access error: $e');
        return;
      }
    }

    if (overlayState == null) return;

    // Remove toasts that are no longer present
    final positionsToRemove = _toasts.keys
        .where((pos) => !grouped.containsKey(pos))
        .toList(growable: false);
    for (final pos in positionsToRemove) {
      _toasts[pos]?.remove();
      _toasts.remove(pos);
      _lastToastsPerPosition.remove(pos);
    }

    // Add or update toasts for each position
    for (final entry in grouped.entries) {
      final pos = entry.key;
      final items = entry.value;
      final lastItems = _lastToastsPerPosition[pos] ?? [];

      bool hasChanged = false;
      if (items.length != lastItems.length) {
        hasChanged = true;
      } else {
        for (int i = 0; i < items.length; i++) {
          if (items[i].id != lastItems[i].id) {
            hasChanged = true;
            break;
          }
        }
      }
      if (hasChanged) {
        _lastToastsPerPosition[pos] = items;
        if (_toasts.containsKey(pos)) {
          _toasts[pos]?.markNeedsBuild();
        } else {
          final entry = OverlayEntry(
            builder: (overlayContext) {
              final toasts = _lastToastsPerPosition[pos] ?? [];
              if (toasts.isEmpty) return const SizedBox.shrink();
              // Use a custom widget to inherit Material context from the app
              return _ToastContextProvider(
                materialContext: _materialAppContext,
                position: pos,
                toasts: toasts,
                safeAreaMinimum: widget.safeAreaMinimum,
              );
            },
          );
          _toasts[pos] = entry;
          try {
            overlayState.insert(entry);
          } catch (e) {
            debugPrintStack(
              label:
                  'ToastyProvider overlay insertion error for position $pos: $e',
            );
            _toasts.remove(pos);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Overlay(key: _overlayKey, initialEntries: [_childEntry]),
    );
  }
}
