import 'package:flutter/material.dart';
import 'package:flutter_toasty/flutter_toasty.dart';

/// Demo settings shared by the app (theme) and the home page (controls).
class DemoSettings extends ChangeNotifier {
  DemoSettings._();
  static final DemoSettings i = DemoSettings._();

  ThemeMode themeMode = ThemeMode.system;
  bool useToastyTheme = true;
  bool useCustomBuilder = false;

  ToastPosition position = ToastPosition.bottomCenter;
  bool showProgressBar = true;
  bool autoDismiss = true;
  bool showTitle = true;
  double durationSeconds = 3;

  void update(void Function(DemoSettings s) change) {
    change(this);
    notifyListeners();
  }
}
