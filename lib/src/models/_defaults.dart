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
    titleTextStyle: TextStyle(
      fontSize: 14,
      color: Colors.white,
      fontWeight: FontWeight.w500,
    ),
    contentTextStyle: TextStyle(fontSize: 12, color: Colors.white),
    icon: SvgPicture.asset(
      Assets.successIcon,
      width: 20,
      height: 20,
      package: 'flutter_toasty',
    ),
    showProgressBar: false,
    progressColor: const Color(0x80FFFFFF),
    showLeadingIcon: true,
    showCloseIcon: true,
    centerIcon: false,
  ),
  ToastType.error: ToastItemOptions(
    backgroundColor: Assets.errorColor,
    titleTextStyle: TextStyle(
      fontSize: 14,
      color: Colors.white,
      fontWeight: FontWeight.w500,
    ),
    contentTextStyle: TextStyle(fontSize: 12, color: Colors.white),
    icon: SvgPicture.asset(
      Assets.errorIcon,
      width: 20,
      height: 20,
      package: 'flutter_toasty',
    ),
    showProgressBar: false,
    progressColor: const Color(0x80FFFFFF),
    showLeadingIcon: true,
    showCloseIcon: true,
    centerIcon: false,
  ),
  ToastType.info: ToastItemOptions(
    backgroundColor: Assets.infoColor,
    titleTextStyle: TextStyle(
      fontSize: 14,
      color: Colors.white,
      fontWeight: FontWeight.w500,
    ),
    contentTextStyle: TextStyle(fontSize: 12, color: Colors.white),
    icon: SvgPicture.asset(
      Assets.infoIcon,
      width: 20,
      height: 20,
      package: 'flutter_toasty',
    ),
    showProgressBar: false,
    progressColor: const Color(0x80FFFFFF),
    showLeadingIcon: true,
    showCloseIcon: true,
    centerIcon: false,
  ),
  ToastType.warning: ToastItemOptions(
    backgroundColor: Assets.warningColor,
    titleTextStyle: TextStyle(
      fontSize: 14,
      color: Colors.white,
      fontWeight: FontWeight.w500,
    ),
    contentTextStyle: TextStyle(fontSize: 12, color: Colors.white),
    icon: SvgPicture.asset(
      Assets.warningIcon,
      width: 20,
      height: 20,
      package: 'flutter_toasty',
    ),
    showProgressBar: false,
    progressColor: const Color(0x80FFFFFF),
    showLeadingIcon: true,
    showCloseIcon: true,
    centerIcon: false,
  ),
  ToastType.custom: ToastItemOptions(
    backgroundColor: Colors.white,
    titleTextStyle: TextStyle(
      fontSize: 14,
      color: Colors.black,
      fontWeight: FontWeight.w500,
    ),
    contentTextStyle: TextStyle(fontSize: 12, color: Colors.black),
    icon: const SizedBox.shrink(),
    showLeadingIcon: false,
    showCloseIcon: false,
    centerIcon: false,
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
