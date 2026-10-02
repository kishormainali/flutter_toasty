import 'package:flutter/material.dart';
import 'package:flutter_toasty/src/models/enums.dart';
import 'package:flutter_toasty/src/models/toasty_options.dart';

/// Everything a [ToastBuilder] needs to render the content of a toast.
class ToastData {
  const ToastData({
    required this.id,
    required this.type,
    required this.message,
    required this.options,
    required this.dismiss,
    this.title,
  });

  /// Unique id of the toast.
  final String id;

  /// The state of the toast (success, error, info, warning, custom).
  final ToastType type;

  /// Optional title passed when showing the toast.
  final String? title;

  /// Message passed when showing the toast.
  final String message;

  /// Resolved options for this toast's [type] (colors, icon, text styles, ...).
  final ToastItemOptions options;

  /// Dismisses this toast.
  final VoidCallback dismiss;
}

/// Builds the content of every toast, regardless of its [ToastType].
///
/// Set it once via [ToastyOptions.builder] instead of calling
/// `FlutterToasty.custom` for each state. Use [ToastData.type] and
/// [ToastData.options] to vary the design per state.
typedef ToastBuilder = Widget Function(BuildContext context, ToastData data);
