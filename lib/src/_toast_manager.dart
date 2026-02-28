import 'package:flutter/material.dart';
import 'package:flutter_toasty/src/models/enums.dart';
import 'package:flutter_toasty/src/models/toast_item.dart';

import 'models/_defaults.dart';
import 'models/toasty_options.dart';

/// {@template toast_manager}
/// The [ToastManager] is a singleton class responsible for managing the display and lifecycle of
/// toasts in the application. It provides methods to show different types of toasts
/// (info, success, warning, error, custom) and handles the queuing and dismissal
/// of toasts based on the configured options.
/// The manager maintains a list of active toasts and ensures that the number of displayed toasts
/// does not exceed the specified maximum. It also allows for global configuration of toast behavior
/// and styling through the [configure] method.
/// {@endtemplate}
class ToastManager {
  /// Private constructor for the singleton pattern. This ensures that only one instance of
  ///  the ToastManager exists throughout the application.
  ToastManager._();

  /// The single instance of the ToastManager, accessible via the [i] getter.
  static final ToastManager _instance = ToastManager._();

  /// Getter for the singleton instance of the ToastManager. This allows other parts of the
  /// application to access the manager and show/dismiss toasts without needing to instantiate it.
  static ToastManager get i => _instance;

  /// {@macro toast_manager}
  /// This factory constructor allows for easy access to the singleton instance of the ToastManager.
  factory ToastManager() => _instance;

  /// counter for generating unique toast IDs.
  /// This ensures that each toast has a distinct identifier for management and dismissal.
  int _counter = 0;

  /// helper method to generate a unique ID for each toast.
  /// This is used internally when showing a new toast
  /// to ensure that it can be individually managed and dismissed.
  String _generateId() {
    _counter++;
    return 'toast_$_counter';
  }

  /// The maximum number of toasts that can be displayed at once.
  /// If the limit is reached, additional toasts will be queued and shown when space is available.
  /// This helps prevent overwhelming the user with too many notifications at once.
  int _maxToasts = 3;

  /// The default options for toasts, which can be overridden by individual toast options.
  /// This includes settings like position, auto-close duration, and styling.
  /// These defaults are used when showing a toast without specific options provided.
  ToastyOptions _defaultOptions = ToastyOptions();

  ToastyOptions get defaultOptions => _defaultOptions;

  /// The list of currently displayed toasts, managed as a
  ///  ValueNotifier to allow for reactive updates in the UI.
  /// This list is updated when toasts are added or removed, and
  /// the UI can listen to changes to display the current toasts accordingly.
  final ValueNotifier<List<ToastItem>> _toasts = ValueNotifier([]);
  ValueNotifier<List<ToastItem>> get toasts => _toasts;

  /// Adds a listener to the list of toasts, allowing the UI to
  /// reactively update when toasts are added or removed.
  void addToastListener(void Function(List<ToastItem>) listener) {
    _toasts.addListener(() => listener(_toasts.value));
  }

  /// Removes a previously added listener from the list of toasts.
  void removeToastListener(void Function(List<ToastItem>) listener) {
    _toasts.removeListener(() => listener(_toasts.value));
  }

  /// Configures the ToastManager with custom options and maximum toast count.
  /// This allows you to set global defaults for all toasts, such as position, styling, and behavior.
  /// The [options] parameter can be used to specify default settings for all toasts,
  /// while [maxToasts] sets the maximum number of toasts that can be displayed
  void configure({ToastyOptions? options, int? maxToasts}) {
    _defaultOptions = options ?? defaultToastyOptions;
    _maxToasts = maxToasts ?? _maxToasts;
  }

  /// Helper method to get the options and title for a given toast type.
  ({ToastItemOptions? options, String title}) _getOptionsAndTitle(
    ToastType type,
    String? title,
  ) {
    ToastItemOptions? options = _defaultOptions.itemOptions?[type];
    options ??= defaultItemOptions[type];
    title ??= type.name.capitalize;
    return (options: options, title: title);
  }

  /// Shows a new toast with the given message and options.
  /// This method creates a new ToastItem with the specified parameters and adds it to the list of active toasts.
  /// If the maximum number of toasts is exceeded, it will remove the oldest toast(s) to make room for the new one.
  /// The method returns the unique ID of the newly created toast, which can be used for later dismissal or management.
  String _show(
    String message, {
    ToastType type = ToastType.info,
    String? title,
    Widget? child,
    VoidCallback? onClick,
    VoidCallback? onClose,
    ToastItemOptions? options,
    ToastPosition? position,
  }) {
    options ??= _defaultOptions.itemOptions?[type] ?? ToastItemOptions();
    final id = _generateId();
    position ??= _defaultOptions.position;
    final toast = ToastItem(
      id: id,
      message: message,
      title: title ?? type.name.capitalize,
      child: child,
      onClick: onClick,
      onClose: onClose,
      options: options,
      position: position,
      type: type,
    );
    final current = _toasts.value;

    int posCount = 0;

    for (final item in current) {
      if (item.position == toast.position) {
        posCount++;
      }
    }

    if (_maxToasts > 0 && posCount >= _maxToasts) {
      final itemToRemove = posCount - _maxToasts + 1;
      int removed = 0;
      final newList = <ToastItem>[];
      for (final item in current) {
        if (item.position == toast.position && removed < itemToRemove) {
          item.onClose?.call();
          removed++;
        } else {
          newList.add(item);
        }
      }
      newList.add(toast);
      _toasts.value = newList;
    } else {
      _toasts.value = [...current, toast];
    }
    return id;
  }

