import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'; // For SemanticsService
import 'package:flutter_svg/svg.dart';
import 'package:flutter_toasty/src/_toast_manager.dart';
import 'package:flutter_toasty/src/assets.dart';
import 'package:flutter_toasty/src/models/enums.dart';
import 'package:flutter_toasty/src/models/toast_item.dart';

class ToastWidget extends StatefulWidget {
  const ToastWidget({super.key, required this.item, required this.isActive});

  final ToastItem item;
  final bool isActive;

  @override
  ToastWidgetState createState() => ToastWidgetState();
}

class ToastWidgetState extends State<ToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progressController;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: widget.item.options.dismissDuration,
    );
    if (widget.isActive) _resumeTimer();
    // Accessibility: Announce the toast content after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        SemanticsService.sendAnnouncement(
          View.of(context),
          '${widget.item.title ?? ""} ${widget.item.message}',
          TextDirection.ltr,
        );
      }
    });
  }

  @override
  void didUpdateWidget(covariant ToastWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      widget.isActive ? _resumeTimer() : _pauseTimer();
    }
  }

  void _startTimer() {
    final remaining =
        widget.item.options.dismissDuration * (1 - _progressController.value);
    _dismissTimer = Timer(
      remaining,
      () => ToastManager.i.dismiss(widget.item.id),
    );
    _progressController.forward(from: _progressController.value);
  }

  void _pauseTimer() {
    _dismissTimer?.cancel();
    _progressController.stop();
  }

  void _resumeTimer() {
    final options = widget.item.options;
    if (!options.autoDismiss ||
        !widget.isActive ||
        options.dismissDuration == Duration.zero) {
      return;
    }
    _dismissTimer?.cancel();
    _startTimer();
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final snackBarTheme = theme.snackBarTheme;
    final globalOptions = ToastManager.i.defaultOptions;
    final options = widget.item.options;

    final backgroundColor = options.backgroundColor;
    final resolvedShape =
        options.shape ??
        snackBarTheme.shape ??
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8));

    return Semantics(
      // liveRegion: true tells screen readers to announce this immediately
      liveRegion: true,
      container: true,
      focused: true,
      label: 'Notification',
      child: MouseRegion(
        onEnter: globalOptions.pauseOnHover ? (_) => _pauseTimer() : null,
        onExit: globalOptions.pauseOnHover ? (_) => _resumeTimer() : null,
        child: GestureDetector(
          onTap: () {
            widget.item.onClick?.call();
            if (globalOptions.closeOnClick) {
              ToastManager.i.dismiss(widget.item.id);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: globalOptions.width),
              child: Material(
                elevation: snackBarTheme.elevation ?? 6.0,
                color: backgroundColor,
                shape: resolvedShape,
                clipBehavior: Clip.antiAlias,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ToastContent(item: widget.item),
                    if (options.showProgressBar)
                      _ProgressBar(
                        controller: _progressController,
                        color: options.progressColor,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ToastContent extends StatelessWidget {
  const _ToastContent({required this.item});
  final ToastItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final snackBarTheme = theme.snackBarTheme;
    final options = item.options;

    CrossAxisAlignment contentAlignment = .start;
    if (options.centerIcon || item.title == null) {
      contentAlignment = .center;
    }

    final TextStyle resolvedContentTextStyle =
        options.contentTextStyle ??
        snackBarTheme.contentTextStyle ??
        TextStyle(color: theme.colorScheme.onInverseSurface);

    final TextStyle resolvedTitleTextStyle =
        options.titleTextStyle ??
        snackBarTheme.contentTextStyle?.copyWith(fontWeight: FontWeight.bold) ??
        TextStyle(
          color: theme.colorScheme.onInverseSurface,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        );

    if (item.type == ToastType.custom && item.child != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: DefaultTextStyle(
          style: resolvedContentTextStyle,
          child: item.child!,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: contentAlignment,
        children: [
          if (options.showLeadingIcon && options.icon is! SizedBox)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ExcludeSemantics(child: options.icon),
            ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: .start,
              mainAxisAlignment: options.centerIcon ? .center : .start,
              children: [
                if (item.title != null)
                  Text(item.title!, style: resolvedTitleTextStyle),
                Text(item.message, style: resolvedContentTextStyle),
              ],
            ),
          ),
          if (options.showCloseIcon)
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: _CloseButton(
                id: item.id,
                color: resolvedContentTextStyle.color,
              ),
            ),
        ],
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.id, this.color});
  final String id;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Dismiss notification',
      button: true,
      child: Material(
        shape: const CircleBorder(),
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        child: Tooltip(
          message: 'Dismiss', // Accessibility: Long-press tooltip
          child: InkWell(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: SvgPicture.asset(
                Assets.closeIcon,
                package: 'flutter_toasty',
                width: 18,
                height: 18,
                colorFilter: color != null
                    ? ColorFilter.mode(
                        color!.withValues(alpha: 0.6),
                        BlendMode.srcIn,
                      )
                    : null,
              ),
            ),
            onTap: () => ToastManager.i.dismiss(id),
          ),
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.controller, required this.color});
  final AnimationController controller;
  final Color color;

  @override
  Widget build(BuildContext context) {
    // Progress bars for toasts are decorative/timing based,
    // we hide them from Semantics to avoid cluttering screen reader focus.
    return ExcludeSemantics(
      child: RepaintBoundary(
        child: SizedBox(
          height: 3,
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              return LinearProgressIndicator(
                value: 1 - controller.value,
                backgroundColor: color.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 3,
              );
            },
          ),
        ),
      ),
    );
  }
}
