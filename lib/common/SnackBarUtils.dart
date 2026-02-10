import 'package:flutter/material.dart';

class SnackBarUtils {
  /// 显示成功提示
  static void showSuccess(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  /// 显示错误提示
  static void showError(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  /// 显示警告提示
  static void showWarning(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      backgroundColor: Colors.orange,
      textColor: Colors.white,
    );
  }

  /// 显示普通信息提示
  static void showInfo(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
    );
  }

  /// 显示自定义SnackBar
  static void showCustom(
      BuildContext context, {
        required String message,
        Color? backgroundColor,
        Color? textColor,
        Duration duration = const Duration(seconds: 2),
        SnackBarBehavior? behavior,
        EdgeInsetsGeometry? margin,
        double? width,
      }) {
    _showSnackBar(
      context,
      message,
      backgroundColor: backgroundColor,
      textColor: textColor,
      duration: duration,
      behavior: behavior,
      margin: margin,
      width: width,
    );
  }

  /// 内部显示SnackBar方法
  static void _showSnackBar(
      BuildContext context,
      String message, {
        Color? backgroundColor,
        Color? textColor,
        Duration duration = const Duration(seconds: 2),
        SnackBarBehavior? behavior,
        EdgeInsetsGeometry? margin,
        double? width,
      }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: textColor ?? Colors.white),
        ),
        backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
        duration: duration,
        behavior: behavior,
        margin: margin,
        width: width,
      ),
    );
  }
}