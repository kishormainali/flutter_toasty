import 'package:flutter/material.dart';
import 'package:flutter_toasty/src/models/enums.dart';
import 'package:flutter_toasty/src/models/toast_data.dart';
import 'package:flutter_toasty/src/models/toasty_options.dart';

/// {@template toasty_theme}
/// Theme extension that holds everything *visual* about toasts, so they follow
/// light/dark mode like any other Flutter widget. Behavior (position, width,
/// hover, max toasts) stays in `ToastyOptions`.
///
/// ```dart
/// MaterialApp(
///   theme: ThemeData(
///     extensions: [ToastyTheme(success: ToastItemOptions(...))],
///   ),
///   darkTheme: ThemeData.dark().copyWith(
///     extensions: [ToastyTheme(success: ToastItemOptions(...))],
///   ),
///   builder: (context, child) => ToastyProvider(child: child!),
/// )
/// ```
///
/// Where a toast's look comes from, highest priority first:
/// 1. `options` passed to a single `FlutterToasty.custom` call
/// 2. this theme
/// 3. `ToastyOptions.itemOptions` (deprecated)
/// 4. the built-in defaults
///
/// Any state you leave `null` falls through to the next level.
/// {@endtemplate}
@immutable
class ToastyTheme extends ThemeExtension<ToastyTheme> {
  /// {@macro toasty_theme}
  const ToastyTheme({
    this.success,
    this.error,
    this.warning,
    this.info,
    this.custom,
    this.builder,
  });

  /// Visual options for success toasts.
  final ToastItemOptions? success;

  /// Visual options for error toasts.
  final ToastItemOptions? error;

  /// Visual options for warning toasts.
  final ToastItemOptions? warning;

  /// Visual options for info toasts.
  final ToastItemOptions? info;

  /// Visual options for custom toasts.
  final ToastItemOptions? custom;

  /// Replaces the content of every toast, so all states share one design.
  ///
  /// The card (background, shape, elevation), progress bar, hover and tap
  /// handling still come from the per-state options. A `child` passed to
  /// `FlutterToasty.custom` takes precedence over this builder.
  final ToastBuilder? builder;

  /// Applies the same [options] to every state.
  const ToastyTheme.all(ToastItemOptions options, {this.builder})
    : success = options,
      error = options,
      warning = options,
      info = options,
      custom = options;

  /// The theme registered on [context]'s [ThemeData], if any.
  static ToastyTheme? maybeOf(BuildContext context) =>
      Theme.of(context).extension<ToastyTheme>();

  /// The options this theme defines for [type], or `null` to fall through.
  ToastItemOptions? optionsFor(ToastType type) => switch (type) {
    ToastType.success => success,
    ToastType.error => error,
    ToastType.warning => warning,
    ToastType.info => info,
    ToastType.custom => custom,
  };

  @override
  ToastyTheme copyWith({
    ToastItemOptions? success,
    ToastItemOptions? error,
    ToastItemOptions? warning,
    ToastItemOptions? info,
    ToastItemOptions? custom,
    ToastBuilder? builder,
  }) {
    return ToastyTheme(
      success: success ?? this.success,
      error: error ?? this.error,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      custom: custom ?? this.custom,
      builder: builder ?? this.builder,
    );
  }

  /// Toast content can't be meaningfully interpolated, so this switches at the
  /// halfway point of a theme animation.
  @override
  ToastyTheme lerp(covariant ToastyTheme? other, double t) {
    if (other == null) return this;
    return t < 0.5 ? this : other;
  }
}
