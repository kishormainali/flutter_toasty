import 'package:flutter/material.dart';
import 'package:flutter_toasty/src/models/_defaults.dart';
import 'package:flutter_toasty/src/models/enums.dart';
import 'package:flutter_toasty/src/models/toast_item.dart';
import 'package:flutter_toasty/src/widgets/toast_widget.dart';

class ToastPositioned extends StatelessWidget {
  final ToastPosition position;
  final List<ToastItem> toasts;

  const ToastPositioned({
    super.key,
    required this.position,
    required this.toasts,
  });

  static const _animationDuration = Duration(milliseconds: 300);

  @override
  Widget build(BuildContext context) {
    final alignment = alignmentMap[position]!;
    final isTop = position.isTop;
    final isBottom = position.isBottom;
    final count = toasts.length;

    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Stack(
            alignment: alignment,
            children: _generateToastItems(isTop, isBottom, count),
          ),
        ),
      ),
    );
  }

  List<Widget> _generateToastItems(bool isTop, bool isBottom, int count) {
    return List.generate(count, (index) {
      final toast = toasts[index];
      final reverseIndex = count - 1 - index;
      final isActiveToast = reverseIndex == 0;

      return AnimatedPositioned(
        key: ValueKey(toast.id),
        curve: Curves.ease,
        top: isTop ? (reverseIndex * 12.0) : null,
        bottom: isBottom ? (reverseIndex * 12.0) : null,
        left: 0,
        right: 0,
        duration: _animationDuration,
        child: AnimatedScale(
          scale: 1 - (reverseIndex * 0.05),
          duration: _animationDuration,
          curve: Curves.ease,
          child: AnimatedOpacity(
            opacity: reverseIndex > 3 ? 0 : 1 - (reverseIndex * 0.2),
            duration: _animationDuration,
            curve: Curves.ease,
            child: IgnorePointer(
              ignoring: !isActiveToast,
              child: ToastWidget(item: toast, isActive: isActiveToast),
            ),
          ),
        ),
      );
    });
  }
}
