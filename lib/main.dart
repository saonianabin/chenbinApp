import 'package:chenbin_app/screens/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'common/SPUtil.dart';
import 'providers/inventory_provider.dart';
import 'providers/movement_provider.dart';
import 'screens/dashboard_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 设置状态栏样式
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  await SPUtil.init();
  runApp(const MyApp());
}

// class AppTheme {
//   // 示例：自定义的浅色主题
//   static ThemeData lightTheme = ThemeData(
//     primarySwatch: Colors.blue,
//     brightness: Brightness.light,
//     fontFamily: 'NotoSansSC',
//     fontFamilyFallback: const ['NotoSansSC'],
//     // 原有其他配置...
//   );
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => InventoryProvider()),
        ChangeNotifierProvider(create: (context) => MovementProvider()),
      ],
      child: MaterialApp(
        title: 'WMS 仓储管理系统',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const LoginPage(),
        locale: const Locale('zh', 'CN'),
      ),
    );
  }
}