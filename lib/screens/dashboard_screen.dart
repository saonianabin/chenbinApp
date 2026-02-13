import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../providers/movement_provider.dart';
import '../utils/app_theme.dart';
import 'inventory_list_screen.dart';
import 'movement_list_screen.dart';
import 'inbound_order.dart';
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}
class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // 初始化数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MovementProvider>(context, listen: false)
          .fetchNetworkLoadInboundList();
      Provider.of<MovementProvider>(context, listen: false)
          .fetchNetworkLoadOutboundList();
    });
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('WMS 仓储管理'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 欢迎信息卡片
            _buildWelcomeCard(context, theme, isDark),
            const SizedBox(height: 12),
            // 任务概览
            _buildTaskOverview(context, theme, isDark),
            const SizedBox(height: 12),
            // 快捷操作
            _buildQuickActions(context, theme, isDark),
          ],
        ),
      ),
    );
  }
  /// 构建欢迎卡片 - 紧凑版
  Widget _buildWelcomeCard(BuildContext context, ThemeData theme, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1976D2), const Color(0xFF0288D1)]
              : [AppTheme.primaryColor, AppTheme.accentColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.4)
                : Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'WMS 仓储管理系统',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(DateTime.now()),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.dashboard_rounded,
            size: 36,
            color: Colors.white.withOpacity(0.8),
          ),
        ],
      ),
    );
  }
  /// 构建任务概览区域 - 紧凑版
  Widget _buildTaskOverview(BuildContext context, ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题栏
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 3,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '任务概览',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            // 查看全部按钮
            TextButton.icon(
              onPressed: () => _navigateToMovementList(context),
              icon: const Icon(Icons.list_alt, size: 16),
              label: const Text('全部', style: TextStyle(fontSize: 13)),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // 任务统计卡片
        Consumer<MovementProvider>(
          builder: (context, movementProvider, child) {
            final stats = movementProvider.statistics;
            final pendingInbound = stats['pendingInbound'] ?? 0;
            final pendingOutbound = stats['pendingOutbound'] ?? 0;
            final totalPending = pendingInbound + pendingOutbound;
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                    const Color(0xFF2C2C2C),
                    const Color(0xFF1E1E1E),
                  ]
                      : [
                    Colors.white,
                    Colors.grey[50]!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? Colors.grey[800]!
                      : Colors.grey[200]!,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withOpacity(0.3)
                        : Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 总待处理数
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.pending_actions,
                        size: 28,
                        color: totalPending > 0
                            ? AppTheme.warningColor
                            : AppTheme.successColor,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '$totalPending',
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                          color: totalPending > 0
                              ? AppTheme.warningColor
                              : AppTheme.successColor,
                          height: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '待处理',
                        style: TextStyle(
                          fontSize: 15,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 分隔线
                  Divider(
                    color: isDark ? Colors.grey[700] : Colors.grey[300],
                    height: 1,
                  ),
                  const SizedBox(height: 12),
                  // 详细统计
                  Row(
                    children: [
                      Expanded(
                        child: _buildMiniStatCard(
                          context,
                          theme,
                          isDark,
                          icon: Icons.add_box,
                          label: '待入库',
                          value: '$pendingInbound',
                          color: AppTheme.infoColor,
                          onTap: () => _navigateToInboundTasks(context),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildMiniStatCard(
                          context,
                          theme,
                          isDark,
                          icon: Icons.remove_circle,
                          label: '待出库',
                          value: '$pendingOutbound',
                          color: AppTheme.warningColor,
                          onTap: () => _navigateToOutboundTasks(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
  /// 构建迷你统计卡片 - 紧凑版
  Widget _buildMiniStatCard(
      BuildContext context,
      ThemeData theme,
      bool isDark, {
        required IconData icon,
        required String label,
        required String value,
        required Color color,
        VoidCallback? onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(isDark ? 0.15 : 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: color,
                ),
                const SizedBox(width: 6),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                    height: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
  /// 构建快捷操作区域 - 紧凑版
  Widget _buildQuickActions(BuildContext context, ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题栏
        Row(
          children: [
            Container(
              width: 3,
              height: 18,
              decoration: BoxDecoration(
                color: AppTheme.successColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '快捷操作',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.6,
          children: [
            _buildQuickActionButton(
              context,
              isDark,
              title: '库存管理',
              icon: Icons.inventory_2,
              color: AppTheme.primaryColor,
              onPressed: () => _navigateToInventory(context),
            ),
            _buildQuickActionButton(
              context,
              isDark,
              title: '采购入库',
              icon: Icons.add_box,
              color: AppTheme.successColor,
              onPressed: () => _navigateToInbound(context),
            ),
            _buildQuickActionButton(
              context,
              isDark,
              title: '销售出库',
              icon: Icons.remove_circle,
              color: AppTheme.warningColor,
              onPressed: () => _navigateToOutbound(context),
            ),
            _buildQuickActionButton(
              context,
              isDark,
              title: '任务管理',
              icon: Icons.list_alt,
              color: AppTheme.infoColor,
              onPressed: () => _navigateToMovementList(context),
            ),
          ],
        ),
      ],
    );
  }
  /// 构建快捷操作按钮 - 紧凑版
  Widget _buildQuickActionButton(
      BuildContext context,
      bool isDark, {
        required String title,
        required IconData icon,
        required Color color,
        required VoidCallback onPressed,
      }) {
    // 根据颜色亮度自动调整文字颜色
    final luminance = color.computeLuminance();
    final textColor = luminance > 0.5 ? Colors.black87 : Colors.white;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color,
            color.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(isDark ? 0.3 : 0.35),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 28,
                  color: textColor,
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  /// 格式化日期
  String _formatDate(DateTime date) {
    const months = [
      '一月', '二月', '三月', '四月', '五月', '六月',
      '七月', '八月', '九月', '十月', '十一月', '十二月'
    ];
    return '${date.year}年 ${months[date.month - 1]} ${date.day}日';
  }
  // 导航方法
  void _navigateToInventory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const InventoryListScreen(),
      ),
    );
  }
  void _navigateToInbound(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const InboundOrder(type: 'inbound'),
      ),
    );
  }
  void _navigateToOutbound(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const InboundOrder(type: 'outbound'),
      ),
    );
  }
  void _navigateToInboundTasks(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MovementListScreen(
          type: 'inbound',
          filterStatus: 'pending',
        ),
      ),
    );
  }
  void _navigateToOutboundTasks(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MovementListScreen(
          type: 'outbound',
          filterStatus: 'pending',
        ),
      ),
    );
  }
  void _navigateToMovementList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MovementListScreen(),
      ),
    );
  }
}