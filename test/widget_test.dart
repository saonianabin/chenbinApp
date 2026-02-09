import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:chenbin_app/main.dart';
import 'package:chenbin_app/providers/inventory_provider.dart';
import 'package:chenbin_app/providers/movement_provider.dart';

void main() {
  testWidgets('WMS 应用启动测试', (WidgetTester tester) async {
    // 构建我们的应用并进行一个帧
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => InventoryProvider()),
          ChangeNotifierProvider(create: (context) => MovementProvider()),
        ],
        child: const MyApp(),
      ),
    );

    // 验证我们的应用启动了，并找到 'WMS 仓储管理系统' 文本
    expect(find.text('WMS 仓储管理系统'), findsOneWidget);
    expect(find.text('欢迎使用 WMS 仓储管理系统'), findsOneWidget);
  });
}