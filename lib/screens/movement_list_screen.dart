import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movement_provider.dart';
import '../models/movement_item.dart';
import '../utils/app_theme.dart';
import 'movement_detail_screen.dart';
import '../widgets/movement_item_card.dart';

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

    _tabController = TabController(length: 3, vsync: this);
    
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
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('出入库任务'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '全部'),
            Tab(text: '入库'),
            Tab(text: '出库'),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _onFilterSelected(value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'pending',
                child: Text('待处理'),
              ),
              const PopupMenuItem(
                value: 'approved',
                child: Text('已通过'),
              ),
              const PopupMenuItem(
                value: 'rejected',
                child: Text('已拒绝'),
              ),
            ],
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Column(
        children: [
          // 状态显示栏
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  _getStatusIcon(_selectedStatus),
                  color: _getStatusColor(_selectedStatus),
                ),
                const SizedBox(width: 8),
                Text(
                  _getStatusDisplayName(_selectedStatus),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // 任务列表
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMovementList(),
                _buildMovementList(type: MovementType.inbound),
                _buildMovementList(type: MovementType.outbound),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovementList({MovementType? type}) {
    return Consumer<MovementProvider>(
      builder: (context, movementProvider, child) {
        // 设置筛选条件
        movementProvider.setFilterStatus(_selectedStatus);
        movementProvider.setFilterType(type);

        final movements = movementProvider.filteredMovements;

        if (movements.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.list_alt,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  '暂无任务数据',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: movements.length,
          itemBuilder: (context, index) {
            final movement = movements[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: MovementItemCard(
                movement: movement,
                onTap: () => _navigateToDetail(context, movement.id),
              ),
            );
          },
        );
      },
    );
  }

  void _navigateToDetail(BuildContext context, String movementId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MovementDetailScreen(movementId: movementId),
      ),
    );
  }

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

  Color _getStatusColor(MovementStatus status) {
    switch (status) {
      case MovementStatus.pending:
        return AppTheme.warningColor;
      case MovementStatus.approved:
        return AppTheme.successColor;
      case MovementStatus.rejected:
        return AppTheme.errorColor;
    }
  }

  String _getStatusDisplayName(MovementStatus status) {
    switch (status) {
      case MovementStatus.pending:
        return '待处理';
      case MovementStatus.approved:
        return '已通过';
      case MovementStatus.rejected:
        return '已拒绝';
    }
  }
}