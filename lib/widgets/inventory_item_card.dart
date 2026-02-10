import 'package:flutter/material.dart';
import '../models/inventory_item.dart';
import '../utils/app_theme.dart';

class InventoryItemCard extends StatelessWidget {
  final dynamic rowData;
  final InventoryItem item;
  final VoidCallback onTap;

  const InventoryItemCard({
    super.key,
    required this.item,
    required this.onTap, this.rowData,
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
              // 商品信息头部
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${rowData["productName"]}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '产品编号: ${rowData["productCode"]}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 库存状态指示器
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(item.stockStatusColor).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "${rowData["scName"]}",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(item.stockStatusColor),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 库存数量信息
              Row(
                children: [
                  Expanded(
                    child: _buildStockInfo(
                      '现有库存',
                      '${rowData["stockNum"]}',
                      Colors.blue,
                    ),
                  ),
                  Expanded(
                    child: _buildStockInfo(
                      '含税价格',
                      '${rowData["taxPrice"]}',
                      Colors.green,
                    ),
                  ),
                  Expanded(
                    child: _buildStockInfo(
                      '含税金额',
                      '${rowData["taxAmount"]}',
                      Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 库位信息
              if (item.location != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '产品品牌: ${rowData["brandName"]}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStockInfo(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String statusColor) {
    switch (statusColor) {
      case 'red':
        return AppTheme.errorColor;
      case 'orange':
        return AppTheme.warningColor;
      case 'green':
        return AppTheme.successColor;
      default:
        return Colors.grey;
    }
  }
}