import 'package:chenbin_app/screens/inbound_order.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../providers/movement_provider.dart';
import '../utils/app_theme.dart';
import 'inventory_list_screen.dart';
import 'movement_list_screen.dart';
import '../widgets/statistics_card.dart';
import '../widgets/quick_action_button.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // 初始化示例数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MovementProvider>(context, listen: false).fetchNetworkLoadInboundList();
      Provider.of<MovementProvider>(context, listen: false).fetchNetworkLoadOutboundList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WMS 仓储管理'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 欢迎信息
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.accentColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '欢迎使用 WMS 仓储管理系统',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '今天是 ${_formatDate(DateTime.now())}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 库存统计卡片
            /*const Text(
              '库存概览',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Consumer<InventoryProvider>(
              builder: (context, inventoryProvider, child) {
                final stats = inventoryProvider.statistics;
                return GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.2,
                  children: [
                    StatisticsCard(
                      title: '总商品数',
                      value: '${stats['totalItems']}',
                      icon: Icons.inventory_2,
                      color: AppTheme.infoColor,
                    ),
                    StatisticsCard(
                      title: '库存预警',
                      value: '${stats['lowStockItems']}',
                      icon: Icons.warning,
                      color: AppTheme.warningColor,
                    ),
                    StatisticsCard(
                      title: '库存过量',
                      value: '${stats['overStockItems']}',
                      icon: Icons.trending_up,
                      color: AppTheme.warningColor,
                    ),
                    StatisticsCard(
                      title: '库存总量',
                      value: '${stats['totalValue']}',
                      icon: Icons.analytics,
                      color: AppTheme.successColor,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),*/

            // 任务统计
            const Text(
              '任务概览',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Consumer<MovementProvider>(
              builder: (context, movementProvider, child) {
                final stats = movementProvider.statistics;
                return Row(
                  children: [
                    Expanded(
                      child: StatisticsCard(
                        title: '待入库',
                        value: '${stats['pendingInbound']}',
                        icon: Icons.add_box,
                        color: AppTheme.infoColor,
                        onTap: () => _navigateToInboundTasks(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatisticsCard(
                        title: '待出库',
                        value: '${stats['pendingOutbound']}',
                        icon: Icons.remove_circle,
                        color: AppTheme.warningColor,
                        onTap: () => _navigateToOutboundTasks(context),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),

            // 快捷操作
            const Text(
              '快捷操作',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.5,
              children: [
                QuickActionButton(
                  title: '库存管理',
                  icon: Icons.inventory_2,
                  color: AppTheme.primaryColor,
                  onPressed: () => _navigateToInventory(context),
                ),
                QuickActionButton(
                  title: '采购入库',
                  icon: Icons.add_box,
                  color: AppTheme.successColor,
                  onPressed: () => _navigateToInbound(context),
                ),
                QuickActionButton(
                  title: '销售出库',
                  icon: Icons.remove_circle,
                  color: AppTheme.warningColor,
                  onPressed: () => _navigateToOutbound(context),
                ),
                QuickActionButton(
                  title: '任务管理',
                  icon: Icons.list_alt,
                  color: AppTheme.infoColor,
                  onPressed: () => _navigateToMovementList(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      '一月', '二月', '三月', '四月', '五月', '六月',
      '七月', '八月', '九月', '十月', '十一月', '十二月'
    ];
    return '${date.year}年 ${months[date.month - 1]} ${date.day}日';
  }

  void _navigateToInventory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const InventoryListScreen(),
      ),
    );
  }
  // 入库
  void _navigateToInbound(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const InboundOrder(
          type: 'inbound',
        ),
      ),
    );
  }

  // 出库
  void _navigateToOutbound(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const InboundOrder(
          type: 'outbound',
        ),
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