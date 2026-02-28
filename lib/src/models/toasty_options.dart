import 'package:flutter/material.dart';
import 'package:flutter_toasty/src/models/enums.dart';

class ToastItemOptions {
  const ToastItemOptions({
    this.backgroundColor = Colors.white,
    this.titleTextStyle,
    this.contentTextStyle,
    this.icon = const SizedBox.shrink(),
    this.autoDismiss = true,
    this.dismissDuration = const Duration(seconds: 3),
    this.showProgressBar = false,
    this.progressColor = const Color(0x80FFFFFF),
    this.showLeadingIcon = true,
    this.showCloseIcon = true,
  });

  /// The background color of the toast.
  final Color backgroundColor;

  /// text style of the title of the toast.
  final TextStyle? titleTextStyle;

  /// text style of the content of the toast.
  final TextStyle? contentTextStyle;

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
  final Color progressColor;

  /// Whether to show the leading icon in the toast. Defaults to true.
  final bool showLeadingIcon;

  /// Whether to show a close icon in the toast. Defaults to false.
  final bool showCloseIcon;

  ToastItemOptions copyWith({
    Color? backgroundColor,
    TextStyle? titleTextStyle,
    TextStyle? contentTextStyle,
    Widget? icon,
    bool? autoDismiss,
    Duration? dismissDuration,
    bool? showProgressBar,
    Color? progressColor,
    bool? showLeadingIcon,
    bool? showCloseIcon,
  }) {
    return ToastItemOptions(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      titleTextStyle: titleTextStyle ?? this.titleTextStyle,
      contentTextStyle: contentTextStyle ?? this.contentTextStyle,
      icon: icon ?? this.icon,
      autoDismiss: autoDismiss ?? this.autoDismiss,
      dismissDuration: dismissDuration ?? this.dismissDuration,
      showProgressBar: showProgressBar ?? this.showProgressBar,
      progressColor: progressColor ?? this.progressColor,
      showLeadingIcon: showLeadingIcon ?? this.showLeadingIcon,
      showCloseIcon: showCloseIcon ?? this.showCloseIcon,
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