  /// Shows an informational toast with the given message and options.
  String info(
    String message, {
    String? title,
    void Function()? onClick,
    void Function()? onClose,
    bool autoDismiss = true,
    Duration dismissDuration = const Duration(seconds: 3),
    bool showProgressBar = false,
    Color? progressColor,
  }) {
    final resolved = _getOptionsAndTitle(ToastType.info, title);
    return _show(
      message,
      type: ToastType.info,
      title: resolved.title,
      onClick: onClick,
      onClose: onClose,
      options: resolved.options?.copyWith(
        autoDismiss: autoDismiss,
        dismissDuration: dismissDuration,
        showProgressBar: showProgressBar,
        progressColor: progressColor,
      ),
    );
  }

  /// Shows a success toast with the given message and options.
  String success(
    String message, {
    String? title,
    void Function()? onClick,
    void Function()? onClose,
    bool autoDismiss = true,
    Duration dismissDuration = const Duration(seconds: 3),
    bool showProgressBar = false,
    Color? progressColor,
  }) {
    final resolved = _getOptionsAndTitle(ToastType.success, title);
    return _show(
      message,
      type: ToastType.success,
      title: resolved.title,
      onClick: onClick,
      onClose: onClose,
      options: resolved.options?.copyWith(
        autoDismiss: autoDismiss,
        dismissDuration: dismissDuration,
        showProgressBar: showProgressBar,
        progressColor: progressColor,
      ),
    );
  }

  /// Shows a warning toast with the given message and options.
  String warning(
    String message, {
    String? title,
    void Function()? onClick,
    void Function()? onClose,
    bool autoDismiss = true,
    Duration dismissDuration = const Duration(seconds: 3),
    bool showProgressBar = false,
    Color? progressColor,
  }) {
    final resolved = _getOptionsAndTitle(ToastType.warning, title);
    return _show(
      message,
      type: ToastType.warning,
      title: resolved.title,
      onClick: onClick,
      onClose: onClose,
      options: resolved.options?.copyWith(
        autoDismiss: autoDismiss,
        dismissDuration: dismissDuration,
        showProgressBar: showProgressBar,
        progressColor: progressColor,
      ),
    );
  }

  /// Shows an error toast with the given message and options.
  String error(
    String message, {
    String? title,
    void Function()? onClick,
    void Function()? onClose,
    bool autoDismiss = true,
    Duration dismissDuration = const Duration(seconds: 3),
    bool showProgressBar = false,
    Color? progressColor,
  }) {
    final resolved = _getOptionsAndTitle(ToastType.error, title);
    return _show(
      message,
      type: ToastType.error,
      title: resolved.title,
      onClick: onClick,
      onClose: onClose,
      options: resolved.options?.copyWith(
        autoDismiss: autoDismiss,
        dismissDuration: dismissDuration,
        showProgressBar: showProgressBar,
        progressColor: progressColor,
      ),
    );
  }

  /// Shows a custom toast with the given message and options.
  /// This allows for fully custom toast content while still using the
  /// manager's show/dismiss functionality.
  /// The [child] parameter can be used to provide a custom widget for
  /// the toast content, replacing the default text and icon.
  /// The [options] parameter can be used to specify custom styling
  /// and behavior for this toast, overriding the defaults.
  /// This method is useful when you want to create a toast
  /// that doesn't fit the standard types (info, success, warning, error)
  ///  and requires a unique appearance or behavior.
  String custom({
    String? message,
    String? title,
    Widget? child,
    void Function()? onClick,
    void Function()? onClose,
    ToastItemOptions? options,
    ToastPosition? position,
  }) {
    assert(
      child != null || message != null,
      'Either a message or a child widget must be provided for a custom toast.',
    );
    options ??= _defaultOptions.itemOptions?[ToastType.custom];
    options ??= defaultItemOptions[ToastType.custom];
    position ??= _defaultOptions.position;
    return _show(
      message ?? '',
      type: ToastType.custom,
      title: title,
      child: child,
      onClick: onClick,
      onClose: onClose,
      options: options,
      position: position,
    );
  }

  /// Dismisses a toast with the given ID.
  /// This method removes the toast from the list of active toasts and triggers any associated
  /// onClose callbacks. The [id] parameter is the unique identifier of the toast to be dismissed,
  ///  which is returned when the toast is shown.
  void dismiss(String id) {
    final current = _toasts.value;
    final newList = current.where((item) => item.id != id).toList();
    _toasts.value = newList;
  }

  /// Dismisses all active toasts.
  /// This method clears the entire list of active toasts and triggers
  /// any associated onClose callbacks
  /// for each toast. This is useful for scenarios where you want to quickly
  /// remove all notifications from the screen,
  /// such as when navigating away from a page or resetting the application state.
  void dismissAll() {
    final current = _toasts.value;
    if (current.isEmpty) return;
    for (final toast in current) {
      toast.onClose?.call();
    }
    _toasts.value = const [];
  }
}

extension _StringX on String {
  String get capitalize {
    final lower = toLowerCase();
    return '${lower[0].toUpperCase()}${lower.substring(1)}';
  }
}
