import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_toasty/src/_toast_manager.dart';
import 'package:flutter_toasty/src/assets.dart';
import 'package:flutter_toasty/src/models/enums.dart';
import 'package:flutter_toasty/src/models/toast_item.dart';
import 'package:flutter_toasty/src/models/toasty_options.dart';

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

  late ToastItemOptions _options;
  late ToastyOptions _globalOptions;

  @override
  void initState() {
    super.initState();
    _options = widget.item.options;
    _globalOptions = ToastManager.i.defaultOptions;
    _progressController = AnimationController(
      vsync: this,
      duration: _options.dismissDuration,
    );
    if (widget.isActive) _resumeTimer();
  }

  @override
  void didUpdateWidget(covariant ToastWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      widget.isActive ? _resumeTimer() : _pauseTimer();
    }
    if (widget.item.options != oldWidget.item.options) {
      _options = widget.item.options;
    }
  }

  void _startTimer() {
    final remaining =
        _options.dismissDuration * (1 - _progressController.value);
    _dismissTimer = Timer(remaining, () {
      ToastManager.i.dismiss(widget.item.id);
    });
    _progressController.forward(from: _progressController.value);
  }

  void _pauseTimer() {
    _dismissTimer?.cancel();
    _progressController.stop();
  }

  void _resumeTimer() {
    if (!_options.autoDismiss) return;
    if (!widget.isActive) return;
    if (_options.dismissDuration == Duration.zero) return;
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
    return MouseRegion(
      onEnter: _globalOptions.pauseOnHover ? (_) => _pauseTimer() : null,
      onExit: _globalOptions.pauseOnHover ? (_) => _resumeTimer() : null,
      child: GestureDetector(
        onTap: () {
          widget.item.onClick?.call();
          if (_globalOptions.closeOnClick) {
            ToastManager.i.dismiss(widget.item.id);
          }
        },
        child: RepaintBoundary(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final deviceWidth = MediaQuery.of(context).size.width;
              final maxWidth = max(0.0, deviceWidth - 32);
              final effectiveWidth = min(_globalOptions.width, maxWidth);
              return Container(
                width: effectiveWidth,
                decoration: BoxDecoration(
                  color: _options.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: .antiAlias,
                child: Column(
                  mainAxisSize: .min,
                  children: [
                    _ToastContent(item: widget.item, options: _options),
                    if (_options.showProgressBar)
                      _ProgressBar(
                        controller: _progressController,
                        color: _options.progressColor ?? _options.textColor,
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ToastContent extends StatelessWidget {
  const _ToastContent({required this.item, required this.options});

  final ToastItem item;
  final ToastItemOptions options;

  @override
  Widget build(BuildContext context) {
    if (item.type == ToastType.custom && item.child != null) {
      return Padding(padding: const EdgeInsets.all(16), child: item.child!);
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: item.title == null ? .center : .start,
        children: [
          options.icon,
          if (options.icon is! SizedBox) const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisSize: .min,
              crossAxisAlignment: .start,
              children: [
                if (item.title != null)
                  Text(
                    item.title!,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: options.textColor,
                    ),
                  ),
                if (item.title != null) const SizedBox(height: 4),
                Text(
                  item.message,
                  style: TextStyle(fontSize: 14, color: options.textColor),
                ),
              ],
            ),
          ),
          CloseIcon(id: item.id),
        ],
      ),
    );
  }
}

class CloseIcon extends StatelessWidget {
  const CloseIcon({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => ToastManager.i.dismiss(id),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: SvgPicture.asset(
            Assets.closeIcon,
            package: 'flutter_toasty',
            width: 16,
            height: 16,
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
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return LinearProgressIndicator(
            value: 1 - controller.value,
            valueColor: AlwaysStoppedAnimation<Color>(
              color.withValues(alpha: 0.4),
            ),
            backgroundColor: Colors.transparent,
            minHeight: 4,
          );
        },
      ),
    );
  }
}
