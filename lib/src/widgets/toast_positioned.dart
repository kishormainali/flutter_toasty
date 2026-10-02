import 'package:flutter/material.dart';
import 'package:flutter_toasty/src/models/_defaults.dart';
import 'package:flutter_toasty/src/models/enums.dart';
import 'package:flutter_toasty/src/models/toast_item.dart';
import 'package:flutter_toasty/src/widgets/toast_widget.dart';

/// {@template toast_positioned}
/// A widget that positions and animates a list of toasts based on the specified [ToastPosition].
/// It uses [AnimatedPositioned], [AnimatedScale], and [AnimatedOpacity] to
/// create smooth entrance and exit animations for the toasts.
/// The toasts are stacked with a slight offset to create a layered effect, and only the topmost toast is interactive while the others are ignored for pointer events.
/// {@endtemplate}
class ToastPositioned extends StatelessWidget {
  /// {@macro toast_positioned}
  const ToastPositioned({
    super.key,
    required this.position,
    required this.toasts,
  });

  /// The position of the toasts on the screen, which determines their alignment and animation behavior.
  final ToastPosition position;

  /// The list of toasts to display in this position. The toasts will be animated based on their order in the list, with the most recent toast appearing on top.
  final List<ToastItem> toasts;

  static const _animationDuration = Duration(milliseconds: 300);

  /// How far each older toast peeks out from behind the one in front.
  static const _peek = 12.0;

  /// How much narrower each older toast is than the one in front, per side.
  static const _inset = 10.0;

  @override
  Widget build(BuildContext context) {
    final alignment = alignmentMap[position]!;
    final count = toasts.length;

    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          // The newest toast is the only non-positioned child, so it sizes the
          // stack. Older toasts are stretched to the newest one's height plus
          // their peek, so they always show behind it regardless of height.
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (var index = 0; index < count; index++)
                _buildToast(index, count),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToast(int index, int count) {
    final toast = toasts[index];
    final depth = count - 1 - index;
    final isFront = depth == 0;

    // A global key keeps each toast's state (timer, progress) when it moves
    // between the front slot and a positioned slot as toasts come and go.
    final content = KeyedSubtree(
      key: GlobalObjectKey(toast.id),
      child: AnimatedOpacity(
        opacity: depth > 3 ? 0 : 1 - (depth * 0.2),
        duration: _animationDuration,
        curve: Curves.ease,
        child: IgnorePointer(
          ignoring: !isFront,
          child: RepaintBoundary(
            child: ToastWidget(item: toast, isActive: isFront),
          ),
        ),
      ),
    );

    if (isFront) return content;

    final extend = -(depth * _peek);
    return AnimatedPositioned(
      key: ValueKey(toast.id),
      duration: _animationDuration,
      curve: Curves.ease,
      top: position.isBottom ? extend : 0,
      bottom: position.isBottom ? 0 : extend,
      left: depth * _inset,
      right: depth * _inset,
      child: content,
    );
  }
}
