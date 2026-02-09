import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movement_provider.dart';
import '../providers/inventory_provider.dart';
import '../models/movement_item.dart';
import '../utils/app_theme.dart';

class MovementDetailScreen extends StatefulWidget {
  final String movementId;

  const MovementDetailScreen({
    super.key,
    required this.movementId,
  });

  @override
  State<MovementDetailScreen> createState() => _MovementDetailScreenState();
}

class _MovementDetailScreenState extends State<MovementDetailScreen> {
  MovementItem? _movement;
  final Map<String, TextEditingController> _quantityControllers = {};
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadMovement();
  }

  @override
  void dispose() {
    for (final controller in _quantityControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _loadMovement() {
    final movementProvider = context.read<MovementProvider>();
    final movement = movementProvider.getMovementById(widget.movementId);
    if (movement != null) {
      setState(() {
        _movement = movement;
      });

      // 初始化数量编辑控制器
      for (final detail in movement.details) {
        _quantityControllers[detail.id] = TextEditingController(
          text: detail.actualQuantity?.toString() ?? '',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_movement == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${_movement!.typeDisplayName}详情'),
        actions: [
          if (_movement!.status == MovementStatus.pending) ...[
            IconButton(
              icon: const Icon(Icons.check_circle),
              onPressed: _isProcessing ? null : () => _showApproveDialog(),
            ),
            IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: _isProcessing ? null : () => _showRejectDialog(),
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 任务基本信息
            _buildTaskInfoCard(),
            const SizedBox(height: 16),

            // 任务明细
            _buildDetailsCard(),
            const SizedBox(height: 24),

            // 操作按钮
            if (_movement!.status == MovementStatus.pending) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _showApproveDialog,
                      icon: const Icon(Icons.check),
                      label: const Text('审核通过'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isProcessing ? null : _showRejectDialog,
                      icon: const Icon(Icons.cancel),
                      label: const Text('拒绝'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.errorColor,
                        side: const BorderSide(color: AppTheme.errorColor),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTaskInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _movement!.type == MovementType.inbound
                      ? Icons.add_box
                      : Icons.remove_circle,
                  color: _getTypeColor(_movement!.type),
                ),
                const SizedBox(width: 8),
                Text(
                  '任务信息',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(_movement!.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _movement!.statusDisplayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(_movement!.status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('单据编号', _movement!.movementNumber),
            const SizedBox(height: 8),
            _buildInfoRow(_movement!.type == MovementType.inbound ? '供应商' : '客户', _movement!.supplierOrCustomer),
            const SizedBox(height: 8),
            _buildInfoRow('仓库', _movement!.warehouse),
            const SizedBox(height: 8),
            _buildInfoRow('操作人', _movement!.operator),
            const SizedBox(height: 8),
            _buildInfoRow('创建时间', _formatDateTime(_movement!.createdAt)),
            if (_movement!.processedAt != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow('处理时间', _formatDateTime(_movement!.processedAt!)),
            ],
            if (_movement!.remarks != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow('备注', _movement!.remarks!),
            ],
            if (_movement!.status == MovementStatus.rejected &&
                _movement!.rejectedReason != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow('拒绝原因', _movement!.rejectedReason!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '任务明细',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._movement!.details.asMap().entries.map((entry) {
              final index = entry.key;
              final detail = entry.value;
              return _buildDetailItem(detail, index);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(MovementDetail detail, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '项目 ${index + 1}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('商品', detail.itemName),
          const SizedBox(height: 8),
          _buildInfoRow('SKU', detail.sku),
          const SizedBox(height: 8),
          _buildInfoRow('单位', detail.unit),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildInfoRow('申请数量', '${detail.requestedQuantity} ${detail.unit}'),
              ),
              if (_movement!.type == MovementType.outbound) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoRow('现有库存', _getCurrentStock(detail.inventoryItemId)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          // 实际数量编辑（仅待处理状态）
          if (_movement!.status == MovementStatus.pending) ...[
            TextField(
              controller: _quantityControllers[detail.id],
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '实${_movement!.type == MovementType.inbound ? '收' : '发'}数量',
                border: const OutlineInputBorder(),
                suffixText: detail.unit,
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  context.read<MovementProvider>().updateActualQuantity(
                    _movement!.id,
                    detail.id,
                    double.tryParse(value) ?? 0.0,
                  );
                }
              },
            ),
          ] else ...[
            _buildInfoRow(
              '实${_movement!.type == MovementType.inbound ? '收' : '发'}数量',
              '${detail.finalQuantity} ${detail.unit}',
            ),
          ],
          if (detail.unitPrice != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow('单价', '¥${detail.unitPrice}'),
                ),
                Expanded(
                  child: _buildInfoRow('小计', '¥${detail.totalAmount}'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }

  void _showApproveDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认审核'),
        content: const Text('确认通过此任务？通过后将自动更新库存。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _approveMovement();
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('拒绝任务'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('请输入拒绝原因：'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: '拒绝原因',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context);
                _rejectMovement(controller.text.trim());
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('请输入拒绝原因')),
                );
              }
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  void _approveMovement() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 500)); // 模拟处理时间

      // 检查出库库存是否充足
      if (_movement!.type == MovementType.outbound) {
        final inventoryProvider = context.read<InventoryProvider>();
        for (final detail in _movement!.details) {
          final item = inventoryProvider.getItemById(detail.inventoryItemId);
          if (item == null || item.availableStock < detail.finalQuantity) {
            throw Exception('库存不足：${detail.itemName} (需要: ${detail.finalQuantity}, 可用: ${item?.availableStock ?? 0})');
          }
        }
      }

      context.read<MovementProvider>().approveMovement(_movement!.id, context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('任务审核通过'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('审核失败: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _rejectMovement(String reason) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 500)); // 模拟处理时间

      context.read<MovementProvider>().rejectMovement(_movement!.id, reason);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('任务已拒绝'),
            backgroundColor: AppTheme.warningColor,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('拒绝失败: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  String _getCurrentStock(String inventoryItemId) {
    final inventoryProvider = context.read<InventoryProvider>();
    final item = inventoryProvider.getItemById(inventoryItemId);
    return item != null ? '${item.availableStock} ${item.unit}' : '未知';
  }

  Color _getTypeColor(MovementType type) {
    switch (type) {
      case MovementType.inbound:
        return AppTheme.successColor;
      case MovementType.outbound:
        return AppTheme.warningColor;
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

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}