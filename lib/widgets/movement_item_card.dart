import 'package:flutter/material.dart';
import '../models/movement_item.dart';
import '../utils/app_theme.dart';

class MovementItemCard extends StatelessWidget {
  final MovementItem movement;
  final VoidCallback onTap;

  const MovementItemCard({
    super.key,
    required this.movement,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 任务头部信息
              Row(
                children: [
                  // 类型图标
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getTypeColor(movement.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      movement.type == MovementType.inbound
                          ? Icons.add_box
                          : Icons.remove_circle,
                      color: _getTypeColor(movement.type),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 任务信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movement.movementNumber,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${movement.typeDisplayName}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 状态标签
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      //color: _getStatusColor(movement.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "movement.statusDisplayName",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        //color: _getStatusColor(movement.status),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 任务详情
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      '总数量',
                      '${movement}',
                      Icons.analytics,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      '项目数',
                      '${movement}',
                      Icons.inventory_2,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      '仓库',
                      "movement",
                      Icons.warehouse,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 时间信息
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '创建时间: ',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (movement.processedAt != null) ...[
                    const SizedBox(width: 16),
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      //color: _getStatusColor(movement.status),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '处理时间: ${_formatDateTime(movement.processedAt!)}',
                      style: TextStyle(
                        fontSize: 12,
                        //color: _getStatusColor(movement.status),
                      ),
                    ),
                  ],
                ],
              ),

              // 拒绝原因
              if (movement.status == MovementStatus.rejected &&
                  movement.rejectedReason != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error,
                        size: 16,
                        color: AppTheme.errorColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '拒绝原因: ${movement.rejectedReason}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.errorColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
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
    return '${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')} '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}