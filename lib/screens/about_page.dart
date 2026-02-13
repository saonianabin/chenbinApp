import 'dart:convert';
import 'dart:developer';

import 'package:chenbin_app/common/SPUtil.dart';
import 'package:chenbin_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../main.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  // 模拟状态：是否开启深色模式（实际开发中应从 Provider/Bloc 获取）
  bool _isDarkMode = false;
  //String codeLogin = SPUtil.getString("code_login");

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<AuthProvider>(context, listen: false).getOrder();
    });
  }

  @override
  Widget build(BuildContext context) {

    // 获取当前主题的数据
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;


    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context, isDark),
            const SizedBox(height: 16),
            _buildStatsCard(context, theme), // 仓库特有的作业数据看板
            const SizedBox(height: 16),
            _buildMenuSection(context, theme, isDark),
            const SizedBox(height: 30),
            _buildLogoutButton(context),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // 1. 顶部用户信息区域
  Widget _buildHeader(BuildContext context, bool isDark) {

    return Container(
      padding: const EdgeInsets.only(top: 60, bottom: 30, left: 20, right: 20),
      decoration: BoxDecoration(
        // 渐变背景：深色模式用深灰渐变，亮色模式用蓝色渐变
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF333333), const Color(0xFF1F1F1F)]
              : [const Color(0xFF1565C0), const Color(0xFF1E88E5)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.blue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // 头像
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const CircleAvatar(
              radius: 35,
              backgroundImage: NetworkImage('https://picsum.photos/150?image=11'),
            ),
          ),
          const SizedBox(width: 15),
          // 信息
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                SPUtil.getString("name_login"),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue[600],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "编号: ${SPUtil.getString("code_login")}",
                  //"编号: ${SPUtil.getString("code_login")} | 一号仓",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ],
          ),
          // const Spacer(),
          // IconButton(
          //   onPressed: () {}, // 跳转到个人资料编辑
          //   icon: const Icon(Icons.edit, color: Colors.white70),
          // )
        ],
      ),
    );
  }

  // 2. 作业数据看板 (WMS 特色)
  Consumer<AuthProvider> _buildStatsCard(BuildContext context, ThemeData theme){
    return Consumer<AuthProvider>(builder: (context, authProvider, child){
      var orderStatistics = authProvider.getOrderStatistics();
      if (orderStatistics == null || orderStatistics.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(theme,"今日订单", "${orderStatistics["data"]["today"]["order"]["totalNum"]}", Colors.orange),
              _buildVerticalDivider(),
              _buildStatItem(theme,"本月订单", "${orderStatistics["data"]["sameMonth"]["order"]["totalNum"]}", Colors.green),
              //_buildVerticalDivider(),
              //_buildStatItem("异常单", "2", Colors.red),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildStatItem(ThemeData theme, String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: color, // 保持数字颜色鲜艳
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.grey[300],
    );
  }


  // --- 功能菜单列表 ---
  Widget _buildMenuSection(BuildContext context, ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildSectionHeader(theme, "作业配置"),
          _buildCardContainer(theme, [
            _buildTile(
              theme,
              icon: Icons.qr_code_scanner,
              title: "PDA 扫码配置",
              subtitle: "广播模式 / 自动回车",
              iconColor: Colors.blue,
              onTap: () {},
            ),
            _buildDivider(theme),
            _buildTile(
              theme,
              icon: Icons.print_outlined,
              title: "蓝牙打印机",
              subtitle: "未连接设备",
              trailingText: "去连接",
              iconColor: Colors.purple,
              onTap: () {},
            ),
          ]),

          const SizedBox(height: 20),
          _buildSectionHeader(theme, "系统设置"),
          _buildCardContainer(theme, [
            _buildTile(
              theme,
              icon: Icons.dark_mode_outlined,
              title: "深色模式",
              iconColor: Colors.amber[700]!,
              // 这里放置 Switch 开关
              trailing: Switch(
                // 绑定到全局 provider
                value: themeProvider.isDarkMode,
                activeColor: Colors.blue,
                onChanged: (val) {
                  // 调用切换方法
                  themeProvider.toggleTheme(val);
                },
              ),
            ),
            _buildDivider(theme),
            _buildTile(
              theme,
              icon: Icons.language,
              title: "多语言 / Language",
              trailingText: "中文",
              iconColor: Colors.teal,
              onTap: () {},
            ),
            _buildDivider(theme),
            _buildTile(
              theme,
              icon: Icons.lock_outline,
              title: "修改密码",
              iconColor: Colors.redAccent,
              onTap: () {},
            ),
          ]),

          const SizedBox(height: 20),
          _buildSectionHeader(theme, "其他"),
          _buildCardContainer(theme, [
            _buildTile(
              theme,
              icon: Icons.info_outline,
              title: "关于系统",
              trailingText: "v1.2.0",
              iconColor: Colors.grey,
              onTap: () {},
            ),
          ]),
        ],
      ),
    );
  }

  // 3. 设置功能列表
  Widget _buildSettingsSection(BuildContext context, ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildGroupTitle(theme,"作业配置"),
          _buildSettingsCard([
            _buildTile(
              theme,
              icon: Icons.qr_code_scanner,
              title: "PDA 扫码配置",
              subtitle: "广播模式 / 自动回车",
              iconColor: Colors.blue,
              onTap: () {},
            ),
            _buildDivider(theme),
            // _buildListTile(
            //   icon: Icons.print,
            //   title: "打印机连接",
            //   subtitle: "未连接",
            //   trailing: const Text("去连接", style: TextStyle(color: Colors.blue)),
            //   onTap: () {},
            // ),
          ]),

          const SizedBox(height: 20),
          _buildGroupTitle(theme,"系统设置"),
          _buildSettingsCard([
            // _buildListTile(
            //   icon: Icons.notifications_outlined,
            //   title: "消息通知",
            //   trailing: Switch(
            //     value: true,
            //     activeColor: Colors.blue,
            //     onChanged: (val) {},
            //   ),
            // ),
            _buildDivider(theme),
            _buildTile(
              theme,
              icon: Icons.dark_mode_outlined,
              title: "深色模式",
              subtitle: "适合夜班作业",
              trailing: Switch(
                // 绑定到全局 provider
                value: themeProvider.isDarkMode,
                activeColor: Colors.blue,
                onChanged: (val) {
                  // 调用切换方法
                  themeProvider.toggleTheme(val);
                },
              ),
              iconColor: Colors.amber[700]!,
            ),
            _buildDivider(theme),
            _buildTile(
              theme,
              icon: Icons.language,
              title: "多语言 / Language",
              trailingText: "中文",
              iconColor: Colors.teal,
              onTap: () {},
            ),
            _buildDivider(theme),
            _buildTile(
              theme,
              icon: Icons.lock_outline,
              title: "修改密码",
              iconColor: Colors.redAccent,
              onTap: () {},
            ),
          ]),

          const SizedBox(height: 20),
          _buildGroupTitle(theme,"关于"),
          _buildSettingsCard([
            _buildTile(
              theme,
              icon: Icons.info_outline,
              title: "关于系统",
              trailingText: "v1.2.0",
              iconColor: Colors.grey,
              onTap: () {},
            ),
          ]),
        ],
      ),
    );
  }

  // 辅助组件：卡片容器
  Widget _buildCardContainer(ThemeData theme, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
            color: theme.textTheme.bodyMedium?.color,
            fontSize: 13,
            fontWeight: FontWeight.bold
        ),
      ),
    );
  }

  // 辅助构建方法：卡片容器
  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }


  Widget _buildTile(
      ThemeData theme, {
        required IconData icon,
        required String title,
        required Color iconColor,
        String? subtitle,
        String? trailingText,
        Widget? trailing,
        VoidCallback? onTap,
      }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1), // 图标背景色浅色
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12))
          : null,
      trailing: trailing ??
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (trailingText != null)
                Text(trailingText, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
              if (trailingText != null) const SizedBox(width: 4),
              Icon(Icons.chevron_right, color: theme.dividerColor.withOpacity(0.5) == Colors.transparent ? Colors.grey : Colors.grey[400]),
            ],
          ),
      onTap: onTap,
    );
  }


  Widget _buildDivider(ThemeData theme) {
    return Divider(height: 1, indent: 64, endIndent: 0, color: theme.dividerColor);
  }

  Widget _buildGroupTitle(ThemeData theme,String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
            color: theme.textTheme.bodyMedium?.color,
            fontSize: 13,
            fontWeight: FontWeight.bold
        ),
      ),
    );
  }

  // 4. 退出登录按钮
  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () {
            showGeneralDialog(
              context: context,
              pageBuilder: (BuildContext buildContext, Animation<double> animation,
                  Animation<double> secondaryAnimation) {
                return TDAlertDialog(
                  content: "确定要退出登录吗？",
                  leftBtnAction: ()=>context.pop(),
                  rightBtnAction: ()=>context.go('/login'),
                );
              },
            );
            /*showDialog(context: context, builder: (_){
              return AlertDialog(
                title: const Text("提示"),
                content: const Text("确定要退出登录吗？"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("取消"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.go('/login');
                    }, child: const Text("确认"),
                  )
                ]
              );
            });*/
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[50],
            foregroundColor: Colors.red,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text("退出登录", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
