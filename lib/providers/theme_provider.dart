import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  // 默认为跟随系统 (System)，也可以改为 ThemeMode.light
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  // 判断当前是否是深色模式 (用于 Switch 开关的状态显示)
  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      // 如果是跟随系统，这里简单处理，实际可获取 window.platformBrightness
      return false;
    }
    return _themeMode == ThemeMode.dark;
  }

  // 切换模式的方法
  void toggleTheme(bool isOn) {
    _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); // 通知所有监听者(UI)更新
  }
}