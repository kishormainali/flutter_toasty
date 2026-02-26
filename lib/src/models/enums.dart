enum ToastPosition {
  topLeft,
  topCenter,
  topRight,
  bottomLeft,
  bottomCenter,
  bottomRight;

  bool get isTop =>
      this == ToastPosition.topLeft ||
      this == ToastPosition.topCenter ||
      this == ToastPosition.topRight;

  bool get isBottom =>
      this == ToastPosition.bottomLeft ||
      this == ToastPosition.bottomCenter ||
      this == ToastPosition.bottomRight;
}

enum ToastType { success, error, info, warning, custom }
