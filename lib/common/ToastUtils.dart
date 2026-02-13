import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter/material.dart';

class ToastUtils {
  // 显示加载中
  static void showLoading({String msg = "加载中..."}) {
    SmartDialog.showLoading(msg: msg);
  }

  // 隐藏加载
  static void dismiss() {
    SmartDialog.dismiss();
  }

  // 普通消息提示
  static void showToast(String msg) {
    SmartDialog.showToast(msg);
  }
}