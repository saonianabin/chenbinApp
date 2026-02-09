import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/movement_item.dart';
import '../models/inventory_item.dart';
import 'inventory_provider.dart';

class MovementProvider extends ChangeNotifier {
  final List<MovementItem> _movements = [];
  MovementStatus _filterStatus = MovementStatus.pending;
  MovementType? _filterType;

  // Getters
  List<MovementItem> get movements => List.unmodifiable(_movements);
  MovementStatus get filterStatus => _filterStatus;
  MovementType? get filterType => _filterType;

  // 获取过滤后的任务列表
  List<MovementItem> get filteredMovements {
    return _movements.where((movement) {
      final matchesStatus = movement.status == _filterStatus;
      final matchesType = _filterType == null || movement.type == _filterType;
      return matchesStatus && matchesType;
    }).toList();
  }

  // 统计数据
  Map<String, dynamic> get statistics {
    final pendingInbound = _movements
        .where((m) => m.status == MovementStatus.pending && m.type == MovementType.inbound)
        .length;
    final pendingOutbound = _movements
        .where((m) => m.status == MovementStatus.pending && m.type == MovementType.outbound)
        .length;
    final totalMovements = _movements.length;

    return {
      'pendingInbound': pendingInbound,
      'pendingOutbound': pendingOutbound,
      'totalMovements': totalMovements,
    };
  }

  // 设置状态筛选
  void setFilterStatus(MovementStatus status) {
    _filterStatus = status;
    notifyListeners();
  }

  // 设置类型筛选
  void setFilterType(MovementType? type) {
    _filterType = type;
    notifyListeners();
  }

  // 获取所有任务
  List<MovementItem> getAllMovements() {
    return List.unmodifiable(_movements);
  }

  // 根据ID获取任务
  MovementItem? getMovementById(String id) {
    try {
      return _movements.firstWhere((movement) => movement.id == id);
    } catch (e) {
      return null;
    }
  }

  // 创建采购入库任务
  String createInboundMovement({
    required String supplier,
    required String warehouse,
    required List<MovementDetail> details,
    String? remarks,
    String operator = '系统管理员',
  }) {
    final movementId = DateTime.now().millisecondsSinceEpoch.toString();
    final movementNumber = 'IN${DateTime.now().millisecondsSinceEpoch}';

    final movement = MovementItem(
      id: movementId,
      movementNumber: movementNumber,
      type: MovementType.inbound,
      status: MovementStatus.pending,
      supplierOrCustomer: supplier,
      warehouse: warehouse,
      details: details,
      remarks: remarks,
      createdAt: DateTime.now(),
      operator: operator,
    );

    _movements.add(movement);
    notifyListeners();

    return movementId;
  }

  // 创建出库任务
  String createOutboundMovement({
    required String customer,
    required String warehouse,
    required List<MovementDetail> details,
    String? remarks,
    String operator = '系统管理员',
  }) {
    final movementId = DateTime.now().millisecondsSinceEpoch.toString();
    final movementNumber = 'OUT${DateTime.now().millisecondsSinceEpoch}';

    final movement = MovementItem(
      id: movementId,
      movementNumber: movementNumber,
      type: MovementType.outbound,
      status: MovementStatus.pending,
      supplierOrCustomer: customer,
      warehouse: warehouse,
      details: details,
      remarks: remarks,
      createdAt: DateTime.now(),
      operator: operator,
    );

    _movements.add(movement);
    notifyListeners();

    return movementId;
  }

