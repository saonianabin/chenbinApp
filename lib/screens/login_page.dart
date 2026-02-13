import 'dart:convert';
import 'dart:developer';
import 'dart:ui';
import 'dart:io';
import 'package:chenbin_app/providers/auth_provider.dart';
import 'package:chenbin_app/screens/dashboard_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../common/SPUtil.dart';
import '../common/SnackBarUtils.dart';
import 'package:flutter/material.dart';
import '../common/Http.dart';
import 'package:flutter_app_update/flutter_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';

class LoginPage extends StatefulWidget {

  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _serverController = TextEditingController();
  final _portController = TextEditingController();
  bool _isPasswordVisible = false;



  @override
  void initState() {
    super.initState();
    _getCacheData();
    _fetchUpdateInfo();
    //_usernameController.text = "admin";
    //_passwordController.text = "admin123";

    String userName_login = SPUtil.getString("userName_login");
    String password_login = SPUtil.getString("password_login");
    if (userName_login.isNotEmpty && password_login.isNotEmpty) {
      _usernameController.text = userName_login;
      _passwordController.text = password_login;
    }else {
      _usernameController.text = "";
      _passwordController.text = "";
    }


  }

  // 获取缓存数据
  Future<void> _getCacheData() async {
    _serverController.text = SPUtil.getString("IP") == null ? "" : SPUtil.getString("IP").toString();
    _portController.text = SPUtil.getString("PORT") == null ? "" : SPUtil.getString("PORT").toString();
    if (SPUtil.getString("IP") != null && SPUtil.getString("PORT") != null) {
      var ip = SPUtil.getString("IP").toString();
      var port = SPUtil.getString("PORT").toString();
    }
    //_usernameController.text = prefs.getString('username') ?? '';
  }

  // 模拟请求服务器更新信息
  Future<void> _fetchUpdateInfo() async {
    try {
      String ip = SPUtil.getString("IP");
      String port = SPUtil.getString("PORT");
      if (ip.isNotEmpty && port.isNotEmpty)
      {
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        Map<String,dynamic> queryParameters = {
          'appName': packageInfo.appName,
          'packageName': packageInfo.packageName,
          'version': packageInfo.version,
          'buildNumber': packageInfo.buildNumber,
          'address':ip
        };
        final response = await Http.get('/bom/mobile/appVersion/checkUpdate', queryParameters: queryParameters);
        if (response['code'] == 200) { // 200表示有更版本
          String apkUrl = response['data']['apkUrl'];
          UpdateModel model = UpdateModel(
            apkUrl,
            "flutterUpdate.apk",
            "ic_launcher",
            apkUrl,
          );
          AzhonAppUpdate.update(model);
        }
      }
    } catch (e) {
      e.runtimeType.toString();
      log('请求更新信息失败：$e');
      return;
    }
  }


  Future<Map<String, dynamic>> getDeviceInfoWithScreen(username,password) async {
    // 初始化设备信息插件
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    Map<String, dynamic> deviceData = {};

    try {
      if (Platform.isAndroid) {
        // Android 设备信息
        final AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        // 获取屏幕分辨率（物理像素）
        final Size screenSize = window.physicalSize;
        deviceData = {
          'appName': packageInfo.appName,
          'packageName': packageInfo.packageName,
          'appVersion': packageInfo.version,
          'buildNumber': packageInfo.buildNumber,
          'userName':username,
          'password':password,
          'platform': 'Android',
          'deviceModel': androidInfo.model, // 设备型号（如 "SM-G998B"）
          'manufacturer': androidInfo.manufacturer, // 厂商（如 "samsung"）
          'systemVersion': androidInfo.version.release, // 系统版本（如 "13"）
          'sdkInt': androidInfo.version.sdkInt, // SDK 版本（如 33）
          'deviceId': androidInfo.id, // 设备唯一标识（需注意隐私）
          'devicePixelRatio': window.devicePixelRatio,
          'screenWidth': screenSize.width.toInt(),
          'screenHeight': screenSize.height.toInt(),
        };

        log("设备信息：$deviceData");
      }
    } catch (e) {
      print('获取设备信息失败：$e');
    }

    return deviceData;
  }

