import 'package:chenbin_app/common/router.dart';
import 'package:chenbin_app/providers/auth_provider.dart';
import 'package:chenbin_app/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:provider/provider.dart';
import 'common/SPUtil.dart';
import 'providers/inventory_provider.dart';
import 'providers/movement_provider.dart';
import 'utils/app_theme.dart';

final ThemeProvider themeProvider = ThemeProvider();

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
        ChangeNotifierProvider(create: (context) => AuthProvider()),
      ],
      child: AnimatedBuilder(
        animation: themeProvider,
        builder: (context, child) {
          return MaterialApp.router(
            routerConfig: getRouter,
            title: 'WMS 仓储管理系统',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode, // 当前模式
            theme: AppTheme.lightTheme,         // 亮色样式
            darkTheme: AppTheme.darkTheme,      // 深色样式
            builder: FlutterSmartDialog.init(),
            locale: const Locale('zh', 'CN'),
          );
        }
      ),
    );
  }
}