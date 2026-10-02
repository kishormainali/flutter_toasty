import 'package:flutter/material.dart';
import 'package:flutter_toasty/src/_toast_manager.dart';

import 'models/enums.dart';
import 'models/toasty_options.dart';

/// {@template flutter_toasty}
/// A utility class for displaying various types of toasts (info, success, warning, error, custom)
/// using the internal [ToastManager]. This class provides a simple static interface for showing
/// and dismissing toasts throughout the application.
/// {@endtemplate}
class FlutterToasty {
  ///{@macro flutter_toasty}
  FlutterToasty._();

  /// Internal instance of the ToastManager that handles all toast operations.
  static final ToastManager _manager = ToastManager();

  /// Show an info toast with the given message and optional title, onClick, and onClose callbacks.
  static String info(
    String message, {
    String? title,
    void Function()? onClick,
    void Function()? onClose,
    bool autoDismiss = true,
    Duration dismissDuration = const Duration(seconds: 3),
    List<Widget> actions = const [],
    bool showProgressBar = false,
    Color? progressColor,
    ToastPosition? position,
  }) {
    return _manager.info(
      message,
      title: title,
      onClick: onClick,
      onClose: onClose,
      autoDismiss: autoDismiss,
      dismissDuration: dismissDuration,
      showProgressBar: showProgressBar,
      progressColor: progressColor,
      position: position,
    );
  }

  /// Show a success toast with the given message and optional title, onClick, and onClose callbacks.
  static String success(
    String message, {
    String? title,
    void Function()? onClick,
    void Function()? onClose,
    bool autoDismiss = true,
    Duration dismissDuration = const Duration(seconds: 3),
    bool showProgressBar = false,
    Color? progressColor,
    ToastPosition? position,
  }) {
    return _manager.success(
      message,
      title: title,
      onClick: onClick,
      onClose: onClose,
      autoDismiss: autoDismiss,
      dismissDuration: dismissDuration,
      showProgressBar: showProgressBar,
      progressColor: progressColor,
      position: position,
    );
  }

  /// Show a warning toast with the given message and optional title, onClick, and onClose callbacks.
  static String warning(
    String message, {
    String? title,
    void Function()? onClick,
    void Function()? onClose,
    bool autoDismiss = true,
    Duration dismissDuration = const Duration(seconds: 3),
    bool showProgressBar = false,
    Color? progressColor,
    ToastPosition? position,
  }) {
    return _manager.warning(
      message,
      title: title,
      onClick: onClick,
      onClose: onClose,
      autoDismiss: autoDismiss,
      dismissDuration: dismissDuration,
      showProgressBar: showProgressBar,
      progressColor: progressColor,
      position: position,
    );
  }

  /// Show an error toast with the given message and optional title, onClick, and onClose callbacks.
  static String error(
    String message, {
    String? title,
    void Function()? onClick,
    void Function()? onClose,
    bool autoDismiss = true,
    Duration dismissDuration = const Duration(seconds: 3),
    bool showProgressBar = false,
    Color? progressColor,
    ToastPosition? position,
  }) {
    return _manager.error(
      message,
      title: title,
      onClick: onClick,
      onClose: onClose,
      autoDismiss: autoDismiss,
      dismissDuration: dismissDuration,
      showProgressBar: showProgressBar,
      progressColor: progressColor,
      position: position,
    );
  }

  /// Show a custom toast with the given message, optional title,
  /// child widget, onClick, onClose callbacks, options, and position.
  static String custom({
    String? message,
    String? title,
    Widget? child,
    VoidCallback? onClick,
    VoidCallback? onClose,
    ToastItemOptions? options,
    ToastPosition? position,
  }) {
    assert(
      message != null || child != null,
      'Either message or child must be provided for a custom toast.',
    );
    return _manager.custom(
      message: message,
      title: title,
      child: child,
      onClick: onClick,
      onClose: onClose,
      options: options,
      position: position,
    );
  }

  /// Dismiss a toast by its unique identifier.
  static void dismiss(String id) {
    return _manager.dismiss(id);
  }

  /// Dismiss all currently visible toasts.
  static void dismissAll() {
    return _manager.dismissAll();
  }
}
