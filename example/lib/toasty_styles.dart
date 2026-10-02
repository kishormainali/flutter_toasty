import 'package:flutter/material.dart';
import 'package:flutter_toasty/flutter_toasty.dart';

/// Per-state colors/icons for one brightness, so light and dark mode each get
/// their own look.
ToastyTheme _theme(Brightness brightness, {ToastBuilder? builder}) {
  final dark = brightness == Brightness.dark;

  ToastItemOptions style(Color accent, IconData icon) {
    final background = dark
        ? Color.alphaBlend(
            accent.withValues(alpha: 0.22),
            const Color(0xFF1E1E1E),
          )
        : Color.alphaBlend(accent.withValues(alpha: 0.12), Colors.white);
    final text = dark ? Colors.white : const Color(0xFF1B1B1F);
    return ToastItemOptions(
      backgroundColor: background,
      titleTextStyle: TextStyle(
        color: text,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: TextStyle(
        color: text.withValues(alpha: 0.85),
        fontSize: 13,
      ),
      icon: Icon(icon, color: accent, size: 22),
      progressColor: accent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: accent.withValues(alpha: 0.4)),
      ),
    );
  }

  return ToastyTheme(
    success: style(Colors.green, Icons.check_circle_rounded),
    error: style(Colors.red, Icons.error_rounded),
    warning: style(Colors.orange, Icons.warning_rounded),
    info: style(Colors.blue, Icons.info_rounded),
    custom: style(Colors.purple, Icons.auto_awesome_rounded),
    builder: builder,
  );
}

/// One design for every state: an accent bar, state icon, title, message and a
/// close button. Built from [ToastData], so no `FlutterToasty.custom` is needed.
Widget customToastBuilder(BuildContext context, ToastData data) {
  final options = data.options;
  final accent = options.progressColor;
  return IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ColoredBox(color: accent, child: const SizedBox(width: 6)),
        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: options.icon,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (data.title != null)
                  Text(
                    '${data.title} · ${data.type.name.toUpperCase()}',
                    style: options.titleTextStyle,
                  ),
                Text(data.message, style: options.contentTextStyle),
              ],
            ),
          ),
        ),
        IconButton(
          tooltip: 'Dismiss',
          onPressed: data.dismiss,
          icon: Icon(
            Icons.close,
            size: 18,
            color: options.contentTextStyle?.color,
          ),
        ),
      ],
    ),
  );
}

ThemeData buildTheme(
  Brightness brightness, {
  required bool useToastyTheme,
  required bool useCustomBuilder,
}) {
  return ThemeData(
    colorSchemeSeed: Colors.indigo,
    brightness: brightness,
    useMaterial3: true,
    extensions: [
      // Colors/icons from the theme and/or the builder; with neither, the
      // built-in look is used.
      if (useToastyTheme)
        _theme(
          brightness,
          builder: useCustomBuilder ? customToastBuilder : null,
        )
      else if (useCustomBuilder)
        const ToastyTheme(builder: customToastBuilder),
    ],
  );
}
