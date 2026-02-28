import 'package:flutter/material.dart';
import 'package:flutter_toasty/src/_toast_manager.dart';
import 'package:flutter_toasty/src/models/enums.dart';
import 'package:flutter_toasty/src/models/toasty_options.dart';

import 'models/toast_item.dart';
import 'widgets/toast_positioned.dart';

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

  @override
  ToastyProviderState createState() => ToastyProviderState();
}

class ToastyProviderState extends State<ToastyProvider> {
  final GlobalKey<OverlayState> _overlayKey = GlobalKey<OverlayState>();
  late final OverlayEntry _childEntry;

  final Map<ToastPosition, OverlayEntry> _toasts = {};

  final Map<ToastPosition, List<ToastItem>> _lastToastsPerPosition = {};

  @override
  void initState() {
    super.initState();

    /// configure the ToastManager with the provided options and maxToasts
    ToastManager.i.configure(
      options: widget.options,
      maxToasts: widget.maxToasts,
    );

    /// create the overlay entry for the child widget
    _childEntry = OverlayEntry(builder: (context) => widget.child);

    /// Listen changes in the ToastManager and update the toasts accordingly
    ToastManager.i.addToastListener(_updateToasts);
  }

  @override
  void dispose() {
    ToastManager.i.removeToastListener(_updateToasts);
    for (final entry in _toasts.values) {
      entry.remove();
    }

    _toasts.clear();
    _lastToastsPerPosition.clear();

    super.dispose();
  }

  void _updateToasts(List<ToastItem> toasts) {
    final grouped = <ToastPosition, List<ToastItem>>{};
    for (final toast in toasts) {
      grouped.putIfAbsent(toast.position, () => []).add(toast);
    }

    final overlayState = _overlayKey.currentState;
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
            builder: (_) {
              final toasts = _lastToastsPerPosition[pos] ?? [];
              if (toasts.isEmpty) return const SizedBox.shrink();
              return SafeArea(
                top: pos.isBottom,
                bottom: pos.isTop,
                child: ToastPositioned(position: pos, toasts: toasts),
              );
            },
          );
          _toasts[pos] = entry;
          overlayState.insert(entry);
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
