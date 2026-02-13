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
  bool _rememberPassword = true;
  @override
  void initState() {
    super.initState();
    _getCacheData();
    _fetchUpdateInfo();
    String userName_login = SPUtil.getString("userName_login");
    String password_login = SPUtil.getString("password_login");
    if (userName_login.isNotEmpty && password_login.isNotEmpty) {
      _usernameController.text = userName_login;
      _passwordController.text = password_login;
    } else {
      _usernameController.text = "";
      _passwordController.text = "";
    }
  }
  // 获取缓存数据
  Future<void> _getCacheData() async {
    _serverController.text =
    SPUtil.getString("IP") == null ? "" : SPUtil.getString("IP").toString();
    _portController.text = SPUtil.getString("PORT") == null
        ? ""
        : SPUtil.getString("PORT").toString();
    if (SPUtil.getString("IP") != null && SPUtil.getString("PORT") != null) {
      var ip = SPUtil.getString("IP").toString();
      var port = SPUtil.getString("PORT").toString();
    }
  }
  // 模拟请求服务器更新信息
  Future<void> _fetchUpdateInfo() async {
    try {
      String ip = SPUtil.getString("IP");
      String port = SPUtil.getString("PORT");
      if (ip.isNotEmpty && port.isNotEmpty) {
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        Map<String, dynamic> queryParameters = {
          'appName': packageInfo.appName,
          'packageName': packageInfo.packageName,
          'version': packageInfo.version,
          'buildNumber': packageInfo.buildNumber,
          'address': ip
        };
        final response = await Http.get('/bom/mobile/appVersion/checkUpdate',
            queryParameters: queryParameters);
        if (response['code'] == 200) {
          // 200表示有更版本
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
  Future<Map<String, dynamic>> getDeviceInfoWithScreen(
      username, password) async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    Map<String, dynamic> deviceData = {};
    try {
      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidInfo =
        await deviceInfoPlugin.androidInfo;
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        final Size screenSize = window.physicalSize;
        deviceData = {
          'appName': packageInfo.appName,
          'packageName': packageInfo.packageName,
          'appVersion': packageInfo.version,
          'buildNumber': packageInfo.buildNumber,
          'userName': username,
          'password': password,
          'platform': 'Android',
          'deviceModel': androidInfo.model,
          'manufacturer': androidInfo.manufacturer,
          'systemVersion': androidInfo.version.release,
          'sdkInt': androidInfo.version.sdkInt,
          'deviceId': androidInfo.id,
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
  Future<void> uploadDeviceInfo(username, password) async {
    try {
      final deviceInfo = await getDeviceInfoWithScreen(username, password);
      Http.post("/bom/device/device-stats", data: deviceInfo);
    } catch (e) {
      log('设备信息上传失败：$e');
    }
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    var isLoading = context.watch<AuthProvider>().isLoading;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Logo和标题
                _buildHeader(theme, isDark),
                const SizedBox(height: 40),
                // 登录表单卡片
                _buildLoginCard(theme, isDark, isLoading),
                const SizedBox(height: 20),
                // 服务器设置
                _buildServerSettings(theme),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
  /// 构建头部
  Widget _buildHeader(ThemeData theme, bool isDark) {
    return Column(
      children: [
        // Logo 图标
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue[600]!,
                Colors.blue[400]!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.warehouse_rounded,
            size: 45,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        // 标题
        Text(
          'WMS 仓储管理',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '欢迎回来，请登录您的账户',
          style: TextStyle(
            fontSize: 14,
            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
  /// 构建登录卡片
  Widget _buildLoginCard(ThemeData theme, bool isDark, bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? Border.all(color: Colors.white.withOpacity(0.1)) : null,
        boxShadow: isDark
            ? null
            : [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 用户名输入框
          _buildInputField(
            controller: _usernameController,
            label: '用户名',
            hint: '请输入用户名',
            icon: Icons.person_outline,
            theme: theme,
            isDark: isDark,
          ),
          const SizedBox(height: 16),

          // 密码输入框
          _buildInputField(
            controller: _passwordController,
            label: '密码',
            hint: '请输入密码',
            icon: Icons.lock_outline,
            theme: theme,
            isDark: isDark,
            isPassword: true,
          ),
          const SizedBox(height: 12),

          // 记住密码
          Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: _rememberPassword,
                  onChanged: (value) {
                    setState(() {
                      _rememberPassword = value ?? false;
                    });
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '记住密码',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 登录按钮
          _buildLoginButton(theme, isLoading),
        ],
      ),
    );
  }
  /// 构建输入框
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required ThemeData theme,
    required bool isDark,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.transparent,
            ),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: isPassword ? !_isPasswordVisible : false,
            style: TextStyle(
              color: theme.textTheme.bodyLarge?.color,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
              ),
              prefixIcon: Icon(
                icon,
                color: Colors.blue[600],
                size: 22,
              ),
              suffixIcon: isPassword
                  ? IconButton(
                icon: Icon(
                  _isPasswordVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                  size: 22,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
  /// 构建登录按钮
  Widget _buildLoginButton(ThemeData theme, bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () async {
          var login = await context.read<AuthProvider>().login(
            _usernameController.text.trim(),
            _passwordController.text.trim(),
          );
          if (login && context.mounted) {
            if (_rememberPassword) {
              SPUtil.setString('userName_login', _usernameController.text.trim());
              SPUtil.setString('password_login', _passwordController.text.trim());
            }
            await context.read<AuthProvider>().getUserInfo();
            context.go("/home");
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: Colors.grey[400],
        ),
        child: isLoading
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : const Text(
          '登录',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
  /// 构建服务器设置按钮
  Widget _buildServerSettings(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.settings_outlined,
          size: 18,
          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
        ),
        TextButton(
          onPressed: _showServerSettings,
          child: Text(
            '服务器设置',
            style: TextStyle(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
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
    Future.delayed(const Duration(milliseconds: 1000), () {});
    try {
      final response =
      await Http.post<Map<String, dynamic>>('/auth/login', queryParameters: {
        'username': username,
        'password': password,
      });
      if (response['code'] == 200) {
        SPUtil.setString('token', response['data']['token']);
        SPUtil.setString('userName_login', username);
        SPUtil.setString('password_login', password);
        context.go("/home");
      } else if (response['code'] == 500) {
        SnackBarUtils.showError(context, response['msg']);
      }
    } catch (e) {
      debugPrint('错误类型: ${e.toString()}');
      SnackBarUtils.showError(context, "网络连接异常");
    } finally {}
  }
  void _showServerSettings() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 24,
            right: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题栏
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.dns_outlined,
                      color: Colors.blue[600],
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '服务器设置',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 服务器地址
              _buildSettingField(
                controller: _serverController,
                label: '服务器地址',
                hint: '例：192.168.1.100',
                icon: Icons.computer,
                theme: theme,
                isDark: isDark,
              ),
              const SizedBox(height: 16),

              // 端口号
              _buildSettingField(
                controller: _portController,
                label: '端口号',
                hint: '例：8080',
                icon: Icons.pin_outlined,
                theme: theme,
                isDark: isDark,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),

              // 保存按钮
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    SPUtil.setString("IP", _serverController.text);
                    SPUtil.setString("PORT", _portController.text);
                    var ip = _serverController.text;
                    var port = _portController.text;
                    if (ip.isEmpty || port.isEmpty) {
                      SnackBarUtils.showWarning(context, "请输入服务器地址和端口");
                      return;
                    }
                    Navigator.of(context).pop();
                    SnackBarUtils.showSuccess(context, "服务器设置已保存");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '保存设置',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  /// 构建设置输入框
  Widget _buildSettingField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required ThemeData theme,
    required bool isDark,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.transparent,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(
              color: theme.textTheme.bodyLarge?.color,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
              ),
              prefixIcon: Icon(
                icon,
                color: Colors.blue[600],
                size: 22,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}