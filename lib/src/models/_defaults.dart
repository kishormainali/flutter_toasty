import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../assets.dart';
import 'enums.dart';
import 'toasty_options.dart';

const alignmentMap = {
  ToastPosition.topLeft: Alignment.topLeft,
  ToastPosition.topCenter: Alignment.topCenter,
  ToastPosition.topRight: Alignment.topRight,
  ToastPosition.bottomLeft: Alignment.bottomLeft,
  ToastPosition.bottomCenter: Alignment.bottomCenter,
  ToastPosition.bottomRight: Alignment.bottomRight,
};

final defaultItemOptions = {
  ToastType.success: ToastItemOptions(
    backgroundColor: Assets.successColor,
    textColor: Colors.white,
    icon: SvgPicture.asset(
      Assets.successIcon,
      width: 24,
      height: 24,
      package: 'flutter_toasty',
    ),
  ),
  ToastType.error: ToastItemOptions(
    backgroundColor: Assets.errorColor,
    textColor: Colors.white,
    icon: SvgPicture.asset(
      Assets.errorIcon,
      width: 24,
      height: 24,
      package: 'flutter_toasty',
    ),
  ),
  ToastType.info: ToastItemOptions(
    backgroundColor: Assets.infoColor,
    textColor: Colors.white,
    icon: SvgPicture.asset(
      Assets.infoIcon,
      width: 24,
      height: 24,
      package: 'flutter_toasty',
    ),
  ),
  ToastType.warning: ToastItemOptions(
    backgroundColor: Assets.warningColor,
    textColor: Colors.white,
    icon: SvgPicture.asset(
      Assets.warningIcon,
      width: 24,
      height: 24,
      package: 'flutter_toasty',
    ),
  ),
  ToastType.custom: ToastItemOptions(
    backgroundColor: Colors.white,
    textColor: Colors.black,
    icon: const SizedBox.shrink(),
  ),
};

final defaultToastyOptions = ToastyOptions(
  position: ToastPosition.bottomCenter,
  pauseOnHover: true,
  closeOnClick: true,
  width: 320,
  dismissDuration: const Duration(seconds: 3),
  animationCurve: Curves.easeInOut,
  animationDuration: const Duration(milliseconds: 300),
  itemOptions: defaultItemOptions,
);
