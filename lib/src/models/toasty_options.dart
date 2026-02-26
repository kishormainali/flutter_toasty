import 'package:flutter/material.dart';
import 'package:flutter_toasty/src/models/enums.dart';

class ToastItemOptions {
  const ToastItemOptions({
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
    this.icon = const SizedBox.shrink(),
    this.autoDismiss = true,
    this.dismissDuration = const Duration(seconds: 3),
    this.showProgressBar = false,
    this.progressColor,
  });

  /// The background color of the toast.
  final Color backgroundColor;

  /// The color of the text content in the toast.
  final Color textColor;

  /// The icon widget to display in the toast.
  final Widget icon;

  /// Whether the toast should automatically dismiss after a certain duration. Defaults to true.
  final bool autoDismiss;

  /// The duration before the toast auto-dismisses. Only relevant if [autoDismiss] is true.
  final Duration dismissDuration;

  /// Whether to show a progress bar indicating the remaining time before auto-dismissal. Defaults to true.
  final bool showProgressBar;

  /// The color of the progress bar (if shown) in the toast.
  /// defaults to a semi-transparent textColor if not specified.
  final Color? progressColor;

  ToastItemOptions copyWith({
    Color? backgroundColor,
    Color? textColor,
    Widget? icon,
    bool? autoDismiss,
    Duration? dismissDuration,
    bool? showProgressBar,
    Color? progressColor,
  }) {
    return ToastItemOptions(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      icon: icon ?? this.icon,
      autoDismiss: autoDismiss ?? this.autoDismiss,
      dismissDuration: dismissDuration ?? this.dismissDuration,
      showProgressBar: showProgressBar ?? this.showProgressBar,
      progressColor: progressColor ?? this.progressColor,
    );
  }
}

class ToastyOptions {
  const ToastyOptions({
    this.position = ToastPosition.bottomRight,
    this.pauseOnHover = true,
    this.closeOnClick = true,
    this.width = 300,
    this.dismissDuration = const Duration(seconds: 3),
    this.animationCurve = Curves.easeInOut,
    this.animationDuration = const Duration(milliseconds: 300),
    this.itemOptions,
  });

  final ToastPosition position;
  final bool pauseOnHover;
  final bool closeOnClick;
  final double width;
  final Duration dismissDuration;
  final Curve animationCurve;
  final Duration animationDuration;
  final Map<ToastType, ToastItemOptions>? itemOptions;
}