  // 审核通过任务
  void approveMovement(String movementId, BuildContext context) {
    final movement = getMovementById(movementId);
    if (movement == null || movement.status != MovementStatus.pending) {
      return;
    }

    final inventoryProvider = Provider.of<InventoryProvider>(
      context,
      listen: false,
    );

    // 检查库存（仅对出库任务）
    if (movement.type == MovementType.outbound) {
      for (final detail in movement.details) {
        final item = inventoryProvider.getItemById(detail.inventoryItemId);
        if (item == null || item.availableStock < detail.finalQuantity) {
          throw Exception('库存不足：${detail.itemName} (需要: ${detail.finalQuantity}, 可用: ${item?.availableStock ?? 0})');
        }
      }
    }

    // 更新库存
    for (final detail in movement.details) {
      if (movement.type == MovementType.inbound) {
        // 入库：增加库存
        inventoryProvider.increaseStock(
          detail.inventoryItemId,
          detail.finalQuantity,
          reason: '采购入库 ${movement.movementNumber}',
        );
      } else if (movement.type == MovementType.outbound) {
        // 出库：减少库存
        inventoryProvider.decreaseStock(
          detail.inventoryItemId,
          detail.finalQuantity,
          reason: '销售出库 ${movement.movementNumber}',
        );
      }
    }

    // 更新任务状态
    final updatedMovement = movement.copyWith(
      status: MovementStatus.approved,
      processedAt: DateTime.now(),
    );

    _updateMovement(updatedMovement);
  }

  // 拒绝任务
  void rejectMovement(String movementId, String reason) {
    final movement = getMovementById(movementId);
    if (movement == null || movement.status != MovementStatus.pending) {
      return;
    }

    final updatedMovement = movement.copyWith(
      status: MovementStatus.rejected,
      rejectedReason: reason,
      processedAt: DateTime.now(),
    );

    _updateMovement(updatedMovement);
  }

  // 更新任务中的实际数量
  void updateActualQuantity(String movementId, String detailId, double actualQuantity) {
    final movement = getMovementById(movementId);
    if (movement == null || movement.status != MovementStatus.pending) {
      return;
    }

    final updatedDetails = movement.details.map((detail) {
      if (detail.id == detailId) {
        return detail.copyWith(actualQuantity: actualQuantity);
      }
      return detail;
    }).toList();

    final updatedMovement = movement.copyWith(details: updatedDetails);
    _updateMovement(updatedMovement);
  }

  // 删除任务
  void removeMovement(String movementId) {
    _movements.removeWhere((movement) => movement.id == movementId);
    notifyListeners();
  }

  // 更新任务
  void _updateMovement(MovementItem updatedMovement) {
    final index = _movements.indexWhere((m) => m.id == updatedMovement.id);
    if (index != -1) {
      _movements[index] = updatedMovement;
      notifyListeners();
    }
  }

  // 初始化示例数据
  void initializeSampleData() {
    // 示例采购入库任务
    final inboundId = createInboundMovement(
      supplier: '苹果中国',
      warehouse: '主仓库',
      details: [
        MovementDetail(
          id: 'detail1',
          inventoryItemId: '1',
          sku: 'ITM001',
          itemName: 'iPhone 15 Pro',
          requestedQuantity: 50.0,
          unit: '台',
          unitPrice: 8999.0,
        ),
        MovementDetail(
          id: 'detail2',
          inventoryItemId: '5',
          sku: 'ITM005',
          itemName: 'AirPods Pro 2',
          requestedQuantity: 100.0,
          unit: '个',
          unitPrice: 1899.0,
        ),
      ],
      remarks: '季度采购计划',
    );

    // 示例出库任务
    final outboundId = createOutboundMovement(
      customer: '京东商城',
      warehouse: '主仓库',
      details: [
        MovementDetail(
          id: 'detail3',
          inventoryItemId: '1',
          sku: 'ITM001',
          itemName: 'iPhone 15 Pro',
          requestedQuantity: 30.0,
          actualQuantity: 30.0,
          unit: '台',
          unitPrice: 9299.0,
        ),
        MovementDetail(
          id: 'detail4',
          inventoryItemId: '3',
          sku: 'ITM003',
          itemName: '小米13',
          requestedQuantity: 20.0,
          actualQuantity: 18.0,
          unit: '台',
          unitPrice: 3999.0,
        ),
      ],
      remarks: '大客户订单',
    );
  }
}