  Future<void> uploadDeviceInfo(username,password) async {
    try {
      final deviceInfo = await getDeviceInfoWithScreen(username,password);
      Http.post("/bom/device/device-stats", data: deviceInfo);
    } catch (e) {
      log('设备信息上传失败：$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 加载状态
    var isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 24, right: 24),
            child: Column(
              children: [
                 const SizedBox(height: 60),
                // Logo和标题
                _buildHeader(),
                const SizedBox(height: 30),
                // 登录表单
                _buildLoginForm(),
                const SizedBox(height: 24),
                // 登录按钮
                _buildLoginButton(),
                const SizedBox(height: 16),
                // 服务器设置
                _buildServerSettings(),
                const SizedBox(height: 40),
                // 其他选项
                //_buildOtherOptions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // 标题
        Text(
          '欢迎使用 WMS 仓储管理',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        // 用户名输入框
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: _usernameController,
            decoration: InputDecoration(
              //labelText: '用户名',
              hintText: '请输入用户名',
              hintStyle: TextStyle(color: Colors.grey),
              prefixIcon: Icon(Icons.person_outline, color: Colors.teal),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
        SizedBox(height: 16),
        // 密码输入框
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              hintText: '请输入密码',
              hintStyle: TextStyle(color: Colors.grey),
              prefixIcon: Icon(Icons.lock_outline, color: Colors.teal),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[600]!, Colors.blue[700]!],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () async {
          // 登录逻辑
          //_handleLogin();
          var login = await context.read<AuthProvider>().login(_usernameController.text.trim(), _passwordController.text.trim());
          if (login && context.mounted) {
            await context.read<AuthProvider>().getUserInfo();
            context.go("/home");
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          '登录',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildServerSettings() {
    return TextButton(
      onPressed: () {
        // 服务器设置页面
        _showServerSettings();
      },
      child: Text(
        '服务器设置',
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 16,
        ),
      ),
    );
  }

  void _handleLogin() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      SnackBarUtils.showWarning(context, "请输入用户名和密码");
      return;
    }

    String ip = SPUtil.getString("IP");
    String port = SPUtil.getString("PORT");
    if (ip.isEmpty || port.isEmpty) {
      SnackBarUtils.showWarning(context, "请先设置服务器IP和端口");
      return;
    }
    //TDToast.showLoading(text: "登录中...",context: context);
    Future.delayed(const Duration(milliseconds: 1000), () {});
    try {
      final response = await Http.post<Map<String, dynamic>>('/auth/login', queryParameters: {
        'username': username,
        'password': password,
      });



      if (response['code'] == 200) {
        SPUtil.setString('token', response['data']['token']);
        SPUtil.setString('userName_login', username);
        SPUtil.setString('password_login', password);
        //uploadDeviceInfo(username,password);
        // 跳转到主页
        //Navigator.of(context).pushReplacementNamed('/indexPage');
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => const DashboardScreen(),
        //   ),
        // );
        context.go("/home");
      }else if (response['code'] == 500) {
        // 提示用户
        SnackBarUtils.showError(context, response['msg']);
      }
    } catch (e) {
      debugPrint('错误类型: ${e.toString()}'); // 如DioExceptionType.connectionError
      // 处理错误
      SnackBarUtils.showError(context, "网络连接异常");
    }finally {
      // 登录完成，关闭加载框
      //TDToast.dismissLoading();
    }
  }

  void _showServerSettings() {
    showModalBottomSheet(
      backgroundColor: Colors.white,
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
        ),
        builder: (_){
      return Padding(
          padding: EdgeInsets.only(
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
          ),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _serverController,
                  keyboardType: TextInputType.number,
                  obscureText: false,
                  decoration: const InputDecoration(
                    labelText: '服务器地址',
                    hintText: '请输入服务器地址',
                  ),
                ),
                const SizedBox(height: 16,),
                TextField(
                    controller: _portController,
                    keyboardType: TextInputType.number,
                    obscureText: false,
                    decoration: const InputDecoration(
                      labelText: '端口号',
                      hintText: '请输入端口号',
                    )
                ),
                const SizedBox(height: 16,),
              ]
          )
      );
    });
    /*showDialog(
      context: context,
      builder: (BuildContext context) {
        return Container();
        return AlertDialog(
          title: "服务器设置",
          contentWidget: Column(
            children: [
              TextField(
                controller: _serverController,
                obscureText: false,
                decoration: const InputDecoration(
                  labelText: '服务器地址',
                  hintText: '请输入服务器地址',
                ),
              ),
              TextField(
                controller: _portController,
                obscureText: false,
                decoration: const InputDecoration(
                  labelText: '端口号',
                  hintText: '请输入端口号',
                ),
              ),
            ],
          ),
          rightBtnAction: () async {

            SPUtil.setString("IP", _serverController.text);
            SPUtil.setString("PORT", _portController.text);

            var ip = _serverController.text;
            var port = _portController.text;
            if (ip.isEmpty || port.isEmpty) {
              //TDToast.showWarning("请输入服务器地址和端口", context: context);
              return;
            }
            Navigator.of(context).pop();
          },
          leftBtnAction: () {
            Navigator.of(context).pop();
          },
        );
      },
    );*/
  }
}