import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/movement_provider.dart';
import '../models/movement_item.dart';
import '../utils/app_theme.dart';
import 'inbound_order_detail.dart';
class MovementListScreen extends StatefulWidget {
  final String? type;
  final String? filterStatus;
  const MovementListScreen({
    super.key,
    this.type,
    this.filterStatus,
  });
  @override
  State<MovementListScreen> createState() => _MovementListScreenState();
}
class _MovementListScreenState extends State<MovementListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  MovementStatus _selectedStatus = MovementStatus.pending;
  @override
  void initState() {
    super.initState();
    // 根据传入的参数设置初始状态
    if (widget.filterStatus != null) {
      switch (widget.filterStatus) {
        case 'pending':
          _selectedStatus = MovementStatus.pending;
          break;
        case 'approved':
          _selectedStatus = MovementStatus.approved;
          break;
        case 'rejected':
          _selectedStatus = MovementStatus.rejected;
          break;
      }
    }
    _tabController = TabController(length: 2, vsync: this);
    // 如果指定了type，设置对应的tab
    if (widget.type != null) {
      switch (widget.type) {
        case 'inbound':
          _tabController.index = 0;
          break;
        case 'outbound':
          _tabController.index = 1;
          break;
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 刷新数据
      Provider.of<MovementProvider>(context, listen: false)
          .fetchNetworkLoadInboundList();
      Provider.of<MovementProvider>(context, listen: false)
          .fetchNetworkLoadOutboundList();
    });
  }
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('出入库任务'),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Column(
            children: [
              TabBar(
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withOpacity(0.7),
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: const TextStyle(fontSize: 14),
                controller: _tabController,
                tabs: const [
                  Tab(text: '入库'),
                  Tab(text: '出库'),
                ],
              ),
            ],
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            onSelected: (value) => _onFilterSelected(value),
            itemBuilder: (context) => [
              _buildPopupMenuItem('pending', '待处理', Icons.pending, Colors.orange, theme),
              _buildPopupMenuItem('approved', '已通过', Icons.check_circle, Colors.green, theme),
              _buildPopupMenuItem('rejected', '已拒绝', Icons.cancel, Colors.red, theme),
            ],
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Column(
        children: [
          // 状态筛选栏 - 优化版
          _buildStatusBar(theme, isDark),

          // 任务列表
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMovementList(
                    type: MovementType.inbound, theme: theme, isDark: isDark),
                _buildMovementList(
                    type: MovementType.outbound, theme: theme, isDark: isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }
  /// 构建弹出菜单项
  PopupMenuItem<String> _buildPopupMenuItem(
      String value,
      String label,
      IconData icon,
      Color color,
      ThemeData theme,
      ) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: theme.textTheme.bodyLarge?.color,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
  /// 构建状态栏 - 优化版
  Widget _buildStatusBar(ThemeData theme, bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
            const Color(0xFF2C2C2C),
            const Color(0xFF1E1E1E),
          ]
              : [
            _getStatusColor(_selectedStatus).withOpacity(0.1),
            _getStatusColor(_selectedStatus).withOpacity(0.05),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _getStatusColor(_selectedStatus).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _getStatusColor(_selectedStatus).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getStatusIcon(_selectedStatus),
              color: _getStatusColor(_selectedStatus),
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _getStatusDisplayName(_selectedStatus),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
          ),
          // 统计数量
          Consumer<MovementProvider>(
            builder: (context, provider, child) {
              int count = 0;
              final currentType = _tabController.index == 0
                  ? MovementType.inbound
                  : MovementType.outbound;

              var movements = currentType == MovementType.inbound
                  ? provider.fetchInboundList
                  : provider.fetchOutboundList;

              // 根据选中的状态筛选数量
              count = movements.where((item) {
                if (_selectedStatus == MovementStatus.pending) {
                  return item.status == '0';
                } else if (_selectedStatus == MovementStatus.approved) {
                  return item.status == '3';
                } else {
                  return item.status != '0' && item.status != '3';
                }
              }).length;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(_selectedStatus),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  /// 构建任务列表
  Widget _buildMovementList({
    MovementType? type,
    required ThemeData theme,
    required bool isDark,
  }) {
    return Consumer<MovementProvider>(
      builder: (context, movementProvider, child) {
        var movements = [];
        if (type == MovementType.inbound) {
          movements = movementProvider.fetchInboundList;
        } else if (type == MovementType.outbound) {
          movements = movementProvider.fetchOutboundList;
        }
        if (movements.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.list_alt,
                  size: 64,
                  color: theme.disabledColor,
                ),
                const SizedBox(height: 16),
                Text(
                  '暂无任务数据',
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.disabledColor,
                  ),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemCount: movements.length,
          itemBuilder: (context, index) {
            final movement = movements[index];
            return _productItemCard(movement, type, theme, isDark);
          },
        );
      },
    );
  }
  /// 构建产品卡片 - 优化版
  Widget _productItemCard(
      MovementItem item, type, ThemeData theme, bool isDark) {
    final statusText = item.status == '0'
        ? '待审核'
        : (item.status == '3' ? '审核通过' : '审核拒绝');
    final statusColor = selectColor(item.status ?? '0');
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: isDark
            ? Border.all(color: Colors.white.withOpacity(0.1), width: 1)
            : null,
        boxShadow: isDark
            ? null
            : [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (type == MovementType.inbound) {
              _navigateToDetail(
                  context, "${item.id}", item.status ?? "0", "inbound");
            } else if (type == MovementType.outbound) {
              _navigateToDetail(
                  context, "${item.id}", item.status ?? "0", "outbound");
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 头部：单据号 + 状态标签
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            type == MovementType.inbound
                                ? Icons.arrow_downward
                                : Icons.arrow_upward,
                            size: 18,
                            color: type == MovementType.inbound
                                ? AppTheme.successColor
                                : AppTheme.warningColor,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              item.code ?? '-',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: statusColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                Divider(
                  height: 1,
                  color: isDark ? Colors.grey[800] : Colors.grey[200],
                ),
                const SizedBox(height: 10),
                // 详细信息网格
                _buildInfoGrid(item, type, theme, isDark),
                const SizedBox(height: 8),

                // 底部操作信息
                Row(
                  children: [
                    Icon(Icons.person, size: 14, color: theme.disabledColor),
                    const SizedBox(width: 4),
                    Text(
                      item.createBy ?? '-',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.disabledColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.access_time, size: 14, color: theme.disabledColor),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item.createTime == null ? '-' : item.createTime.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.disabledColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  /// 构建信息网格
  Widget _buildInfoGrid(
      MovementItem item, type, ThemeData theme, bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildInfoItem('仓库', item.scName ?? '-', Icons.warehouse, theme)),
            const SizedBox(width: 10),
            Expanded(child: _buildInfoItem('数量', '${item.totalNum ?? 0}', Icons.inventory_2, theme)),
          ],
        ),
        const SizedBox(height: 8),
        if (type == MovementType.inbound)
          _buildInfoItem('供应商', item.supplierName ?? '-', Icons.local_shipping, theme)
        else if (type == MovementType.outbound)
          _buildInfoItem('客户', item.customerName ?? '-', Icons.person_outline, theme),
      ],
    );
  }
  /// 构建信息项
  Widget _buildInfoItem(String label, String value, IconData icon, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? Colors.white.withOpacity(0.05)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryColor),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  /// 状态颜色
  Color selectColor(String status) {
    if (status == '0') {
      return Colors.orange;
    } else if (status == '1' || status == '拒绝状态码') {
      return Colors.redAccent;
    } else {
      return Colors.green;
    }
  }
  /// 导航到详情页
  void _navigateToDetail(
      BuildContext context, String movementId, String status, String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InboundOrderDetail(
          type: type,
          inboundOderId: movementId,
          status: int.parse(status),
        ),
      ),
    );
  }
  /// 筛选状态选择
  void _onFilterSelected(String status) {
    setState(() {
      switch (status) {
        case 'pending':
          _selectedStatus = MovementStatus.pending;
          break;
        case 'approved':
          _selectedStatus = MovementStatus.approved;
          break;
        case 'rejected':
          _selectedStatus = MovementStatus.rejected;
          break;
      }
    });
  }
  /// 获取状态图标
  IconData _getStatusIcon(MovementStatus status) {
    switch (status) {
      case MovementStatus.pending:
        return Icons.pending;
      case MovementStatus.approved:
        return Icons.check_circle;
      case MovementStatus.rejected:
        return Icons.cancel;
    }
  }
  /// 获取状态颜色
  Color _getStatusColor(MovementStatus status) {
    switch (status) {
      case MovementStatus.pending:
        return Colors.orange;
      case MovementStatus.approved:
        return Colors.green;
      case MovementStatus.rejected:
        return Colors.red;
    }
  }
  /// 获取状态显示名称
  String _getStatusDisplayName(MovementStatus status) {
    switch (status) {
      case MovementStatus.pending:
        return '待处理任务';
      case MovementStatus.approved:
        return '已通过任务';
      case MovementStatus.rejected:
        return '已拒绝任务';
    }
  }
}