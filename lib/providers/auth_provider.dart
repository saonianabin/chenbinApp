import 'package:chenbin_app/common/ToastUtils.dart';
import 'package:flutter/material.dart';

import '../repositories/UserRepository.dart';

class AuthProvider extends ChangeNotifier{
    bool _isLoading = false;
    Map<String, dynamic> _statistics = {};
    bool get isLoading => _isLoading;

    final UserRepository _userRepository = UserRepository();

    Future<bool> login(String username, String password) async {
      if (username.isEmpty || password.isEmpty) {
        ToastUtils.showToast("请输入用户名和密码");
        return false;
      }
      ToastUtils.showLoading(msg: "登录中...");
      _isLoading = true;
      try{
        notifyListeners();
        Future.delayed(const Duration(milliseconds: 1000), () {});
        await _userRepository.login(username, password);
        ToastUtils.showToast("登录成功");
        return true;
      } catch(e){
        ToastUtils.showToast("登录失败");
        return false;
      }finally {
        _isLoading = false;
        ToastUtils.dismiss();
        notifyListeners();
      }
    }

    Future getUserInfo() async {
      var result = await _userRepository.getInfo();
      return result;
    }

    Future<Map<String, dynamic>>  getOrder() async {
      var map = await _userRepository.getOrder();
      _statistics = map;
      notifyListeners();
      return _statistics;
    }

    Map<String, dynamic> getOrderStatistics() {
      return _statistics;
    }
}